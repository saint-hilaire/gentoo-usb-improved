
## ABOUT
This script will turn your USB-drive into a bootable drive from which you can boot Gentoo Linux.  
I tried running the script supplied in https://wiki.gentoo.org/wiki/LiveUSB/Guide, but I ran into some problems, so I followed the instructions manually, and came up with this.  

I originally intended for this to be run on an Ubuntu machine, which is where I have tested this. However, I believe it's flexible enough to run on any Linux system.  

## Requirements:
You downloaded the Gentoo installation media from https://www.gentoo.org/downloads/ or one of the mirror sites.   
The file should have the file extension `.iso`   
You also have a precompiled Master Boot Record on your computer, it should look something like this: `*mbr.bin`   

You have to run this as root.    

## Usage:
`./gentoo-usb.sh -t TARGET_PARTITION -m MBR_PATH -i ISO_PATH`   
Required flags:   
`-t`: Target partition. Something like `/dev/sdb1`, note that the partition number is required as well.  
`-m`: MBR-binary. The exact path to the precompiled Master Boot Record. For me, it was `/usr/lib/syslinux/mbr/mbr.bin`   
`-i`: ISO-file. Exact path to the ISO image that you downloaded   
Example:   
`./gentoo-usb.sh -t /dev/sdc1 -m /usr/lib/syslinux/mbr/mbr.bin -i /home/alice/Downloads/install-amd64-minimal-20210425T214502Z.iso`    




## WARNING! 
**THIS SCRIPT DELETES ALL DATA ON THE SPECIFIED DRIVE!**    
**NEEDLESS TO SAY, IF YOU ACCIDENTALLY SPECIFY THE WRONG DRIVE, IT WILL DELETE THE DATA THERE AS WELL!**    
**PLEASE USE WITH CAUTION!**    
