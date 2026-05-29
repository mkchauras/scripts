#! /bin/bash

KVER=$(make kernelrelease)
make moudles_install
sudo update-initramfs -c -k $KVER -b $(pwd)
