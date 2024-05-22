#!/bin/bash

# Define colors
GREEN="\e[1;32m"
RED="\e[1;31m"
YELLOW="\e[1;33m"
MUSTARD="\e[1;33m"
DEFAULT="\e[0m"

# Define variables
CLANG_VER="clang-r498229b"
CLANG_DIR="/home/ubuntu/tc/clang"

echo -e "${YELLOW}Using clang directory: $CLANG_DIR${DEFAULT}"

KERNEL_DIR=$PWD
Anykernel_DIR=$KERNEL_DIR/AnyKernel3/

echo -e "${MUSTARD}Choose the kernel version:${DEFAULT}"
echo -e "${MUSTARD}1. Beta${DEFAULT}"
echo -e "${MUSTARD}2. Stable${DEFAULT}"
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        KERNEL_VERSION="Beta"
        ;;
    2)
        KERNEL_VERSION="Stable"
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${DEFAULT}"
        exit 1
        ;;
esac

echo -e "${MUSTARD}Enter the name for the kernel zip file (without the extension): ${DEFAULT}"
read KERNEL_NAME

FINAL_ZIP="$KERNEL_VERSION-$KERNEL_NAME.zip"

BUILD_START=$(date +"%s")

export TARGET_KERNEL_CLANG_COMPILE=true
PATH="$CLANG_DIR/bin:${PATH}"

echo -e "${MUSTARD}***********************************************${DEFAULT}"
echo -e "${MUSTARD}          Compiling CalamityKernel                ${DEFAULT}"
echo -e "${MUSTARD}***********************************************${DEFAULT}"

mkdir -p out
make O=out ARCH=arm64 vendor/laurel_sprout-perf_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=$CLANG_DIR/bin/llvm- LLVM=1 LLVM_IAS=1 Image.gz-dtb dtbo.img || exit

echo -e "${MUSTARD}***********************************************${DEFAULT}"
echo -e "${MUSTARD}                Zipping Kernel                 ${DEFAULT}"
echo -e "${MUSTARD}***********************************************${DEFAULT}"

cp out/arch/arm64/boot/Image.gz-dtb $Anykernel_DIR
cp out/arch/arm64/boot/dtbo.img $Anykernel_DIR
cd $Anykernel_DIR
rm *.zip
zip -r9 $FINAL_ZIP * -x .git README.md *placeholder

echo -e "${MUSTARD}***********************************************${DEFAULT}"
echo -e "${MUSTARD}                 Cleaning up                   ${DEFAULT}"
echo -e "${MUSTARD}***********************************************${DEFAULT}"

cd ../
rm -rf $Anykernel_DIR/Image.gz-dtb
rm -rf $Anykernel_DIR/dtbo.img

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "${GREEN}Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.${DEFAULT}"