#!/bin/bash

# Board table for the CoreDLA SoC example designs.
#
# The Yocto image is built per MACHINE (see hps/yocto/run-build.sh), but the FPGA
# bitstream and its flash programming are per board. Board ids match the GSRD:
# the MACHINE name for gsrd-socfpga boards, and the design directory name for
# agilex5e-ed-gsrd and agilex3c-ed-gsrd boards.
#
# Source this file, then call board_lookup <board>, which sets:
#   BOARD             resolved board id
#   BOARD_MACHINE     Yocto MACHINE
#   BOARD_S2M_PLATFORM / BOARD_M2M_PLATFORM   directories under platform/
#   BOARD_FLASH_LOADER  quartus_pfg flash_loader (FPGA device), empty for Arria 10
#   BOARD_QSPI_DEVICE   quartus_pfg QSPI device, empty for Arria 10

# board|machine|s2m platform|m2m platform|flash_loader|qspi device
BOARD_TABLE=(
    "arria10|arria10|a10_soc_s2m|a10_soc_m2m||"
    "agilex7_dk_si_agi027fc|agilex7_dk_si_agi027fc|agx7_soc_s2m|agx7_soc_m2m|AGIB027R31B|MT25QU02G"
    "mk-a5e065bb32aes1|agilex5_mk_a5e065bb32aes1|agx5_soc_s2m|agx5_soc_m2m|A5ED065BB32AE6SR0|MT25QU128"
    # For now, the mk-a5e065bb32aea board uses the same Yocto MACHINE as mk-a5e065bb32aes1
    "mk-a5e065bb32aea|agilex5_mk_a5e065bb32aes1|agx5_soc_s2m_prq|agx5_soc_m2m_prq|A5ED065BB32AE4S|MT25QU128"
    "dk-a3w135bm16aea|agilex3|agx3_soc_s2m|agx3_soc_m2m|A3CW135BM16AE6S|QSPI512"
)

# Legacy names accepted in place of a board id
declare -A BOARD_ALIASES=(
    [agilex5_mk_a5e065bb32aes1]=mk-a5e065bb32aes1
)

function board_ids()
{
    local row
    for row in "${BOARD_TABLE[@]}"; do
        echo "${row%%|*}"
    done
}

function boards_for_machine()
{
    local row
    for row in "${BOARD_TABLE[@]}"; do
        IFS='|' read -r b m _ <<< "${row}"
        if [[ "${m}" == "${1}" ]]; then
            echo "${b}"
        fi
    done
    return 0
}

# board_lookup <board id | alias | machine with exactly one board>
function board_lookup()
{
    local name=$1 row b m s2m m2m fl qspi
    local -a matches

    if [[ -n "${BOARD_ALIASES[${name}]}" ]]; then
        echo "[WARNING] ${name} is deprecated; use board ${BOARD_ALIASES[${name}]}" >&2
        name=${BOARD_ALIASES[${name}]}
    fi

    for row in "${BOARD_TABLE[@]}"; do
        IFS='|' read -r b m s2m m2m fl qspi <<< "${row}"
        if [[ "${b}" == "${name}" ]]; then
            BOARD=${b}; BOARD_MACHINE=${m}
            BOARD_S2M_PLATFORM=${s2m}; BOARD_M2M_PLATFORM=${m2m}
            BOARD_FLASH_LOADER=${fl}; BOARD_QSPI_DEVICE=${qspi}
            return 0
        fi
    done

    matches=($(boards_for_machine "${name}"))
    if [[ ${#matches[@]} -eq 1 ]]; then
        board_lookup "${matches[0]}"
        return $?
    elif [[ ${#matches[@]} -gt 1 ]]; then
        echo "Error: machine ${name} is used by several boards, select one of: ${matches[*]}" >&2
        return 1
    fi

    echo "Error: unknown board ${name}. Valid boards: $(board_ids | tr '\n' ' ')" >&2
    return 1
}
