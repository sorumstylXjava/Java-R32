#!/bin/bash
ROOT_DIR=$(pwd)
CLANG_DIR="${ROOT_DIR}/clang"
OUT_DIR="${ROOT_DIR}/out"

if [ ! -d "${CLANG_DIR}" ]; then
    echo "--- Cloning LineageOS Clang for Rosemary ---"
    git clone --depth=1 https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b -b lineage-19.1 "${CLANG_DIR}"
fi

export PATH="${CLANG_DIR}/bin:${PATH}"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Java"
export KBUILD_BUILD_HOST="Java_nih_deks"

mkdir -p ${OUT_DIR}

echo "--- Generating Rosemary Defconfig ---"
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
    AS=llvm-as \
    LLVM=1 \
    LLVM_IAS=1

if [ -f "${OUT_DIR}/arch/arm64/boot/Image.gz-dtb" ]; then
    echo "--- BUILD SUCCESSFUL ---"
else
    echo "--- BUILD FAILLED---"
    exit 1
fi
