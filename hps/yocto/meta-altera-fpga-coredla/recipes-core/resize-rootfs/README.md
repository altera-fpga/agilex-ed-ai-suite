# resize-rootfs

Recipe to resize the rootfs partition to fill the SD card

> [!WARNING]
> This will not work on an Arria10 board since it contains a partition to store the FPGA bitstream files right after the rootfs partition. Running `resize-rootfs.sh` on an Arria10 board will result in the following:
> ```
> Resizing partition /dev/mmcblk0p2 on /dev/mmcblk0 (partition 2)
> Resizing partition...
> Error: Can't have overlapping partitions.
> ERROR: Failed to resize partition.
> ```

Relies on the following recipes, included by default in `coredla-image.bb`:
```
e2fsprogs-resize2fs
parted
```

This recipe copies `resize-rootfs.sh` to `/usr/bin` and then sets up `resize-rootfs.service` to run upon first boot. The service runs `resize-rootfs.sh`, creates `/etc/resized`, disables the service, and then reboots. If the service were to run again then the presence of `/etc/resized` will prevent it from trying to resize the partition.

In the event that this recipe has not been included in the Yocto build (it is not included by default), `resize-rootfs.sh` can be copied to the board and run manually, provided the required recipes are included.
