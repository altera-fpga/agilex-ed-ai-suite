FILESEXTRAPATHS:append := ":${THISDIR}/files"

UBOOT_EXTLINUX_KERNEL_ARGS:append:agilex7_dk_si_agi027fc=" cma=230M mem=8G"

# Boot command patches/cfg inclusion, with optional firmware
SRC_URI:append:arria10   = "\
 file://0001-fpga1sdram1-bridge-enable.patch\
 ${@oe.utils.conditional("ALTERA_FPGA_FIRMWARE", "1", " file://fit_spl_fpga.itb", "", d)}\
 "

SRC_URI:append:agilex5_mk_a5e065bb32aes1 = " file://agilex5-bridge-enable-bootcmd.cfg "

SRC_URI:append:agilex3 = " file://agilex-bridge-enable-bootcmd.cfg \
                           file://agilex-defconfig-settings.cfg \
                        "
U_BOOT_AGILEX_PATCH_CFG_FW = "\
  file://0001-agilex-fpga-bridge-enable.patch\
  file://agilex-bridge-enable-bootcmd.cfg\
  ${@oe.utils.conditional("ALTERA_FPGA_FIRMWARE", "1", " file://top.core.rbf file://uboot-script-agilex_fm87.txt file://uboot_script.its", "", d)}\
  "
SRC_URI:append:agilex7_dk_si_agf014ea = " ${U_BOOT_AGILEX_PATCH_CFG_FW} "
SRC_URI:append:agilex7_dk_si_agf014eb = " ${U_BOOT_AGILEX_PATCH_CFG_FW} "
SRC_URI:append:agilex7_dk_si_agi027fa = " ${U_BOOT_AGILEX_PATCH_CFG_FW} "
SRC_URI:append:agilex7_dk_si_agi027fb = " ${U_BOOT_AGILEX_PATCH_CFG_FW} "
SRC_URI:append:agilex7_dk_si_agi027fc = " ${U_BOOT_AGILEX_PATCH_CFG_FW} "
SRC_URI:append:agilex7_dk_dev_agf027f1es = " ${U_BOOT_AGILEX_PATCH_CFG_FW} "

U_BOOT_SCRIPT = ""
U_BOOT_SCRIPT:agilex7_dk_si_agf014ea = "uboot-script-agilex_fm87.txt"
U_BOOT_SCRIPT:agilex7_dk_si_agf014eb = "uboot-script-agilex_fm87.txt"
U_BOOT_SCRIPT:agilex7_dk_si_agi027fa = "uboot-script-agilex_fm87.txt"
U_BOOT_SCRIPT:agilex7_dk_si_agi027fb = "uboot-script-agilex_fm87.txt"
U_BOOT_SCRIPT:agilex7_dk_si_agi027fc = "uboot-script-agilex_fm87.txt"
U_BOOT_SCRIPT:agilex7_dk_dev_agf027f1es = "uboot-script-agilex_fm87.txt"

do_compile:append() {
    if [[ -n "${U_BOOT_SCRIPT}" && "${ALTERA_FPGA_FIRMWARE}" == "1" ]]; then
        cp ${WORKDIR}/${U_BOOT_SCRIPT} ${WORKDIR}/uboot.txt
        mkimage -f "${WORKDIR}/uboot_script.its" ${B}/boot.scr.uimg
    fi
}

do_deploy:append() {
    if [[ "${ALTERA_FPGA_FIRMWARE}" == "1" ]]; then
        if [[ "${MACHINE}" == "arria10" ]]; then
            install -m 0644 ${WORKDIR}/fit_spl_fpga.itb ${DEPLOYDIR}/fit_spl_fpga.itb
        else
            install -m 0644 ${B}/boot.scr.uimg ${DEPLOYDIR}/boot.scr.uimg
            install -m 0644 ${WORKDIR}/top.core.rbf ${DEPLOYDIR}/top.core.rbf
        fi
    fi
}
