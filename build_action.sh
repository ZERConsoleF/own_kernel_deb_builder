#!/usr/bin/env bash

export VERSION=$(grep 'Kernel Configuration' < config | awk '{print $3}')
export VERCODE=v6.x

# add deb-src to sources.list
sed -i "/deb-src/s/# //g" /etc/apt/sources.list

# install dep
apt update
apt upgrade -y
apt install make gcc bc -y
apt install pkg-config libncurses-dev -y
apt install flex -y
apt install bison -y
apt-get install -y libncurses5-dev flex bison libssl-dev
apt-get install -y wget curl
apt install fakeroot -y
apt-get install  dpkg-dev -y
apt install rsync kmod cpio -y
apt-get install libelf-dev -y
apt install -y git wget curl dwarves build-essential fakeroot bc kmod cpio libncurses5-dev libgtk2.0-dev libglib2.0-dev libglade2-dev libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev dpkg-dev autoconf libdw-dev cmake zstd
apt install -y wget xz-utils make gcc flex bison dpkg-dev bc rsync kmod cpio libssl-dev zsh
apt install -y git dwarves build-essential fakeroot bc kmod cpio libncurses5-dev libgtk2.0-dev libglib2.0-dev libglade2-dev libncurses-dev gawk flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev dpkg-dev autoconf libdw-dev cmake zstd gzip
apt build-dep -y linux
apt upgrade -y

# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

# download kernel source
wget http://www.kernel.org/pub/linux/kernel/$VERCODE/linux-"$VERSION".tar.xz
tar -xf linux-"$VERSION".tar.xz
cd linux-"$VERSION" || exit

# copy config file
cp ../config .config

# disable DEBUG_INFO to speedup build
scripts/config --disable DEBUG_INFO

# extra build argument
export EXTRA_ARGS=""

# apply patches
# shellcheck source=src/util.sh
source ../patch.d/*.sh

# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
echo "This is make args: make -j\"$CPU_CORES\" bindeb-pkg $EXTRA_ARGS"
time nice make -j"$CPU_CORES" bindeb-pkg $EXTRA_ARGS

# move deb packages to artifact dir
cd ..
echo "Output Builder Items"
mkdir "artifact-deb"
mv ./*.deb artifact-deb/
tar -zcvf ./artifact-deb/linux-certs.tar.gz ./linux-"$VERSION"/certs

# move build environment to artifact dir
echo "Packing Build Env"
mkdir "artifact-env"
tar -zcvf ./artifact-env/linux-"$VERSION"-MakeEnv.tar.gz ./linux-"$VERSION"
echo "All Done."
exit 0
