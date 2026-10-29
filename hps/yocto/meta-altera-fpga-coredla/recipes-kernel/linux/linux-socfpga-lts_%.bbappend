FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://0001-altera-msgdma.patch \
    file://enable-coredla-mod.cfg \
    file://coredla-dts.patch \
    file://coredla-agilex-dts.patch \
    file://coredla-agilex5-dts.patch \
"
