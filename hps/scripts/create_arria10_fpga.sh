#! /bin/bash
set -o errexit

# Script to update the contents of a WIC Image
START_PATH=`pwd`
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# list of tools which are required. Not an exhastive list
required_tools=(mkimage)
for t in ${required_tools[@]}; do
    which $t >/dev/null
    if [[ $? != 0 ]]
    then
        echo "Error : You need \"$t\" installed"
        exit 11
    fi
done


if [ $# -lt 2 ]; then
    echo ./create_arria10_fpga.sh fpga_dir out_dir
    exit 1
fi

fpga_dir=$1
out_dir=$2

itb_file=$out_dir/fit_spl_fpga.itb

echo Info - ${FUNCNAME[0]}: Add FPGA Dir $fpga_dir

if [ ! -e $fpga_dir/top.periph.rbf ]; then
    echo Error : Failed to find $fpga_dir/top.periph.rbf
    exit 2
elif [ ! -e $fpga_dir/top.core.rbf ]; then
    echo Error : Failed to find $fpga_dir/top.core.rbf
    exit 2
fi

mkdir -p $out_dir

# Create the fit_spl_fpga.itb file
rm -f $out_dir/fit_temp.its

cat <<EOF > $out_dir/fit_temp.its
/dts-v1/;

/ {
	description = "FIT image with FPGA bistream";
	#address-cells = <1>;

	images {
		fpga-periph-1 {
			description = "FPGA peripheral bitstream";
			data = /incbin/("$fpga_dir/top.periph.rbf");
			type = "fpga";
			arch = "arm";
			compression = "none";
		};
		fpga-core-1 {
			description = "FPGA core bitstream";
			data = /incbin/("$fpga_dir/top.core.rbf");
			type = "fpga";
			arch = "arm";
			compression = "none";
		};
	};


	configurations {
		default = "config-1";
		config-1 {
			description = "Boot with FPGA early IO release config";
			fpga = "fpga-periph-1";
		};
	};
};
EOF

mkimage -E -f $out_dir/fit_temp.its $itb_file
if [ $? != 0 ]; then
    echo Error : Creating $itb_file
    exit 2
fi
rm $out_dir/fit_temp.its
