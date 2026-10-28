SUMMARY="Intel RSU (Remote System Update) library"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "git://github.com/altera-opensource/intel-rsu.git;protocol=https;branch=master; \
           file://001_cross_compile_to_cc.patch \
          "

PV = "1.0+git${SRCPV}"
SRCREV = "91ce86efca46d6b819428ff7769fb458478556e7"
DEPENDS = "zlib"

S = "${WORKDIR}/git"

do_compile () {
        export EXTRA_LDFLAGS="${LDFLAGS}"
	oe_runmake -C lib
}

do_install () {
	export INSTALL_PATH="${D}${libdir}"
        install -d ${INSTALL_PATH}
	oe_runmake -C ${S}/lib install
}


