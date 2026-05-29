# Replacement / Addendum for build_order.md Phase 12.16 — Right Sidebar Repo Root

**Where to put this:** Add a note at the top of the Phase 12.16 checklist in `build_order.md`, before the first checkbox. Also add a ⚠ marker to the `quickshell_plan.md` Section 2 "Repo root directory" open decision row, marking it as resolved.

---

## Resolved: Repo Root Directory = `~/dev`

The right sidebar scans for repositories from a single root directory. Per the open decision in `quickshell_plan.md`, this is confirmed as `~/dev`.

---

## Where in the Quickshell Config This Variable Lives

In `~/.config/quickshell/sidebar-right/RightSidebar.qml` (or `RepoCard.qml`), define the repo root as a top-level property:

```qml
// At the top of RightSidebar.qml, before any Item or Component declarations:
property string repoRoot: "/home/simone/dev"
```

Use `/home/simone/dev` rather than `~/dev` — QML does not expand `~` and the path will fail silently if `~` is used literally.

Pass `repoRoot` to the `Process` call that scans for `.git` directories:

```qml
Process {
    command: ["find", repoRoot, "-maxdepth", "2", "-name", ".git", "-type", "d"]
    // ...
}
```

---

## Before Building Phase 12.16

- [ ] Verify `~/dev` exists: `ls ~/dev` — if not, create it: `mkdir -p ~/dev`
- [ ] Clone at least one repository into `~/dev` so the sidebar has something to display during testing: `cd ~/dev && git clone <any-repo>`
- [ ] Set `repoRoot: "/home/simone/dev"` in `RightSidebar.qml` before first build — do not leave this as a placeholder
- [ ] After building, verify the find command works from the terminal before expecting it to work in QML:
  ```bash
  find /home/simone/dev -maxdepth 2 -name ".git" -type d
  ```

> **Note:** `quickshell_plan.md` suggests `repoRoot` as the variable name. Use exactly that name for consistency when referencing the Quickshell plan across future Claude sessions.
