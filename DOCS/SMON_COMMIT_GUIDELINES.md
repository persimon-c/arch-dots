# Commit Guidelines — arch-dots repo
## `github.com/persimon-c/arch-dots`

---

## Two Ways Files Get Into This Repo

This repo is managed by **two separate tools** that both push to the same remote. Never mix them up.

| Tool | What it manages | Local path |
|---|---|---|
| **chezmoi** | Dotfiles (`~/.config/*`, `~/.zshrc`) | `~/.local/share/chezmoi/` |
| **git directly** | Docs, wiki, readme | `~/Repo/arch-dots/` |

Both push to `github.com/persimon-c/arch-dots` on branch `main`. If one pushes ahead of the other, the other will get a rejection error and need `git pull --rebase` first.

---

## PART 1 — Chezmoi (dotfiles)

### What belongs here
Everything under `~/.config/` and `~/.zshrc` that is a config file you maintain. See `chezmoi managed` for the full list.

### What does NOT belong here
- Matugen output files (regenerated on every wallpaper change)
- ARCHIVE, DOCS, WIKI, README — these go in `~/Repo/arch-dots` directly
- Any file in `~/.config/quickshell/theme/colors.json`

### Adding a new dotfile
```bash
chezmoi add ~/.config/foo/bar.conf
chezmoi git -- add dot_config/foo/bar.conf
chezmoi git -- commit -m "feat(foo): add bar.conf"
chezmoi git -- push
```

### Updating a tracked dotfile
```bash
chezmoi re-add ~/.config/foo/bar.conf
chezmoi git -- add dot_config/foo/bar.conf
chezmoi git -- commit -m "feat(foo): update bar.conf"
chezmoi git -- push
```

### Removing a dotfile from tracking
```bash
chezmoi forget ~/.config/foo/bar.conf
rm ~/.local/share/chezmoi/dot_config/foo/bar.conf   # if still in source
chezmoi git -- add dot_config/foo/bar.conf
chezmoi git -- commit -m "chore(foo): remove bar.conf from tracking"
chezmoi git -- push
```

### Chezmoi naming rules
| Live path | chezmoi source name |
|---|---|
| `~/.config/foo` | `dot_config/foo` |
| `~/.zshrc` | `dot_zshrc` |
| `~/.config/gtk-3.0/` | `dot_config/private_gtk-3.0/` |
| `~/.config/rofi/wallpaper-picker.sh` | `dot_config/rofi/executable_wallpaper-picker.sh` |
| `~/.config/matugen/config.toml` | `dot_config/matugen/private_config.toml` |
| `~/.config/quickshell/services/Github.qml` | `dot_config/quickshell/services/private_Github.qml` |

### Checking chezmoi state
```bash
chezmoi status                          # what needs committing
chezmoi diff | grep "^diff --git"       # what differs between source and live
chezmoi git -- status                   # what git sees in the chezmoi source
chezmoi git -- log --oneline | head -10
```

---

## PART 2 — Direct Git (docs, wiki, readme)

### What belongs here
- `README.md`
- `DOCS/` — keybinds, apps, settings, setup plan, maintenance plan, system health
- `WIKI/` — Hyprland, Quickshell, Matugen reference docs
- `ARCHIVE/` — old plans, outdated configs kept for reference

### Workflow
```bash
cd ~/Repo/arch-dots
git add DOCS/keybinds.md
git commit -m "docs: update keybinds.md"
git push
```

### If push is rejected (chezmoi pushed ahead)
```bash
git pull --rebase origin main
# if conflict:
git add <conflicted_file>
GIT_EDITOR=true git rebase --continue
git push
```

### Recovering deleted files from history
```bash
# Find which commit deleted it
GIT_PAGER=cat git log --all --oneline --diff-filter=D -- PATH/

# Find the commit just before the deletion
GIT_PAGER=cat git log --oneline | head -20

# Restore from the commit before deletion
git checkout <commit-before-deletion>^ -- PATH/
git add PATH/
git commit -m "docs: restore PATH"
git push
```

---

## Commit Message Convention

```
feat(scope): add/update filename       # new file or meaningful update
chore(scope): remove/rename/cleanup    # housekeeping
docs: description                      # anything in DOCS/, WIKI/, ARCHIVE/, README
```

### Examples
```
feat(quickshell/bar): add Bar.qml
feat(quickshell/services): add Audio.qml
feat(matugen): update config.toml
feat(shell): update .zshrc
feat(btop): update btop.conf
chore(matugen/templates): remove rofi-colors.rasi
chore: remove matugen outputs and old hypr confs from tracking
docs: update keybinds.md
docs: restore WIKI and README
```

---

## Critical Rules

**Run chezmoi git commands one at a time.** Pasting multiple lines runs only the first — the rest are ignored silently.

**Never add ARCHIVE/DOCS/WIKI/README via chezmoi.** They have no live system target path so chezmoi will show them as a permanent phantom diff. Manage them from `~/Repo/arch-dots` directly.

**Never add matugen output files.** If they appear in `chezmoi diff`, use `chezmoi forget` on them. The list: `colors.json`, `matugen-colors.conf`, `colors.css`, `colors.sh`, `hypr-colors.conf`, `colors.rasi`.

**`chezmoi forget` does not delete from git.** You still need to `git add` the deletion and commit it.

**If chezmoi and `~/Repo/arch-dots` get out of sync**, always `git pull --rebase` from `~/Repo/arch-dots` before pushing. Use `GIT_EDITOR=true git rebase --continue` if it opens an editor and fails.

**`chezmoi diff` vs `chezmoi git -- status`:**
- `chezmoi diff` = source vs your live `~/.config`
- `chezmoi git -- status` = source vs what's committed to git
- These are different. Check both when debugging.
