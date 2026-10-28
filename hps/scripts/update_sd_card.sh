#! /bin/bash

# Script to update the contents of a WIC Image
START_PATH=`pwd`
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# list of tools which are required. Not an exhastive list
required_tools=(mkfs.ext4 fakeroot mkimage mcopy parted mdel cpio)

for t in ${required_tools[@]}; do
    which $t >/dev/null
    if [[ $? != 0 ]]
    then
        echo "Error : You need \"$t\" installed"
        tool_error=1
    fi
done

# if tool_error is not empty then we had an error
if [ ! -z $tool_error ]; then
    exit 1
fi

get_partition_info() # parameters: partition_type, src_image_file
{
    part_info=$(parted -s $2 'unit b print' | grep $1)
    if [[ $? != 0 ]]
    then
	echo "Failed to get information about $2 partition from image file $1"
	exit 1
    fi

    # Find start and end sector of fat
    part_num=$(echo $part_info | awk '{print $1}')
    part_start=$(echo $part_info | awk '{print $2}')
    part_end=$(echo $part_info | awk '{print $3}')
    part_start=${part_start%?}
    let seek=$part_start/512
    part_end=${part_end%?}
    let part_size=$part_end-$part_start+1
    let part_sectors=$part_size/512
}

update_fat_partition() # parameters: src image file, new contents
{
    echo "*** Update FAT partition with rbf, dtb, kernel files"
    image_file=$1
    shift

    if [[ ! -f $image_file ]]; then
    	echo "Cannot open image file $image_file"
	    exit 2
    fi

    image_dir="$(cd "$(dirname "${image_file}")" && pwd)"
    fatimage_file=$image_dir/fatimage

    get_partition_info fat32 $image_file
    fat_part_offset=$seek

    # copy out partition
    rm -f $fatimage_file
    [[ -e $fatimage_file ]] && echo "Error: Unable to remove $fatimage_file" && exit 1
    dd if=$image_file bs=512 skip=$seek count=$part_sectors of=$fatimage_file

    for filename in "$@"
    do
        mdel -i $fatimage_file ::/`basename $filename` > /dev/null 2>&1
        mcopy -i $fatimage_file $filename ::/
    done
    
    mdir -i $fatimage_file

    dd conv=notrunc if=$fatimage_file bs=512 of=$image_file seek=$fat_part_offset
    
    rm -rf $fatimage_file
    [[ -e $fatimage_file ]] && echo "Error: Unable to remove $fatimage_file" && exit 1
}

extend_ext4_partition() # parameters: src file image, new size
{
    image_file=$1
    let new_size_sectors=$2*1024*2
    let new_size=$new_size_sectors*512
    get_partition_info ext4 $image_file

    echo "ext4 partition size $part_size (Sectors $part_sectors) New size $new_size (Sectors $new_size_sectors) $part_end"
    
    if [ $new_size_sectors -gt $part_sectors ]
    then
	echo "Extending image file..."
	let increase=$new_size_sectors-$part_sectors
	dd if=/dev/zero bs=512 count=$increase >> $image_file
	echo "Extending partition..."
	let new_end=$part_start+$new_size-1
    parted --script ${image_file} resizepart 3 ${new_end}B
    fi
}

