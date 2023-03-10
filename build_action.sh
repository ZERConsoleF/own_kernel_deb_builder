#!/usr/bin/env bash

export VERSION=$(grep 'Kernel Configuration' < config | awk '{print $3}')
export VERCODE=v6.x

# add deb-src to sources.list
sed -i "/deb-src/s/# //g" /etc/apt/sources.list

# install dep
apt update
apt install -y wget xz-utils make gcc flex bison dpkg-dev bc rsync kmod cpio libssl-dev zsh
apt install -y git dwarves build-essential fakeroot bc kmod cpio libncurses5-dev libgtk2.0-dev libglib2.0-dev libglade2-dev libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev dpkg-dev autoconf libdw-dev cmake zstd
apt build-dep -y linux

# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

# download kernel source
wget http://www.kernel.org/pub/linux/kernel/$VERCODE/linux-"$VERSION".tar.xz
tar -xf linux-"$VERSION".tar.xz
cd linux-"$VERSION" || exit

# copy config file
cp ../config .config

# disable DEBUG_INFO to speedup build
#scripts/config --disable DEBUG_INFO

# extra build argument
export EXTRA_ARGS=""

# apply patches
# shellcheck source=src/util.sh
source ../patch.d/*.sh

# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
echo "This is make args: make -j\"$CPU_CORES\" bindeb-pkg $EXTRA_ARGS"
make -j"$CPU_CORES" bindeb-pkg $EXTRA_ARGS

# move deb packages to artifact dir
cd ..
mkdir "artifact"
mv ./*.deb artifact/
