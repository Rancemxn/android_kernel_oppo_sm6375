# OPPO K10x Kernel Source (Unofficial)

## 0. 准备环境

*   请使用 WSL/类 Unix 环境
*   以下操作在同一个命令行环境中进行

## 1. 准备系统依赖

*   以下依赖以 Ubuntu 22.04 为例：

```bash
sudo apt-get update
sudo apt-get install git wget automake flex lzop bison gperf build-essential zip curl zlib1g-dev g++-multilib gcc-multilib libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng maven libssl-dev pwgen libswitch-perl policycoreutils minicom libxml-sax-base-perl libxml-simple-perl bc libc6-dev-i386 libx11-dev lib32z-dev libgl1-mesa-dev xsltproc unzip device-tree-compiler python3 ccache git-lfs gnupg imagemagick libelf-dev libncurses5-dev libsdl1.2-dev gpart fuse2fs e2fsck-static icu-doc rsync adb fastboot libstdc++6 python-is-python3 gcc-aarch64-linux-gnu -y
```

*   如果在 `gcc-aarch64-linux-gnu` 安装失败，请尝试在命令中移除它，再次执行
*   然后手动安装 `gcc-aarch64-linux-gnu`，即：

```bash
sudo apt-get install gcc-aarch64-linux-gnu -y
```

## 2. 克隆源代码

*   准备一个空旷的文件夹，以及初始化 Android 内核结构：

```bash
mkdir -p ./OPPO_K10X_Source
cd ./OPPO_K10X_Source
export OPPO_K10X_RootPath=$(pwd)
mkdir -p kernel
```

### 获取内核

```bash
git clone https://github.com/Rancemxn/android_kernel_oppo_sm6375.git kernel/msm-5.4 --depth 1 -b main
```

### 获取驱动、设备树

```bash
git clone https://github.com/oppo-source/android_kernel_modules_and_devicetree_oppo_sm6375.git --depth 1 -b oppo/sm6375_u_14.0.0_k10x_5g temp_modules
```

## 3. 处理 Android 内核与驱动依赖关系

```bash
mv temp_modules/vendor ./vendor
rm -rf temp_modules
```

## 4. 准备编译器

### 创建文件夹，环境变量

```bash
mkdir compiler
cd $OPPO_K10X_RootPath/compiler
mkdir ccache-bin
```

### 获取 Clang

```bash
curl -fL "https://github.com/Rancemxn/android_kernel_oppo_sm6375/releases/download/tool-develop/linux-x86-refs_tags_android-14.0.0_r0.140-clang-r416183b.tar.gz" -o clang-r416183b.tar.gz --connect-timeout 30 --retry 5 --retry-delay 5
mkdir -p clang-12.0.5
tar -xzf clang-r416183b.tar.gz -C clang-12.0.5
rm clang-r416183b.tar.gz
```

### 获取 gcc

```bash
git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-9.3 aarch64-linux-android-9.3 --depth=1
git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 arm-linux-androideabi-4.9 --depth=1
```

### 配置ccache

```bash
cd ccache-bin
ln -sf "$(which ccache)" clang
ln -sf "$(which ccache)" clang++
ln -sf "$(which ccache)" aarch64-linux-android-gcc
ln -sf "$(which ccache)" aarch64-linux-android-g++
ln -sf "$(which ccache)" arm-linux-androideabi-gcc
ln -sf "$(which ccache)" arm-linux-androideabi-g++
```

## 5. 配置环境参数

```bash
cd $OPPO_K10X_RootPath/kernel/msm-5.4
cat <<EOF > env_vars.sh
export OPPO_K10X_RootPath=${OPPO_K10X_RootPath}
EOF
cd $OPPO_K10X_RootPath/kernel/msm-5.4/drivers/staging
ln -sf $OPPO_K10X_RootPath/vendor/qcom/opensource/wlan/qcacld-3.0 qcacld-3.0
ln -sf $OPPO_K10X_RootPath/vendor/qcom/opensource/wlan/qca-wifi-host-cmn qca-wifi-host-cmn
ln -sf $OPPO_K10X_RootPath/vendor/qcom/opensource/wlan/fw-api fw-api
ln -sf $OPPO_K10X_RootPath/vendor/qcom/opensource/wlan/utils utils
echo 'source "drivers/staging/qcacld-3.0/Kconfig"' >> $OPPO_K10X_RootPath/kernel/msm-5.4/drivers/staging/Kconfig
echo 'obj-$(CONFIG_QCA_CLD_WLAN) += qcacld-3.0/' >> $OPPO_K10X_RootPath/kernel/msm-5.4/drivers/staging/Makefile
sed -i 's|WLAN_ROOT := drivers/staging/qcacld-3.0|WLAN_ROOT := $(srctree)/$(src)|g' "$OPPO_K10X_RootPath/vendor/qcom/opensource/wlan/qcacld-3.0/Kbuild"
```

## 6. 编译

> **请忽略警告，除非你知道你在做什么**

```bash
cd $OPPO_K10X_RootPath/kernel/msm-5.4
./build.sh
```

*   命令完成后，Image输出在：`$OPPO_K10X_RootPath/kernel/msm-5.4/out/arch/arm64/boot` 下。驱动模块请查看 `$OPPO_K10X_RootPath/kernel/msm-5.4/out/all_modules`

> 你需要将驱动文件刷入到vendor/lib/modules/5.4-gki下。同时移除vendor/lib/modules与子目录5.4-gki下的所有非自编译文件