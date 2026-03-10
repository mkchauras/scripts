#!/bin/bash
set -xe

j=`nproc`

HOME=/home/mkchauras

# linux src
linux_dir="$HOME/src/linux"
# ci-scripts src
ci_scripts_dir="$HOME/src/ci-scripts"

#
# Variables for build step
#
build_make_dir="$ci_scripts_dir/build"
# command for build, this is interpreted by $build_make_dir/Makefile
build_make_cmd="make LLVM=1 kernel@ppc64le@fedora SRC=$linux_dir JFACTOR=$j DEFCONFIG=ppc64le_guest_defconfig"
# This is where build step will output the built kernel artifacts
build_kernel_dir=$build_make_dir/output/latest-kernel


#
# Variables for root disk creation step. This root disk will be used during
# boot. Look into ci-scripts/root-disks/Makefile for reference on adding newer
# distor support
#
image_name="ubuntu22.04-cloudimg-ppc64el.qcow2"
disk_make_dir="$ci_scripts_dir/root-disks"
disk_make_cmd="make $image_name"

#
# Variables for boot step
#
boot_script_dir=$ci_scripts_dir/scripts/boot
# the boot command. This will eventually pass all args to lib/qemu.py. Check that files
# arg parser snippet to see supported flags. There are also wrappers over qemu.py present
# in $boot_script_dir/*
boot_script="$boot_script_dir/qemu-pseries --cpu POWER10 --cloud-image $image_name --interactive"

#
# build step
#
cd $build_make_dir
$build_make_cmd
 
#
# root disk creation step
#
pushd $disk_make_dir
./install-deps.sh
make cloud-init-user-data.img
$disk_make_cmd

popd

#
# qemu boot step. KBUILD_OUTPUT needs to be set as it is interpreted by boot
# scripts
#
KBUILD_OUTPUT=$build_kernel_dir $boot_script
