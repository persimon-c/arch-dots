# Missing Setup Step: Pacman Hooks

Two hooks that protect dual boot stability after package updates.

---

## Hook 1: sbctl Re-signing After GRUB or Kernel Update

When GRUB or the kernel is updated, the sbctl Secure Boot signatures become stale. This hook automatically re-signs both after any update to either package, so Secure Boot stays valid without manual intervention.

1. **Create the hooks directory if it does not exist:**

   ```bash
   sudo mkdir -p /etc/pacman.d/hooks
   ```

2. **Write the hook file:**

   ```bash
   sudo tee /etc/pacman.d/hooks/sbctl-sign.hook > /dev/null << 'EOF'
   [Trigger]
   Operation = Upgrade
   Type = Package
   Target = grub
   Target = linux

   [Action]
   Description = Re-signing GRUB and kernel with sbctl after update
   When = PostTransaction
   Exec = /bin/sh -c 'sbctl sign -s /efi/EFI/GRUB/grubx64.efi && sbctl sign -s /boot/vmlinuz-linux'
   EOF
   ```

3. **Verify the file was written correctly:**

   ```bash
   cat /etc/pacman.d/hooks/sbctl-sign.hook
   ```

   The hook uses the automated signing form (not the reminder form) because forgetting to re-sign after a kernel update is a boot failure waiting to happen. The `-s` flag to `sbctl sign` adds the file to sbctl's list of files to re-sign on future `sbctl sign --generate` calls.

> **Note:** This hook only matters after Secure Boot is configured and signed (Phase — Dual Boot Protection in `setup_plan.md`). Creating the hook file before that point is harmless — sbctl will simply not be present yet and the Exec command will fail silently on any premature package updates. Install the hook file at the same time you do the Secure Boot signing.

---

## Hook 2: GRUB Fallback Path Copy After GRUB Update

When GRUB is updated, the fallback EFI path (`/efi/EFI/Boot/bootx64.efi`) is not automatically updated. This hook copies the new GRUB binary to the fallback path immediately after any GRUB update, so the fallback boot path stays current.

1. **Write the hook file** (the hooks directory should already exist from Hook 1):

   ```bash
   sudo tee /etc/pacman.d/hooks/grub-fallback.hook > /dev/null << 'EOF'
   [Trigger]
   Operation = Upgrade
   Type = Package
   Target = grub

   [Action]
   Description = Copying updated GRUB binary to UEFI fallback path
   When = PostTransaction
   Exec = /bin/cp /efi/EFI/GRUB/grubx64.efi /efi/EFI/Boot/bootx64.efi
   EOF
   ```

2. **Verify:**

   ```bash
   cat /etc/pacman.d/hooks/grub-fallback.hook
   ```

3. **Run the fallback copy manually once** to make sure the path is current right now (not just on future updates):

   ```bash
   sudo cp /efi/EFI/GRUB/grubx64.efi /efi/EFI/Boot/bootx64.efi
   ```

   Verify the copy succeeded:

   ```bash
   ls -lh /efi/EFI/Boot/bootx64.efi
   # Should show a file of roughly the same size as /efi/EFI/GRUB/grubx64.efi
   ```

> **Chezmoi note:** Both hook files are system files (under `/etc/`). Track them in Chezmoi as system files:
> ```bash
> chezmoi add /etc/pacman.d/hooks/sbctl-sign.hook
> chezmoi add /etc/pacman.d/hooks/grub-fallback.hook
> ```
> Chezmoi handles system files via `sudo` mode — it will prompt for your password when applying.
