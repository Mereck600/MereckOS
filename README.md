### Mereck OS

This is a work in progress simple OS 
# Tools
- Linux OS
- Micro text editor
- nasm assembler
- QEMU 
- MAKE
- mtools
- bochs

# Currently working on the bootloader
- Uses floppy disk as bootloader
# To run:
Install the nedded tools, you can just find them online and apt install if on linux if on windows good luck 
As of right now you just cd into the project, run 'make' in the teminal then run 'qemu-system-i386 -fda build/main_floppy.img'
run this together to simply run the below code 
``` make && qemu-system-i386 -fda build/main_floppy.img ```


# Explanation:
Bootloader starts off as a floppy disk for ease of use, universal support across vms and FAT12 because its simple 
