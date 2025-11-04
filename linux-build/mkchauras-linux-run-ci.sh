#!/bin/bash

usage() {
    echo "Usage: $0 <LINUX_DIR> <DEFCONFIG>"
    echo
    echo "Arguments:"
    echo "  LINUX_DIR   Path to Linux source directory (e.g. ~/src/linux)"
    echo "  DEFCONFIG   Kernel defconfig to use (e.g. ppc64le_guest_defconfig)"
    echo
    echo "Example:"
    echo "  $0 ~/src/linux ppc64le_guest_defconfig"
    exit 1
}

# Show help if requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Require exactly 2 arguments
if [[ $# -ne 2 ]]; then
    echo "Error: Missing arguments."
    usage
fi

set -xe
linux_dir="$1"
defconfig="$2"

j=$(nproc)

# ci-scripts src
ci_scripts_dir="$HOME/src/ci-scripts"

#
# Variables for build step
#
build_make_dir="$ci_scripts_dir/build"
# command for build, this is interpreted by $build_make_dir/Makefile
build_make_cmd="make kernel@ppc@fedora SRC=$linux_dir JFACTOR=$j DEFCONFIG=$defconfig"
# This is where build step will output the built kernel artifacts
build_kernel_dir=$build_make_dir/output/latest-kernel


#
# Variables for root disk creation step
#
image_name="fedora41-cloudimg-ppc64le.qcow2"
disk_make_dir="$ci_scripts_dir/root-disks"
disk_make_cmd="make $image_name"

#
# Variables for boot step
#
boot_script_dir=$ci_scripts_dir/scripts/boot
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
# qemu boot step
#
KBUILD_OUTPUT=$build_kernel_dir $boot_script

