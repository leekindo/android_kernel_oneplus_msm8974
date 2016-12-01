#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear
cd `dirname "$0"`

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
DEFCONFIG="bacon_defconfig"
CMDLINE_EXT="androidboot.selinux=permissive"
CMDLINE_BASE="androidboot.hardware=bacon androidboot.bootdevice=msm_sdcc.1 ehci-hcd.park=3"
CMDLINE="$CMDLINE_BASE $CMDLINE_EXT"

# Vars
export CROSS_COMPILE="ccache ${HOME}/tools/arm-linux-gnueabihf-4.9/bin/arm-linux-gnueabihf-"
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=ab123321
export KBUILD_BUILD_HOST=kernel

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/tools"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"

# Functions
function clean_all {
	rm -rf $REPACK_DIR/out/*
	cd $KERNEL_DIR
	echo
	make clean && make mrproper
}

function make_kernel {
	echo
	make $DEFCONFIG
	make $THREAD
	cp -vr $ZIMAGE_DIR/zImage $REPACK_DIR/out
}


function make_dtb {
	$REPACK_DIR/dtbToolCM -2 -o $REPACK_DIR/out/dtb -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/
}

DATE_START=$(date +"%s")

echo -e "${green}"
echo "New Kernel Creation Script:"
echo -e "${restore}"

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid input, try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_kernel
		make_dtb
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid input, try again!"
		echo
		;;
esac
done

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
