# OFS FPGA Device Setup

A one-time setup step is required anytime an FPGA device using OFS is
powercycled or soft rebooted.  This setup step loads the pre-built OFS FIM onto
the FPGA to ensure it is ready to run the AI Suite AFU, as well as ensuring that
the host PC is able to communicate to the FPGA via PCIe.

## Create udev rules

> [!NOTE]
> Creating the following rule file will allow non-root users to perform
> inference.  It only needs to be done once.  This step may be skipped if that
> is not desired.

Create the following two udev rule files:

* `/etc/udev/rules.d/90-intel-fpga-opencl.rules`
```
KERNEL=="dfl-fme.[0-9]", ACTION=="add|change", GROUP="root", MODE="0666", RUN+="/bin/bash -c 'chmod 0666 %S%p/errors/ /dev/%k'"
KERNEL=="dfl-port.[0-9]", ACTION=="add|change", GROUP="root", MODE="0666", RUN+="/bin/bash -c 'chmod 0666 %S%p/dfl/userclk/frequency %S%p/errors/* /dev/%k'"
```

* `/etc/udev/rules.d/uio.rules`
```
SUBSYSTEM=="uio" KERNEL=="uio*" MODE="0666"
```

Then run the following commands to update the Linux system:

```shell
sudo udevadm control --reload
sudo udevadm trigger /dev/dfl-fme.0
sudo udevadm trigger /dev/dfl-port.0
sudo udevadm trigger --subsystem-match=uio --settle
```

## Program the FPGA with the OFS FIM

Obtain the pre-built OFS FIM for the target board from
[OFS 2024.2-1 Release](https://github.com/OFS/ofs-agx7-pcie-attach/releases/tag/ofs-2024.2-1).
It will contain the `ofs_top.sof` with the OFS FIM.  Program the FPGA with

```shell
quartus_pgm -c 1 -m jtag -o "p;<path to sof>/ofs_top.sof@1"
```

Reboot the host machine to allow it enumerate all connected PCIe devices.

```shell
sudo reboot
```

## Initialize OPAE

> [!NOTE]
> This must run whenever the host restarts.  This step can be made persistent
> with a systemd startup service.

OPAE must be initialized with the correct PCIe device address.  First, get the
relevant PCIe device address with

```shell
sudo fpgainfo fme
```

This will return an address in `s:b:d.f` format.  The OPAE initialization is
then done with

```shell
# Replace $PCIE_ADDR with the address obtained from the command above.
sudo pci_device $PCIE_ADDR vf 1

# If $PCIE_ADDR is `s:d:d.0` then $PCIE_ADDR_1 takes the form `s:b:d.1`.
sudo opae.io init -d $PCIE_ADDR_1 $USER
```
