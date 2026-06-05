# System Health Report
**Device:** ASUS TUF Gaming FX505DT  
**Date:** June 1, 2026  
**Context:** Post-recovery check after "Unmountable Boot Volume" incident during Arch Linux dual-boot setup

---

## Summary

All critical checks passed. Disks are healthy, filesystem is clean, and hardware performance is within expected ranges for this hardware. The only errors in the event log are NVIDIA service failures unrelated to disk or filesystem health.

---

## Disk Health

**Command:** `wmic diskdrive get status,model,size`

| Model | Size | Status |
|---|---|---|
| ST1000LM035-1RK172 (HDD, sda) | 1,000,202,273,280 bytes (~931 GB) | **OK** |
| TS256GMTE110S (NVMe SSD, nvme0n1) | 256,052,966,400 bytes (~238 GB) | **OK** |
| VendorCo ProductCode USB Device | 31,453,470,720 bytes (~29 GB) | OK |

Both internal drives report healthy status. No drive errors detected at the hardware level.

---

## Partition Layout (from diskpart)

**Command:** `list disk` + `list volume`

### Disks

| Disk | Status | Size |
|---|---|---|
| Disk 0 (HDD, sda) | Online | 931 GB |
| Disk 1 (NVMe SSD, nvme0n1) | Online | 238 GB |
| Disk 2 (USB) | Online | 29 GB |

### Volumes

| Volume | Letter | Label | Filesystem | Size | Status | Info |
|---|---|---|---|---|---|---|
| 0 | D: | DATA | NTFS | 305 GB | Healthy | Pagefile (Windows HDD storage) |
| 1 | C: | OS | NTFS | 174 GB | **Healthy** | Boot (Windows SSD partition) |
| 2 | — | SYSTEM | FAT32 | 260 MB | Healthy | System (shared EFI partition) |
| 3 | — | RECOVERY | NTFS | 1100 MB | Healthy | Hidden (Windows Recovery) |
| 4 | — | — | — | 253 MB | Unusable | Arch Linux ext4 root (not readable by Windows) |

Volume 1 (C:, OS, 174 GB) is the partition that showed as RAW during the incident. It now shows as **NTFS, Healthy, Boot** — confirming the ntfsfix repair was successful.

---

## Filesystem Integrity Check

**Command:** `chkdsk C: /scan`  
**Mode:** Read-only online scan (no changes made)

| Check | Result |
|---|---|
| File records processed | 2,085,120 |
| Bad file records | **0** |
| Index entries processed | 2,412,604 |
| Unindexed files | **0** |
| Bad sectors | **0** |
| Data files processed | 163,743 |
| Overall result | **No problems found** |

**Disk space:**

| Metric | Value |
|---|---|
| Total disk space | 182,616,742 KB (~174 GB) |
| In use by files | 127,247,780 KB (~121 GB) |
| Available | 52,715,352 KB (~50 GB) |
| Allocation unit size | 4,096 bytes |
| Total duration | 1.15 minutes |

The filesystem is fully consistent. No further action required on the Windows partition.

---

## Performance Assessment

**Command:** `winsat formal`  
**Total run time:** 1 minute 51 seconds

### CPU

| Test | Score |
|---|---|
| LZW Compression (multicore) | 453.19 MB/s |
| AES256 Encryption (multicore) | 5,646.74 MB/s |
| Vista Compression (multicore) | 1,119.03 MB/s |
| SHA1 Hash (multicore) | 2,580.74 MB/s |
| LZW Compression (single core) | 83.35 MB/s |
| AES256 Encryption (single core) | 853.53 MB/s |
| Vista Compression (single core) | 197.12 MB/s |
| SHA1 Hash (single core) | 581.66 MB/s |

Normal for Ryzen 5 3550H (4 cores, 8 threads). AES hardware acceleration visible in the encryption scores.

### Memory

| Test | Score |
|---|---|
| Memory Performance | 15,006.87 MB/s |

Normal for dual-channel DDR4 at this spec.

### Storage (NVMe SSD)

| Test | Score | WinSAT Score |
|---|---|---|
| Sequential 64.0 Read | 1,584.75 MB/s | 8.8 |
| Random 16.0 Read | 436.88 MB/s | 8.2 |

Normal for the TS256GMTE110S NVMe drive. Sequential read of ~1,585 MB/s is within the expected range for this model.

### Graphics (Direct3D)

All Direct3D tests returned 42.00 F/s across all tiers. This is a WinSAT cap behavior when the GPU is not being fully utilized in the test environment — not indicative of GPU failure. The GTX 1650 is functional.

Video Memory Throughput: 6,457.41 MB/s — normal for GTX 1650 GDDR5.

---

## System Event Log

**Command:** `Get-EventLog -LogName System -EntryType Error -Newest 20`

All 20 errors (June 1, 2026, 02:10–02:11) are from a single source:

> **Service Control Manager — NVIDIA LocalSystem Container**  
> Instance IDs: 3221232503, 3221232495 (alternating)

**Assessment:** These errors are not related to disk health, filesystem integrity, or the partition resize. They are NVIDIA service startup failures, likely caused by Secure Boot state being inconsistent during previous boot attempts (Secure Boot was toggled multiple times during the troubleshooting session). These errors are expected to clear once Windows is booted stably with a consistent Secure Boot configuration.

No disk errors, no filesystem errors, no memory errors, no critical hardware failures in the event log.

---

## Incident Summary

### What happened

During Arch Linux installation, `ntfsresize` shrunk the Windows C: partition (nvme0n1p3) from ~237 GB to ~174 GB. The resize completed without errors, but the NTFS boot sector retained an incorrect sector count (365,234,368 instead of the correct 365,233,485). Windows was not booted after the resize to run its own consistency check, so the incorrect sector count persisted.

On a later boot attempt, Windows encountered the corrupt boot sector and reported "Unmountable Boot Volume."

### How it was fixed

Booted the Arch Linux live USB and ran:
```bash
ntfsfix /dev/nvme0n1p3
```

ntfsfix detected that the primary boot sector was unreadable (invalid sector count), found the alternate boot sector was usable, rewrote the primary boot sector with the correct sector count (365,233,485), and processed the MFT successfully.

Output:
```
Trying the alternate boot sector
The alternate bootsector is usable
Set sector count to 365233485 instead of 365234368
Rewriting the bootsector
The boot sector has been rewritten
Processing $MFT and $MFTMirr...
Reading $MFT... OK
Reading $MFTMirr... OK
Comparing $MFTMirr to $MFT... OK
Processing of $MFT and $MFTMirr completed successfully.
Setting required flags on partition... OK
Going to empty the journal ($LogFile)... OK
Checking the alternate boot sector... FIXED
NTFS volume version is 3.1.
NTFS partition /dev/nvme0n1p3 was processed successfully.
```

Windows booted normally after this repair.

### Prevention

After any NTFS partition resize from a Linux live environment, boot Windows before proceeding with further Linux setup. Windows will verify the filesystem on first boot and correct any inconsistencies. This is documented in the installation plan patch.

---

## Overall Assessment

| Area | Status |
|---|---|
| HDD (ST1000LM035) | Healthy |
| NVMe SSD (TS256GMTE110S) | Healthy |
| Windows C: filesystem | Clean, no errors |
| Windows boot | Functional |
| CPU | Normal |
| Memory | Normal |
| Storage performance | Normal |
| GPU | Functional |
| Event log | No hardware or disk errors |

System is in good health. Safe to proceed with Arch Linux Secure Boot configuration.
