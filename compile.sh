#!/bin/sh

clear

rm ./cdiso/*.o

python3 preprocessor.py

nasm -f elf32 cdiso/output.asm -o cdiso/asm.o

gcc -c -g -Wall -m32 src/long_mode_os/kernel/*.c -o cdiso/kernel.o -nostdlib -ffreestanding -mno-red-zone -fno-exceptions -nodefaultlibs -fno-builtin -fno-pic -fno-pie

echo 2

ld -m elf_i386 -r -static -nostdlib -T linker.ld -R cdiso/asm.o -o cdiso/os.img

echo 3

mkisofs -no-emul-boot -boot-load-size 10 -exclude-list cdiso/exclude.txt -o cdiso/os.iso -b cdiso/os.img ./

