@echo off

cls

::type "src\test_os_1.asm" > "cdiso\test_os_1.asm"

python preprocessor.py || GOTO end

nasm -f elf32 cdiso/output.asm -o asm.o || GOTO end

gcc -c -g -Wall -m16 src/long_mode_os/kernel/*.c asm.o -o cdiso/kernel.o -nostdlib -ffreestanding -mno-red-zone -fno-exceptions -nodefaultlibs -fno-builtin -fno-pic -fno-pie || GOTO end

ld -static -nostdlib -build-id=none -T linker.ld -R *.o -o os.img  || GOTO end

pause

mkisofs -no-emul-boot -boot-load-size 70 -exclude-list exclude.txt -o os.iso -b os.img %cd%/cdiso

:end

