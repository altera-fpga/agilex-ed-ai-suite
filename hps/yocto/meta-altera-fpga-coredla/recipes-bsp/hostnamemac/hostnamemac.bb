SUMMARY = "Append MAC address to hostname"
SECTION = "hostnamemac"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd
inherit features_check

SRC_URI = "file://hostnamemac.sh \
           file://hostnamemac.service \
	   "

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

SYSTEMD_SERVICE:${PN} = "hostnamemac.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
	install -d ${D}${systemd_system_unitdir}
	install -m 0644  ${S}/hostnamemac.service ${D}${systemd_system_unitdir}

	install -d ${D}${bindir}
	install -m 0755 ${S}/hostnamemac.sh ${D}${bindir}
}

FILES:${PN} += "${systemd_system_unitdir}/hostnamemac.service ${bindir}/hostnamemac.sh"
REQUIRED_DISTRO_FEATURES="systemd"
