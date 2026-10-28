DESCRIPTION = "Yocto recipe for userio module"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"
inherit module

# Set source paths
SRC_URI = "file://Makefile \
           file://msgdma_userio_chr.c \
           file://msgdma_userio_chr.h \
           file://msgdma_userio.h \
           file://msgdma_userio_platform.c \
           "

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

RPROVIDES_${PN}:append = "module-msgdma-userio"