update_ext4_partition() # parameters: src image file, cpio in file, cpio out file, rootfs addition dir
{
    echo "*** Update EXT4 partition with rootfs files"
    image_file=$1
    cpio_in_file=$2
    cpio_out_file=$3
    rootfs_additions_dir=$4
    get_partition_info ext4 $image_file
    ext4_part_offset=$seek

    if [[ ! -f $image_file ]]; then
        echo "Cannot open image file $image_file"
        exit 3
    elif [[ ! -f $cpio_in_file ]]; then
        echo "Cannot open cpio file $cpio_in_file"
        exit 4
    elif [[ ! -d $rootfs_additions_dir ]]; then
        echo "Cannot open rootfs_additions_dir $rootfs_additions_dir"
        exit 5
    fi

    image_dir="$(cd "$(dirname "${image_file}")" && pwd)"
    ext4image_file=$image_dir/ext4image
    rm -f $ext4image_file
    [[ -e $ext4image_file ]] && echo "Error: Unable to remove $ext4image_file" && exit 1
    dd of=$ext4image_file bs=512 seek=$part_sectors count=0
    if [[ $? != 0 ]]; then
        echo "Could not allocate space for ext4 image file"
        exit 6
    fi

    # extract rootfs
    rootfs_dir=$image_dir/rootfs
    rm -rf $rootfs_dir
    [[ -e $rootfs_dir ]] && echo "Error: Unable to remove $rootfs_dir" && exit 1
    mkdir -p $rootfs_dir
    pushd $rootfs_dir
        cpio -i -F $cpio_in_file
    popd

    chmod -R u+r $rootfs_dir

    # add new files
    cp -R $rootfs_additions_dir/* $rootfs_dir/
    
    # create a cpio file with the changes
    pushd $rootfs_dir
        find . | cpio --owner root:root -H newc -o > $cpio_out_file
    popd
    
    # Create a new EXT4 image from the file set
    fakeroot -- mkfs.ext4 -d $rootfs_dir $ext4image_file
    if [[ $? != 0 ]]; then
	    echo "Error : Failed to create new ext4 root filesystem"
	    exit 7
    fi

    dd conv=notrunc if=$ext4image_file bs=512 of=$image_file seek=$ext4_part_offset

    # Clean-up
    rm -rf $rootfs_dir
    rm -rf $ext4image_file
    if [[ -e $rootfs_dir || -e $ext4image_file ]]
    then
        echo "Error: Unable to clean up" && exit 1
    fi
}

###############################################################################################
update_rootfs()
{
    update_ext4_partition $out_dir/$wic_file $in_dir/$cpio_file $out_dir/$cpio_file $rootfs_dir
}

update_agilex3_fpga()
{
    ${SCRIPT_PATH}/create_agilex3_fpga.sh $fpga_dir $out_dir $out_dir/$hex_file $BOARD
    if [ $? != 0 ]; then
        exit 2
    fi
}

update_agilex5e_fpga()
{
    ${SCRIPT_PATH}/create_agilex5e_fpga.sh $fpga_dir $out_dir $out_dir/$hex_file $BOARD
    if [ $? != 0 ]; then
        exit 2
    fi
}

update_agilex7_dk_si_agi027fc_fpga()
{
    ${SCRIPT_PATH}/create_agilex7_dk_si_agi027fc_fpga.sh $fpga_dir $out_dir $out_dir/$hex_file
    if [ $? != 0 ]; then
        exit 2
    fi
}

update_arria10_fpga()
{ 
    echo Info - ${FUNCNAME[0]}: Add FPGA Dir $fpga_dir
    ${SCRIPT_PATH}/create_arria10_fpga.sh $fpga_dir $out_dir
    if [ $? != 0 ]; then
        exit 2
    fi

    # Add fit_spl_fpga.itb to FAT partition
    update_fat_partition $out_dir/$wic_file $out_dir/fit_spl_fpga.itb
} 

###############################################################################################
check_products()
{
    if [ ! -e $in_dir/$wic_file ]; then
        echo Error : $in_dir/$wic_file does not exist
        exit 4
    fi
    if [ ! -e $in_dir/$cpio_file ]; then
        echo Error : $in_dir/$cpio_file does not exist
        exit 4
    fi
    if [ ! -z $hex_file  ] && [ ! -e $in_dir/$hex_file ]; then
        echo Error : $in_dir/$hex_file does not exist
        exit 4
    fi

    echo "Info : Copying ${wic_file}..."
    cp $in_dir/$wic_file $out_dir/$wic_file
#    cp $in_dir/$cpio_file $out_dir/$cpio_file # Don't copy as done if the rootfs is updated
    if [ ! -z $hex_file ]; then
        echo "Info : Copying ${hex_file}..."
        cp $in_dir/$hex_file $out_dir/$hex_file
    fi
}
###############################################################################################
usage()
{
    echo "Usage: $0 -w <wic image> -o <output directory> [-f <fpga dir> -r <rootfs dir> -b <board>]"
    echo "  -b selects the board when -f is set. Defaults to mk-a5e065bb32aes1 for the Agilex 5 wic image,"
    echo "     which is shared by all Agilex 5 boards."
    echo "     Boards: $(board_ids | tr '\n' ' ')"
    exit 1
}

source ${SCRIPT_PATH}/../boards.sh

while getopts "w:f:r:o:b:hx" optname; do
    case "$optname" in
        h)
            usage
            exit 1
            ;;
        w)
            wic_image=$OPTARG
            ;;
        f)
            fpga_dir=$OPTARG
            ;;
        r)
            rootfs_dir=$OPTARG
            ;;
        o)
            out_dir=$OPTARG
            ;;
        b)
            board=$OPTARG
            ;;
        x)
            set -x
            ;;
    esac
done
shift "$(($OPTIND -1))"

# Validate that the wic image is valid
if [ -z $wic_image ]; then
    echo Error: Please specific wic image using -w
    usage
    exit 1
fi

if [ ! -e $wic_image ]; then
    echo Error: specified wic image does not exists.
    exit 1
fi

# Find the machine name
if [[ $wic_image = *coredla-image-arria10.wic ]]; then
    machine=arria10
    wic_file=coredla-image-arria10.wic
    cpio_file=coredla-image-arria10.cpio
elif [[ $wic_image = *coredla-image-agilex7_dk_si_agi027fc.wic ]]; then
    machine=agilex7_dk_si_agi027fc
    wic_file=coredla-image-agilex7_dk_si_agi027fc.wic
    cpio_file=coredla-image-agilex7_dk_si_agi027fc.cpio
    hex_file=u-boot-spl-dtb.hex
elif [[ $wic_image = *coredla-image-agilex5_mk_a5e065bb32aes1.wic ]]; then
    machine=agilex5_mk_a5e065bb32aes1
    wic_file=coredla-image-agilex5_mk_a5e065bb32aes1.wic
    cpio_file=coredla-image-agilex5_mk_a5e065bb32aes1.cpio
    hex_file=u-boot-spl-dtb.hex
elif [[ $wic_image = *coredla-image-agilex3.wic ]]; then
    machine=agilex3
    wic_file=coredla-image-agilex3.wic
    cpio_file=coredla-image-agilex3.cpio
    hex_file=u-boot-spl-dtb.hex
else
    echo Error: Failed to determine machine from wic_image [$wic_image]
    exit 1
fi
echo Info : Detected machine is $machine

# The board selects the FPGA device; only needed when programming the FPGA
if [ ! -z $fpga_dir ]; then
    board_lookup ${board:-$machine} || exit 1
    if [[ "${BOARD_MACHINE}" != "${machine}" ]]; then
        echo Error: board ${BOARD} uses machine ${BOARD_MACHINE}, but the wic image is for ${machine}
        exit 1
    fi
    echo Info : Selected board is $BOARD
fi

in_dir=`dirname $wic_image`

# If out_dir not specified us the current run directory
if [ -z $out_dir ]; then
    out_dir=`pwd`
else
    mkdir -p $out_dir
fi

# Check all products and copy to output directory
check_products

# Update the fpga
if [ ! -z $fpga_dir ]; then
    if [ $machine == arria10 ]; then
        update_arria10_fpga
    elif [ $machine == agilex7_dk_si_agi027fc ]; then
        update_agilex7_dk_si_agi027fc_fpga
    elif [ $machine == agilex5_mk_a5e065bb32aes1 ]; then
        update_agilex5e_fpga
    elif [ $machine == agilex3 ]; then
        update_agilex3_fpga
    else
        echo Error: Invalid Machine - $machine
        exit 5
    fi
fi

# Update the rootfs
if [ ! -z $rootfs_dir ]; then
    update_rootfs
fi
