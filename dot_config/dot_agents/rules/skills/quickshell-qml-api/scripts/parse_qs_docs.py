#!/usr/bin/env python3
"""
Parse Quickshell C++ headers into a rich QML API reference markdown.
v3: fixed module mapping, larger lookahead, enum values, dedup, clean output.
"""

import re
from pathlib import Path
from collections import defaultdict

SRC = Path("/tmp/qs-src/quickshell-master/src")

LOOKAHEAD = 150  # lines to scan ahead for QML_ELEMENT etc.

# ── helpers ───────────────────────────────────────────────────────────────────

def strip_doc(raw):
    lines = []
    for line in raw.splitlines():
        s = line.strip()
        if s.startswith("///!"):
            lines.append(s[4:].lstrip())
        elif s.startswith("///"):
            lines.append(s[3:].lstrip())
    return "\n".join(lines).strip()

def collect_doc_before(lines, idx):
    docs = []
    i = idx - 1
    while i >= 0:
        s = lines[i].strip()
        if s.startswith("///"):
            docs.insert(0, lines[i])
        elif s == "":
            i -= 1
            continue
        else:
            break
        i -= 1
    return strip_doc("\n".join(docs))

def module_for_path(path):
    rel = str(path.relative_to(SRC))
    if rel.startswith("bluetooth"):                 return "Quickshell.Bluetooth"
    if rel.startswith("dbus/dbusmenu"):             return "Quickshell.DBusMenu"
    if "hyprland" in rel:                           return "Quickshell.Hyprland"
    if rel.startswith("x11/i3"):                    return "Quickshell.I3"
    if rel.startswith("io"):                        return "Quickshell.Io"
    if rel.startswith("network"):                   return "Quickshell.Networking"
    if rel.startswith("services/greetd"):           return "Quickshell.Services.Greetd"
    if rel.startswith("services/mpris"):            return "Quickshell.Services.Mpris"
    if rel.startswith("services/notifications"):    return "Quickshell.Services.Notifications"
    if rel.startswith("services/pam"):              return "Quickshell.Services.Pam"
    if rel.startswith("services/pipewire"):         return "Quickshell.Services.Pipewire"
    if rel.startswith("services/polkit"):           return "Quickshell.Services.Polkit"
    if "status_notifier" in rel or "systemtray" in rel: return "Quickshell.Services.SystemTray"
    if rel.startswith("services/upower"):           return "Quickshell.Services.UPower"
    if rel.startswith("wayland"):                   return "Quickshell.Wayland"
    if rel.startswith("widgets"):                   return "Quickshell.Widgets"
    if rel.startswith("windowmanager"):             return "Quickshell.WindowManager"
    # window/ contains core types like PanelWindow, ExclusionMode, Anchors
    if rel.startswith("window"):                    return "Quickshell"
    return "Quickshell"

def parse_enum_block(lines, start):
    """Extract enum values from block starting at `start`. Returns list of {name, doc}."""
    block = []
    depth = 0
    for j in range(start, min(start + 40, len(lines))):
        s = lines[j].strip()
        depth += s.count("{") - s.count("}")
        block.append(lines[j])
        if j > start and depth <= 0:
            break
    text = "\n".join(block)
    values = []
    for m in re.finditer(
        r'((?:[ \t]*///[^\n]*\n)+)?[ \t]*([A-Z][A-Za-z0-9_]*)\s*(?:=\s*[^,\n]+)?,',
        text
    ):
        raw_doc = m.group(1) or ""
        val_name = m.group(2)
        val_doc = strip_doc(raw_doc) if raw_doc.strip() else ""
        values.append({"name": val_name, "doc": val_doc})
    return values

# ── parser ────────────────────────────────────────────────────────────────────

