@echo off

cd c:/code/os_stuff

xcopy /Y /I "test_os_1.asm" "cdiso/test_os_1.asm"

cd cdiso

del "test_os_1.iso"

nasm -f bin -o test_os_1.flp test_os_1.asm

mkisofs -no-emul-boot -boot-load-size 4 -o test_os_1.iso -b test_os_1.flp c:/code/os_stuff/cdiso

cd ..

