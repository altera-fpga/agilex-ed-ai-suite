#! /bin/bash
# Run in Nios V Command Shell, Quartus Prime 22.4 or later

quartus_project=$1
qsys_file=$2
hex_file=$3
# Optional 4th arg: highest byte address of the Nios V RAM, used by elf2hex.
# Defaults to 0x1ffff (128 KB). agx3_soc_s2m passes 0xbfff for its 48 KB RAM.
hex_end="${4:-0x1ffff}"

usage()
{
    echo "Usage:"
    echo "    build.sh <quartus_project_file> <qsys_file> <destination_hex_file> [hex_end]"
}

if [ -z "$quartus_project" ]; then
    usage
    exit 1
fi

if [ -z "$qsys_file" ]; then
    usage
    exit 1
fi

if [ -z "$hex_file" ]; then
    usage
    exit 1
fi

if [ ! -f "$quartus_project" ]; then
    echo Quartus project file not found "$quartus_project"
    usage
    exit 1
fi

if [ ! -f "$qsys_file" ]; then
    echo qsys file not found "$qsys_file"
    usage
    exit 1
fi

# RAM size in bytes = highest address + 1 (hex_end is inclusive)
ram_size_bytes=$(( hex_end + 1 ))

# Export the bsp folder from the Quartus project, create the
# CMakeFiles.txt for the application, build the app, then
# build the stream_controller.hex binary, in the 'build' folder

# Force a clean rebuild so a stale bsp/build cache never relinks against an
# out-of-date memory map (e.g. after resizing the Nios V RAM).
# NOTE: only remove generated dirs. 'app' holds the application SOURCE.
rm -rf build bsp

niosv-bsp -c --quartus-project=$quartus_project --system=$qsys_file --type=hal bsp/settings.bsp

# WORKAROUND (Quartus 26.3): the msgdma HAL driver niosv-bsp copies in here has
# printf() calls that sit outside its own DMA_DEBUG/MSGDMA_DEBUG guards - the
# whole prefetcher poll/refill path plus three error paths. Referencing printf at
# all drags newlib's float-capable vfprintf, gdtoa/mprec and the libgcc
# soft-float helpers into the image: ~71 KB on a build whose own code is ~28 KB.
# That overflows agx3_soc_s2m's 48 KB Nios V RAM. The 26.1 driver had no printf
# calls at all. Rewrite them to alt_printf, which goes straight to alt_putchar
# and costs ~550 bytes.
#
# alt_printf only understands %x, %s, %c and %% (see bsp/HAL/src/alt_printf.c),
# and on an unknown conversion it neither prints nor consumes its argument, which
# would desync every later argument in the same call. So rewrite the %lu/%d/%p/
# %08lx specifiers in those calls to %x as well. Fields that used to print in
# decimal now print in hex.
#
# The rewrite is confined to lines holding an alt_printf( call so that the "%"
# modulo operators elsewhere in the driver are left alone. bsp/ is deleted and
# regenerated above on every run, so this re-applies to a pristine copy each time.
msgdma_src=bsp/drivers/src/altera_msgdma.c
if [ -f "$msgdma_src" ]; then
    patched=$(grep -cE "\bprintf[[:space:]]*\(" "$msgdma_src")
    sed -i -e 's/\bprintf[[:space:]]*(/alt_printf(/g' \
           -e '/alt_printf(/ s/%[-+ #0-9.]*\(hh\|h\|ll\|l\|z\|t\|j\)\?[diouxXp]/%x/g' \
           "$msgdma_src"
    echo "Applied msgdma printf workaround: rewrote $patched printf call(s) to alt_printf."
else
    echo "WARNING: $msgdma_src not found; skipped the msgdma printf workaround."
fi

niosv-app --bsp-dir=bsp --app-dir=app --srcs=app --elf-name=stream_controller.elf

# cmake dependency, version 3.14.10 or later. https://cmake.org/download/
cmake -B build -DCMAKE_BUILD_TYPE=Release app
cmake --build build

# ---- Size report ----
echo ""
echo "=== ELF size (text/data/bss) ==="
riscv32-unknown-elf-size build/stream_controller.elf

read -r text data bss dec hexval filename < <(riscv32-unknown-elf-size build/stream_controller.elf | tail -n 1)

# 'size' counts every section once, but .rwdata sits in RAM twice while
# hal.linker.enable_alt_load_copy_rwdata is on: once at its run address and
# again as the init image alt_load() copies from. Ask the linker where the image
# really ends so this report follows whatever the BSP settings produce.
read -r heap_hex stack_hex < <(riscv32-unknown-elf-nm build/stream_controller.elf | awk '
    $3 == "__alt_heap_start"    { h = $1 }
    $3 == "__alt_stack_pointer" { s = $1 }
    END { print h, s }')

echo ""
echo "Footprint (text+data+bss): $dec bytes"
if [ -n "$heap_hex" ] && [ -n "$stack_hex" ]; then
    heap_start=$((16#$heap_hex))
    stack_top=$((16#$stack_hex))
    echo "Image ends at:             $heap_start bytes (__alt_heap_start)"
    echo "Top of RAM:                $stack_top bytes (__alt_stack_pointer)"
    # Worst-case stack for this application is about 2400 bytes: the deepest
    # chain reachable through its function-pointer dispatch, with interrupts
    # landing on the same stack because hal.linker.enable_exception_stack is off.
    # The heap adds 32 bytes per inference request on top of that.
    stack_worst_case=2400
    if [ "$heap_start" -ge "$stack_top" ]; then
        echo "WARNING: image overflows the RAM by $((heap_start - stack_top)) bytes"
    elif [ "$((stack_top - heap_start))" -lt "$stack_worst_case" ]; then
        echo "WARNING: only $((stack_top - heap_start)) bytes for stack + heap, and the"
        echo "         worst-case stack alone is ~$stack_worst_case bytes"
    else
        echo "OK: $((stack_top - heap_start)) bytes for stack + heap"
    fi
    if [ "$stack_top" -ne "$ram_size_bytes" ]; then
        echo "WARNING: linker sees a $stack_top byte RAM but hex_end=$hex_end implies $ram_size_bytes"
    fi
else
    echo "RAM budget (hex_end=$hex_end): $ram_size_bytes bytes"
    echo "WARNING: no __alt_heap_start/__alt_stack_pointer in the ELF; cannot report"
    echo "         true headroom (section totals understate RAM use under alt_load)."
fi
echo "================================="
echo ""

elf2hex build/stream_controller.elf -b 0x0 -w 32 -e "$hex_end" -r 4 -o build/stream_controller.hex
cp build/stream_controller.hex $hex_file

exit 0
