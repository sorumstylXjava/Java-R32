#!/bin/bash

ROOT_DIR=$(pwd)
CLANG_DIR="${ROOT_DIR}/clang"
OUT_DIR="${ROOT_DIR}/out"
ANYKERNEL_DIR="${ROOT_DIR}/AnyKernel3"

if [ ! -d "${CLANG_DIR}" ]; then
    echo "--- Cloning LineageOS Clang ---"
    git clone --depth=1 https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b -b lineage-19.1 "${CLANG_DIR}"
fi

export PATH="${CLANG_DIR}/bin:${PATH}"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Java"
export KBUILD_BUILD_HOST="Java_nih_deks"

mkdir -p ${OUT_DIR}

echo "--- Generating Defconfig ---"
make O=out ARCH=arm64 rosemary_defconfig

make -j$(nproc --all) O=out \
    ARCH=arm64 \
    CC=clang \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    LD=ld.lld \
    AR=llvm-ar \
    AS=llvm-as

if [ -f "${OUT_DIR}/arch/arm64/boot/Image.gz" ]; then
    echo "--- BUILD SUCCESSFUL"
else
    echo "--- BUILD FAILED"
    exit 1
fi