def parse_hpp(path):
    text = path.read_text(errors="replace")
    lines = text.splitlines()
    results = []
    in_signals = False
    current = None

    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        # Track signal sections
        if stripped == "signals:":
            in_signals = True; i += 1; continue
        if re.match(r'^(public|protected|private)(\s+slots)?:', stripped):
            in_signals = False

        # ── Namespace enum (Edges, WlrLayer, ExclusionMode, etc.) ─────────────
        ns_match = re.match(r'^namespace\s+(\w+)\s*(?:\{|//|$)', stripped)
        if ns_match:
            ns_name = ns_match.group(1)
            lookahead = "\n".join(lines[i:min(i + LOOKAHEAD, len(lines))])
            qml_ne = re.search(r'QML_NAMED_ELEMENT\((\w+)\)', lookahead)
            if "Q_NAMESPACE" in lookahead and ("QML_ELEMENT" in lookahead or qml_ne):
                qml_name = qml_ne.group(1) if qml_ne else ns_name
                ns_doc = collect_doc_before(lines, i)
                enum_vals = parse_enum_block(lines, i)
                results.append({
                    "name": qml_name, "kind": "enum_namespace",
                    "doc": ns_doc, "inherits": None, "singleton": False,
                    "properties": [], "functions": [], "signals": [],
                    "enums": [{"name": "Enum", "values": enum_vals}],
                })
                current = None

        # ── Class/struct ──────────────────────────────────────────────────────
        class_match = re.match(r'^(?:class|struct)\s+(\w+)[\s:{]', stripped)
        if class_match:
            cname = class_match.group(1)
            lookahead = "\n".join(lines[i:min(i + LOOKAHEAD, len(lines))])
            qml_ne = re.search(r'QML_NAMED_ELEMENT\((\w+)\)', lookahead)
            is_qml = bool(
                re.search(r'\bQML_ELEMENT\b', lookahead) or
                re.search(r'\bQML_SINGLETON\b', lookahead) or
                re.search(r'\bQSDOC_ELEMENT\b', lookahead) or
                qml_ne
            )
            if is_qml:
                qml_name = qml_ne.group(1) if qml_ne else cname
                cdoc = collect_doc_before(lines, i)
                if cdoc.startswith("!"): cdoc = cdoc[1:].lstrip()

                inh_ov = re.search(r'QSDOC_BASECLASS\((\w+)\)', lookahead)
                if inh_ov:
                    inherits = inh_ov.group(1)
                else:
                    inh = re.match(r'(?:class|struct)\s+\w+\s*:\s*(?:public\s+)?(\w+)', stripped)
                    raw_inh = inh.group(1) if inh else None
                    # strip irrelevant Qt internals
                    skip = {"QObject","QQuickItem","QQuickWindow","PostReloadHook",
                            "ProxyWindowBase","QQmlParserStatus","QAbstractListModel"}
                    inherits = raw_inh if raw_inh and raw_inh not in skip else None

                current = {
                    "name": qml_name, "kind": "type",
                    "doc": cdoc, "inherits": inherits,
                    "singleton": bool(re.search(r'\bQML_SINGLETON\b', lookahead)),
                    "properties": [], "functions": [], "signals": [], "enums": [],
                }
                in_signals = False
                results.append(current)

        if current and current["kind"] == "type":
            # Q_PROPERTY
            if "Q_PROPERTY(" in stripped and "QSDOC_HIDE" not in stripped:
                prop_raw = stripped
                while ");" not in prop_raw and i + 1 < len(lines):
                    i += 1; prop_raw += " " + lines[i].strip()
                type_ov = re.search(r'QSDOC_TYPE_OVERRIDE\((.+?)\)', prop_raw)
                clean = re.sub(r'QSDOC_\w+(\([^)]*\))?', '', prop_raw).strip()
                pm = re.match(r'Q_PROPERTY\(\s*(\S+)\s+(\w+)', clean)
                if pm:
                    ptype = type_ov.group(1) if type_ov else pm.group(1)
                    pname = pm.group(2)
                    readonly = "WRITE" not in prop_raw and "MEMBER" not in prop_raw
                    pdoc = collect_doc_before(lines, i)
                    current["properties"].append({
                        "name": pname, "type": ptype, "doc": pdoc, "readonly": readonly
                    })

            # Q_INVOKABLE
            inv = re.match(r'(?:static\s+)?Q_INVOKABLE\s+\S+\s+(\w+)\(([^)]*)\)', stripped)
            if inv:
                current["functions"].append({
                    "name": inv.group(1), "params": inv.group(2).strip(),
                    "doc": collect_doc_before(lines, i),
                })

            # Signals
            if in_signals:
                sig = re.match(r'void\s+(\w+)\(([^)]*)\)\s*;', stripped)
                if sig:
                    current["signals"].append({
                        "name": sig.group(1), "params": sig.group(2).strip(),
                        "doc": collect_doc_before(lines, i),
                    })

            # Nested enum
            if re.match(r'enum\b', stripped):
                vals = parse_enum_block(lines, i)
                em = re.match(r'enum\s+(?:class\s+)?(\w+)', stripped)
                ename = em.group(1) if em else "Enum"
                current["enums"].append({
                    "name": ename, "values": vals,
                    "doc": collect_doc_before(lines, i)
                })

        i += 1
    return results

# ── render ────────────────────────────────────────────────────────────────────

