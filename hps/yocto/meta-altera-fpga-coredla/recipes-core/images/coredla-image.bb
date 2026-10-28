DESCRIPTION = "Builds the CoreDLA image"
LICENSE="MIT"

inherit image

IMAGE_FEATURES += "empty-root-password allow-empty-password"

VIRTUAL-RUNTIME_dev_manager = "udev"

VIRTUAL-RUNTIME_init_manager = "systemd"
VIRTUAL-RUNTIME_initscripts= " "
VIRTUAL-RUNTIME_login_manager = "busybox shadow"

export IMAGE_BASENAME = "coredla-image"

IMAGE_PREPROCESS_COMMAND += "do_systemd_network ; "

do_systemd_network () {
	install -d ${IMAGE_ROOTFS}${sysconfdir}/systemd/network
	cat << EOF > ${IMAGE_ROOTFS}${sysconfdir}/systemd/network/10-en.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF

	cat << EOF > ${IMAGE_ROOTFS}${sysconfdir}/systemd/network/11-eth.network
[Match]
Name=eth*

[Network]
DHCP=yes
EOF
}

# ADD YOUR MODULE RECIPE(S) HERE
IMAGE_INSTALL:append = " \
	${VIRTUAL-RUNTIME_dev_manager} \
	${VIRTUAL-RUNTIME_init_manager} \
	${VIRTUAL-RUNTIME_initscripts} \
	${VIRTUAL-RUNTIME_login_manager} \
	packagegroup-core-ssh-openssh \
	mtd-utils-ubifs \
	devmem2 \
	i2c-tools \
	update-alternatives-opkg \
	setmacaddress \
	strace \
	gdbserver \
	hostnamemac \
	avahi-daemon \
	avahi-autoipd \
	msgdma-userio \
	uio-devices \
	kernel-modules \
	python3 \
	python3-pip \
	lrzsz \
	perf \
	valgrind \
	e2fsprogs-resize2fs \
	parted \
	util-linux \
	"


WKS_FILES:arria10 = "coredla-image.wks"
WKS_FILES:agilex7_dk_si_agi027fc = "coredla-agilex7_dk_si_agi027fc-image.wks"
WKS_FILES:agilex5_mk_a5e065bb32aes1 = "coredla-agilex5_mk_a5e065bb32aes1-image.wks"
WKS_FILES:agilex3 = "coredla-agilex3-image.wks"

# add intel-rsu-lib unless building for arria10
IMAGE_INSTALL:append = ' ${@oe.utils.conditional("MACHINE", "arria10", "", " intel-rsu-lib", d)}'

UBOOT_EXTLINUX_ROOT:agilex7_dk_si_agi027fc = "root=/dev/mmcblk0p2"
UBOOT_EXTLINUX_ROOT:agilex3 = "root=/dev/mmcblk0p2"

IMAGE_BOOT_FILES:agilex7_dk_si_agi027fc = " \
			${UBOOT_BINARY} \
			Image \
			socfpga_agilex_socdk.dtb;socfpga-agilex-socdk.dtb \
			extlinux.conf;extlinux/extlinux.conf \
			"

IMAGE_BOOT_FILES:arria10 = " \
			${UBOOT_BINARY} \
			${KERNEL_IMAGETYPE} \
			socfpga_arria10_socdk_sdmmc.dtb \
			extlinux.conf;extlinux/extlinux.conf \
			"

IMAGE_BOOT_FILES:agilex5_mk_a5e065bb32aes1 = " \
			${UBOOT_BINARY} \
			Image \
			socfpga_agilex5_socdk_modular.dtb;socfpga-agilex5-socdk.dtb \
			extlinux.conf;extlinux/extlinux.conf \
			"

IMAGE_BOOT_FILES:agilex3 = " \
			${UBOOT_BINARY} \
			Image \
			socfpga_agilex3_socdk.dtb;socfpga-agilex5-socdk.dtb \
			extlinux.conf;extlinux/extlinux.conf \
			"
