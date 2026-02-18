#!/bin/bash

export OPPO_K10X_RootPath=/home/OPPO_K10X_Source
export OPPO_K10X_KernelPath=/home/OPPO_K10X_Source/kernel/msm-5.4
export OPPO_K10X_Compiler=/home/OPPO_K10X_Source/compiler

export ARCH="arm64"
export SUBARCH="arm64"
export PATH="$OPPO_K10X_Compiler/clang-11.0.2/bin:$OPPO_K10X_Compiler/aarch64-linux-android-4.9/bin:$OPPO_K10X_Compiler/arm-linux-androideabi-4.9/bin:$PATH"
export CC="ccache clang"
export CROSS_COMPILE="aarch64-linux-android-"
export CROSS_COMPILE_ARM32="arm-linux-androideabi-"
export TRIPLE="aarch64-linux-gnu-"
export CLANG_TRIPLE="aarch64-linux-gnu-"
export CLANG_PATH=$OPPO_K10X_Compiler/clang-11.0.2/bin
export USE_CCACHE=1

make O=out CC="ccache clang" sm6375_defconfig
make O=out CC="ccache clang" -j$(nproc)