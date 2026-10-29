#!/bin/sh

# Check if resize has been done
if [ ! -f /etc/resized ]; then
    # Get root partition device
    ROOT_PART=$(mount | grep "on / type" | cut -d' ' -f1)
    if [ -z "$ROOT_PART" ]; then
      echo "ERROR: Unable to detect root partition."
      exit 1
    fi
    # Extract base device and partition number
    # Example: from /dev/mmcblk0p2 -> /dev/mmcblk0 and 2
    ROOT_DEV=$(echo "$ROOT_PART" | sed -E 's|p?[0-9]+$||')
    PART_NUM=$(echo "$ROOT_PART" | grep -o '[0-9]*$')

    echo "Resizing partition $ROOT_PART on $ROOT_DEV (partition $PART_NUM)"

    # Resize partition to fill SD card
    echo "Resizing partition..."
    parted -s "$ROOT_DEV" resizepart "$PART_NUM" 100% || {
      echo "ERROR: Failed to resize partition."
      exit 1
   }

    # Resize filesystem
    resize2fs "$ROOT_PART" || {
      echo "ERROR: Failed to resize filesystem."
      exit 1
    }

    # Mark as resized
    touch /etc/resized
    sync
    echo "Root filesystem has been resized."

    # Remove this service to prevent running again
    systemctl disable resize-rootfs.service

    echo "Resize script completed. Rebooting..."
    reboot
else
    echo "System already resized. Nothing to do."
    exit 0
fi