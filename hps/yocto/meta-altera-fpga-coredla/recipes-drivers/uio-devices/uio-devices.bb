#
# This file is the uio-devices recipe.
#

SUMMARY = "uio-devices"
SECTION = "initscripts"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

FILESEXTRAPATHS:append := ":${THISDIR}/files"
SRC_URI = " \
	file://uio-devices \
	file://uio-devices.service \
	"

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

inherit systemd

do_install() {
	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
       		install -d ${D}${systemd_system_unitdir}
		install -m 644 ${S}/uio-devices.service ${D}${systemd_system_unitdir}/uio-devices.service
	fi

	install -d ${D}/usr/bin
	install -m 755 ${S}/uio-devices ${D}/usr/bin/uio-devices
}
FILES:${PN} += "${sysconfdir}/*"
FILES:${PN} += "${@bb.utils.contains('DISTRO_FEATURES','systemd','/usr/bin/uio-devices ${systemd_system_unitdir}/uio-devices.service','',d)}"

SYSTEMD_SERVICE:${PN} = "${@bb.utils.contains('DISTRO_FEATURES','systemd','uio-devices.service','',d)}"
