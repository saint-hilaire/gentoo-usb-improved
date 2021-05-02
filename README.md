
## ABOUT
This script will turn your USB-drive into a bootable drive from which you can boot Gentoo Linux.  
I tried running the script supplied in https://wiki.gentoo.org/wiki/LiveUSB/Guide, but I ran into some problems, so I followed the instructions manually, and came up with this.  

I originally intended for this to be run on an Ubuntu machine, which is where I have tested this. However, I believe it's flexible enough to run on any Linux system.  

## Requirements:
You downloaded the Gentoo installation media from https://www.gentoo.org/downloads/ or one of the mirror sites.   
The file should have the file extension `.iso`   
You also have a precompiled Master Boot Record on your computer, it should look something like this: `*mbr.bin`   


You have to run this as root.


## WARNING! 
**THIS SCRIPT DELETES ALL DATA ON THE SPECIFIED DRIVE!**    
**NEEDLESS TO SAY, IF YOU ACCIDENTALLY SPECIFY THE WRONG DRIVE, IT WILL DELETE THE DATA THERE AS WELL!**    
**PLEASE USE WITH CAUTION!**    