def render_type(t, module):
    out = []
    out.append(f"### {t['name']}")
    meta = [f"`{module}`"]
    if t.get("inherits"): meta.append(f"inherits `{t['inherits']}`")
    if t.get("singleton"): meta.append("**singleton**")
    out.append("  ".join(meta))

    if t.get("doc"):
        out.append(""); out.append(t["doc"])

    for e in t.get("enums", []):
        if not e["values"]: continue
        label = t["name"] if t["kind"] == "enum_namespace" else f"{t['name']}.{e['name']}"
        out.append(f"\n**Enum** `{label}`:")
        for v in e["values"]:
            dsuf = f" — {v['doc']}" if v['doc'] else ""
            out.append(f"- `{v['name']}`{dsuf}")

    if t.get("properties"):
        out.append("\n**Properties:**")
        for p in t["properties"]:
            ro = " *(readonly)*" if p.get("readonly") else ""
            dsuf = f" — {p['doc']}" if p.get("doc") else ""
            out.append(f"- `{p['name']}` : `{p['type']}`{ro}{dsuf}")

    if t.get("functions"):
        out.append("\n**Functions:**")
        for f in t["functions"]:
            dsuf = f" — {f['doc']}" if f.get("doc") else ""
            out.append(f"- `{f['name']}({f['params']})`{dsuf}")

    # Only emit non-trivial signals (skip xyzChanged noise)
    sigs = [s for s in t.get("signals", []) if not re.match(r'\w+Changed$', s["name"])]
    if sigs:
        out.append("\n**Signals:**")
        for s in sigs:
            p = f"({s['params']})" if s["params"] else "()"
            dsuf = f" — {s['doc']}" if s.get("doc") else ""
            out.append(f"- `{s['name']}{p}`{dsuf}")

    return "\n".join(out)

# ── main ──────────────────────────────────────────────────────────────────────

def main():
    by_module = defaultdict(dict)

    for hpp in sorted(SRC.rglob("*.hpp")):
        try:
            types = parse_hpp(hpp)
        except Exception as e:
            print(f"  skip {hpp.name}: {e}")
            continue
        mod = module_for_path(hpp)
        for t in types:
            key = t["name"]
            existing = by_module[mod].get(key)
            if existing is None:
                by_module[mod][key] = t
            else:
                # Merge: keep richer entry, combine enums
                if len(t["properties"]) > len(existing["properties"]):
                    # Keep new but merge in enums from old if missing
                    if not t["enums"] and existing["enums"]:
                        t["enums"] = existing["enums"]
                    by_module[mod][key] = t
                else:
                    if not existing["enums"] and t["enums"]:
                        existing["enums"] = t["enums"]
                    if not existing["doc"] and t["doc"]:
                        existing["doc"] = t["doc"]

    MODULE_ORDER = [
        "Quickshell",
        "Quickshell.Wayland",
        "Quickshell.Hyprland",
        "Quickshell.Io",
        "Quickshell.Services.Mpris",
        "Quickshell.Services.Notifications",
        "Quickshell.Services.SystemTray",
        "Quickshell.Services.Pipewire",
        "Quickshell.Services.UPower",
        "Quickshell.Networking",
        "Quickshell.Bluetooth",
        "Quickshell.Widgets",
        "Quickshell.WindowManager",
        "Quickshell.I3",
        "Quickshell.DBusMenu",
        "Quickshell.Services.Pam",
        "Quickshell.Services.Greetd",
        "Quickshell.Services.Polkit",
    ]
    all_mods = MODULE_ORDER + sorted(set(by_module.keys()) - set(MODULE_ORDER))

    out = Path(__file__).parent.parent / "references" / "quickshell-api.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    total = 0
    with out.open("w") as f:
        f.write("# Quickshell v0.3.0 QML API Reference\n\n")
        f.write("Extracted from source: https://github.com/quickshell-mirror/quickshell\n\n")
        f.write("---\n\n")
        for mod in all_mods:
            if mod not in by_module: continue
            types = sorted(by_module[mod].values(), key=lambda x: x["name"])
            f.write(f"## {mod}\n\n")
            for t in types:
                f.write(render_type(t, mod))
                f.write("\n\n---\n\n")
                total += 1

    print(f"\nWrote {total} types, {out.stat().st_size/1024:.1f} KB")

    text = out.read_text()
    checks = [
        "WlrLayer", "ExclusionMode", "Edges", "MprisPlaybackState",
        "PanelWindow", "Process", "Hyprland", "SystemTray", "WlrLayershell",
        "MprisPlayer", "NotificationServer", "Pipewire",
    ]
    print("\nSanity check:")
    for c in checks:
        t_ok = f"### {c}" in text
        e_ok = f"Enum` {c}" in text or (t_ok and "Enum**" in text[text.find(f"### {c}"):text.find(f"### {c}")+600])
        print(f"  {c:30s} type={'✓' if t_ok else '✗'}  enum={'✓' if e_ok else '-'}")

if __name__ == "__main__":
    main()