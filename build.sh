#!/bin/bash
ROOT_DIR=$(pwd)
CLANG_DIR="${ROOT_DIR}/clang"
OUT_DIR="${ROOT_DIR}/out"

if [ ! -d "${CLANG_DIR}" ]; then
    echo "--- Cloning LineageOS Clang for Rosemary ---"
    git clone --depth=1 https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b -b lineage-19.1 "${CLANG_DIR}"
fi

# Pastiin PATH absolut biar mantap
export PATH="${CLANG_DIR}/bin:${PATH}"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Java"
export KBUILD_BUILD_HOST="Java_nih_deks"

# Bersihin out lama biar ga nyampah kalo di lokal
mkdir -p ${OUT_DIR}

echo "--- Generating Rosemary Defconfig ---"
make O=out ARCH=arm64 rosemary_defconfig

echo "--- Memulai Siksaan Rosemary ---"
# Pake LLVM=1 itu udah otomatis manggil llvm-nm, llvm-objcopy, dll.
# Kita cuma perlu define CC, LD, dan CROSS_COMPILE-nya aja.
make -j$(nproc --all) O=out \
    ARCH=arm64 \
    CC=clang \
    LD=ld.lld \
    AR=llvm-ar \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    LLVM=1 \
    LLVM_IAS=1 \
    V=0 # Set V=1 kalo mau liat log super detail pas error

if [ -f "${OUT_DIR}/arch/arm64/boot/Image.gz-dtb" ]; then
    echo "--- BUILD SUCCESSFUL ---"
else
    echo "--- BUILD FAILLED ---"
    exit 1
fi
