# recipes-core/resize-rootfs/resize-rootfs.bb
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SUMMARY = "Script to resize the root partition on first boot"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://resize-rootfs.sh \
           file://resize-rootfs.service"

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "resize-rootfs.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/resize-rootfs.sh ${D}${bindir}

    # Install systemd service
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/resize-rootfs.service ${D}${systemd_system_unitdir}
}

FILES:${PN} += "${bindir}/resize-rootfs.sh ${systemd_system_unitdir}/resize-rootfs.service"

RDEPENDS:${PN} += "e2fsprogs-resize2fs parted"