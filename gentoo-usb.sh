#!/bin/bash

# This script will turn your USB-drive into a bootable drive from which you can boot Gentoo Linux.
# I tried running the script supplied in https://wiki.gentoo.org/wiki/LiveUSB/Guide, 
# but I ran into some problems, so I followed the instructions manually, and came up with this.

# I originally intended for this to be run on an Ubuntu machine, which is where I have tested this.
# However, I believe it's flexible enough to run on any Linux system.

# Requirements:
# You downloaded the Gentoo installation media from https://www.gentoo.org/downloads/ or one of the mirror sites.
# The file should have the file extension .iso
# You also have a precompiled Master Boot Record on your computer, it should look something like this: *mbr.bin


# You have to run this as root.


# WARNING! THIS SCRIPT DELETES ALL DATA ON THE SPECIFIED DRIVE!
# NEEDLESS TO SAY, IF YOU ACCIDENTALLY SPECIFY THE WRONG DRIVE, IT WILL DELETE THE DATA THERE AS WELL!
# PLEASE USE WITH CAUTION!

# Making sure we are root:
if [[ $(whoami) != "root" ]]
then
	echo "You need to be root to run this script."
	exit
fi


# Getting user input. These flags are required:
# -t: Target partition. Something like /dev/sdb1, note that the partition number is required as well.
# -m: MBR-binary. The exact path to the precompiled Master Boot Record. For me, it was /usr/lib/syslinux/mbr/mbr.bin
# -i: ISO-file. Exact path to the ISO image that you downloaded

while getopts t:m:i: flag
do
    case "${flag}" in
        t) target_partition=${OPTARG};;
        m) mbr_path=${OPTARG};;
        i) iso_path=${OPTARG};;
    esac
done

usage="Usage:
./gentoo-usb.sh -t TARGET_PARTITION -m MBR_PATH -i ISO_PATH
-t: Target partition. Something like /dev/sdb1, note that the partition number is required as well.
-m: MBR-binary. The exact path to the precompiled Master Boot Record. For me, it was /usr/lib/syslinux/mbr/mbr.bin
-i: ISO-file. Exact path to the ISO image that you downloaded
Example:
./gentoo-usb.sh -t /dev/sdc1 -m /usr/lib/syslinux/mbr/mbr.bin -i /home/alice/Downloads/install-amd64-minimal-20210425T214502Z.iso"
if [[ "$target_partition" == ""  ||  "$mbr_path" == ""  ||  "$iso_path" == "" ]]
then
	echo "$usage"
	exit
fi


# Sanity checking user input.

if [[ "$target_partition" != /dev/[a-z]*[1-9]* ]]
then
	echo "Please enter a valid partition name. Should be something like: /dev/sdb1"
	exit
fi
if [[ "$mbr_path" != *mbr* ]]
then
	echo "Please provide a valid MBR file. Should be something like /usr/lib/syslinux/mbr/mbr.bin"
	exit
fi
if [[ "$iso_path" != *.iso ]]
then
	echo "Please provide a valid ISO path. Should be something like /home/alice/Downloads/install-amd64-minimal-20210425T214502Z.iso"
	exit
fi


# Making sure that the provided parameters exist.

if ! test -e $target_partition 
then
	echo "$target_partition not found! Exiting."
	exit
fi
if ! test -e $mbr_path 
then
	echo No MBR file found at $mbr_path! Exiting.
	exit
fi
if ! test -e $iso_path 
then
	echo No ISO file found at $iso_path! Exiting.
	exit
fi



# Getting (for example) /dev/sdb from /dev/sdb2
usb_device=$(echo $target_partition | sed 's/[0-9]//g')


# Creating the FAT file system on the drive.
# WARNING! This deletes all data!
partition_size=$(lsblk -bno SIZE $target_partition | head -1)
if [ $partition_size -lt 4000000000 ]
then
	mkfs.fat -F 16 $target_partition
else
	mkfs.fat -F 32 $target_partition
fi


# Copying the MBR binary onto the USB device.
dd if=$mbr_path of=$usb_device


# Mounting the ISO onto our file system
mkdir -p /mnt/cdrom
mount -o loop,ro -t iso9660 $iso_path /mnt/cdrom

# Mounting the newly formatted USB drive onto our file system
mkdir -p /mnt/usb
mount -t vfat $target_partition /mnt/usb

# Copying the files from the minimal installation CD to the LiveUSB
cp -r /mnt/cdrom/* /mnt/usb
mv /mnt/usb/isolinux/* /mnt/usb
mv /mnt/usb/isolinux.cfg /mnt/usb/syslinux.cfg
rm -rf /mnt/usb/isolinux*
mv /mnt/usb/memtest86 /mnt/usb/memtest

# Unmounting the ISO image
umount /mnt/cdrom

# Adjusting the bootloader configuration
# The slowusb parameter will introduce some extra delays before attempting to mount the filesystem. 
# This is needed to allow the USB drive to settle upon detection.
sed -i -e "s:cdroot:cdroot slowusb:" -e "s:kernel memtest86:kernel memtest:" /mnt/usb/syslinux.cfg

# Unmounting the USB drive
umount /mnt/usb

# Installing the syslinux bootloader onto the USB drive
syslinux $target_partition
