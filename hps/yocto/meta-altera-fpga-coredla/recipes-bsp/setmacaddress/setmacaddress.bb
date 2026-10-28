SUMMARY = "Set MAC address from config file in NV storage"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"


SRC_URI = "file://setmacaddress.sh \
           file://setmacaddress.rules \
           "

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

do_install() {
	install -d ${D}${sysconfdir}/udev/rules.d
	install -m 0644  ${S}/setmacaddress.rules ${D}${sysconfdir}/udev/rules.d

	install -d ${D}${bindir}
	install -m 0755 ${S}/setmacaddress.sh ${D}${bindir}

	sed -i -e s:/sbin:${base_sbindir}:g -e s:/etc:${sysconfdir}:g ${D}${bindir}/setmacaddress.sh
}
