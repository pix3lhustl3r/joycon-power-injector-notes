My Switch Atmosphere Setup Notes - pix3lhustler_

VERIFY FIRST:
- Hold both Volume + Power = AMS/fusee screen (good)
- Normal boot = no "Maintenance mode" (good) 

LINUX SETUP:
$ sudo pacman -S python-pyusb libusb hekate-switch
$ lsusb | grep 0955  # RCM mode check

DAY 1 - BACKUP EVERYTHING:
1. Hekate bin from GitHub → SD root  
2. Hekate → Tools → Backup eMMC BOOT0/BOOT1 (raw)
3. Hekate → Backup → eMMC BOOT (raw) 
   ↑ This = brick-proof forever

HOMEbrew (LEGAL):
- Tinfoil → RetroArch, Goldleaf only
- Skip NSP/CIA for now

LINUX TOOLS:
$ sudo pacman -S godmode9 hacdiskmount
$ sudo mount /dev/sdX1 /mnt/switch

DANGER:
- No RCM Loader apps from sketchy sites
- No "free games" NSPs  
- No firmware update without NAND backup

Next: NAND backup → homebrew → Python GPIO scripts
