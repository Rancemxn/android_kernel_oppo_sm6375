#!/bin/bash

if [ -z "$OPPO_K10X_RootPath" ]; then
    CONF_FILE="$(dirname "$(readlink -f "$0")")/env_vars.sh"
    if [ -f "$CONF_FILE" ]; then
        source "$CONF_FILE"
    fi
fi

if [ -z "$OPPO_K10X_RootPath" ]; then
    echo "OPPO_K10X_RootPath is not defined."
    exit 1
fi

export ARCH="arm64"
export SUBARCH="arm64"
export PATH="$OPPO_K10X_RootPath/compiler/ccache-bin:$OPPO_K10X_RootPath/compiler/clang-12.0.5/bin:$OPPO_K10X_RootPath/compiler/aarch64-linux-android-9.3/bin:$OPPO_K10X_RootPath/compiler/arm-linux-androideabi-4.9/bin:$PATH"
export CROSS_COMPILE="aarch64-linux-android-"
export CROSS_COMPILE_ARM32="arm-linux-androideabi-"
export CLANG_TRIPLE="aarch64-linux-gnu-"
export CLANG_PATH=$OPPO_K10X_RootPath/compiler/clang-12.0.5/bin

make O=out CC="clang" LLVM=1 sm6375_defconfig
make O=out CC="clang" LLVM=1 -j$(nproc)


ALL_MODULES_DIR="$OPPO_K10X_RootPath/kernel/msm-5.4/out/all_modules"
KERNEL_RELEASE=$(cat out/include/config/kernel.release)
FAKE_ROOT="$OPPO_K10X_RootPath/kernel/msm-5.4/out/fake_root"
FAKE_MOD_DIR="$FAKE_ROOT/lib/modules/$KERNEL_RELEASE"
mkdir -p "$ALL_MODULES_DIR"
mkdir -p "$FAKE_MOD_DIR"
find . -name "*.ko" -exec cp {} "$FAKE_MOD_DIR/" \;
cd "$FAKE_MOD_DIR"
mv wlan.ko qca_cld3_wlan.ko
ls -1 *.ko > modules.load
cd "$(dirname "$0")"
depmod -b "$FAKE_ROOT" "$KERNEL_RELEASE"
mv "$FAKE_MOD_DIR/"* "$ALL_MODULES_DIR/"
rm -rf "$FAKE_ROOT"