#!/bin/bash

if [ $(whoami) != root ]; then
	echo "This script needs to be run as root."
	exit 1
fi

if [ $# -ne 1 ]; then
	echo "$0 kernelrelease"
	exit 1
fi

if [ ! -f /boot/grub2/grub.cfg ]; then
	echo "/boot/grub2/grub.cfg does not seem to be mounted, trying /boot/grub/grub.cfg"
## Some systems are using "grub" instead of "grub2"
if [ ! -f /boot/grub/grub.cfg ]; then
	echo "Can't find grub.cfg in /boot/grub2/ OR /boot/grub/"
	exit 1
fi

if [ ! -x $(which nproc) ]; then
	MAKEOPTIONS="-j$(( $(nproc) +1 ))"
else
	MAKEOPTIONS="-j$(( $(grep -c processor /proc/cpuinfo) +1 ))"
fi

KERNEL=${1##*/}

LOGFILE=/tmp/updatekernel-$KERNEL
>$LOGFILE

echo "### Setting kernel release $KERNEL"
eselect kernel set $KERNEL &>> $LOGFILE
if [ $? -ne 0 ]; then
	echo "Failed to set kernel release"
	exit 1
fi

echo "### Changing directory and copying previous config."
echo "Using kernel config: /boot/config-$(uname -r)"
cd /usr/src/linux &>> $LOGFILE
cp /boot/config-$(uname -r) /usr/src/linux/.config  &>> $LOGFILE
if [ $? -ne 0 ]; then
	echo "Failed to copy previous kernel config"
	exit 1
fi
echo "### Building and installing kernel"
make oldconfig | tee -a $LOGFILE
( make $MAKEOPTIONS && \
	make modules_install && \
	make install
) &>> $LOGFILE

if [ $? -ne 0 ]; then
	echo "Build failed... Please advise"
	exit 1
fi

echo "### Build complete. Rebuilding kernel modules"
emerge @module-rebuild &>> $LOGFILE
if [ $? -ne 0 ];then
	echo "Rebuilding kernel modules failed"
	exit 1
fi

echo "### Updating grub2 config"
grub2-mkconfig -o /boot/grub2/grub.cfg &>> $LOGFILE
if [ $? -ne 0 ];then
	echo "'grub2-mkconfig -o /boot/grub2/grub.cfg' failed, trying 'grub-mkconfig -o /boot/grub/grub.cfg' instead."
## Some systems are using "grub" instead of "grub2".
grub-mkconfig -o /boot/grub/grub.cfg &>> $LOGFILE
if [ $? -ne 0 ];then
	echo "Updating grub config failed"
	exit 1
fi

echo "### All done!"
