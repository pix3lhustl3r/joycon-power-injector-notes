#!/bin/sh
# Switch session helper - Artix Linux
# Safe, no brick risk, no online updates, no sig‑patches
# Only local backup checks + SD mount / unmount + safety reminder

set -e

BACKUP_DIR="$HOME/nand-backups"
MOUNT_POINT="/mnt/switch"

warn() {
    printf "⚠️  %s\n" "$1"
}

okay() {
    printf "✅ %s\n" "$1"
}

fail() {
    printf "❌ %s\n" "$1"
    exit 1
}

# Detect Switch device (SD or eMMC over USB)
find_switch_device() {
    # Look for SD‑like block devices first
    for d in /dev/sd*1; do
        if [ -b "$d" ]; then
            echo "$d"
            return 0
        fi
    done

    # If that didn't reveal anything, try eMMC (mmcblk)
    if [ -b "/dev/mmcblk0" ]; then
        echo "/dev/mmcblk0"
        return 0
    fi

    return 1
}

# Turn e.g. /dev/sdX1 into /dev/sdX
device_root() {
    echo "$1" | sed 's/1$//'
}

do_check_backups() {
    echo
    echo "Checking backups in $BACKUP_DIR..."

    if [ -d "$BACKUP_DIR" ]; then
        if [ -f "$BACKUP_DIR"/*.raw ] || [ -f "$BACKUP_DIR"/*.bin ]; then
            okay "NAND / eMMC backups found in $BACKUP_DIR"
        else
            warn "No NAND backup file found in $BACKUP_DIR."
            echo "   You can create one later with a manual backup command."
        fi
    else
        warn "No backup directory; create it with: mkdir -p $BACKUP_DIR"
        echo "   Without backups, you have no brick‑proof safety net."
    fi
}

do_mount_sd() {
    echo
    echo "Detecting Switch over USB..."

    DRIVE=""
    for d in /dev/sd*1 /dev/mmcblk0p1; do
        if [ -b "$d" ]; then
            DRIVE="$d"
            break
        fi
    done

    if [ -z "$DRIVE" ]; then
        fail "No Switch SD / eMMC device detected over USB. Check cable / Switch."
    fi

    okay "Switch device detected: $DRIVE"

    if [ ! -d "$MOUNT_POINT" ]; then
        sudo mkdir -p "$MOUNT_POINT"
    fi

    if mountpoint -q "$MOUNT_POINT"; then
        warn "$MOUNT_POINT is already mounted; nothing to do."
    else
        echo "Mounting $DRIVE to $MOUNT_POINT..."
        sudo mount "$DRIVE" "$MOUNT_POINT"
        if [ -d "$MOUNT_POINT" ]; then
            okay "Switch SD mounted. Browse with:"
            ls -1 "$MOUNT_POINT" | head -n 10
            echo "   Full path: /mnt/switch"
        fi
    fi
}

do_unmount_sd() {
    echo
    if mountpoint -q "$MOUNT_POINT"; then
        echo "Unmounting $MOUNT_POINT..."
        sudo umount "$MOUNT_POINT"
        if mountpoint -q "$MOUNT_POINT"; then
            warn "Still mounted; check: sudo mount | grep $MOUNT_POINT"
        else
            okay "Unmounted $MOUNT_POINT."
        fi
    else
        warn "$MOUNT_POINT is not mounted; nothing to do."
    fi
}

do_safety_reminder() {
    echo
    echo "Safety notes:"
    echo "  • This script does NOT update firmware or sig‑patches."
    echo "  • This script does NOT connect to the internet."
    echo "  • This script does NOT brick‑risk your Switch."
    echo "  • It only does:"
    echo "    - Check local backups"
    echo "    - Mount or unmount your SD card"
    echo "    - Print this safety reminder."
}

print_menu() {
    echo
    echo "Switch session helper (Artix, no brick risk)"
    echo "============================================="
    echo "1) Check backups"
    echo "2) Mount SD card from Switch"
    echo "3) Unmount SD card"
    echo "4) Safety reminder only"
    echo "5) Exit"
    echo
}

main() {
    while true; do
        print_menu

        printf "Choose [1-5]: "
        read -r choice

        case "$choice" in
            1)
                do_check_backups
                echo
                ;;
            2)
                do_mount_sd
                echo
                ;;
            3)
                do_unmount_sd
                echo
                ;;
            4)
                do_safety_reminder
                echo
                ;;
            5)
                echo "Bye."
                exit 0
                ;;
            *)
                warn "Please pick 1, 2, 3, 4, or 5."
                ;;
        esac
    done
}

main
