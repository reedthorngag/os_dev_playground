@echo off

cls

::type "src\test_os_1.asm" > "cdiso\test_os_1.asm"

python preprocessor.py

cd cdiso

nasm -f bin -o os.flp output.asm

mkisofs -no-emul-boot -boot-load-size 70 -exclude-list exclude.txt -o os.iso -b os.flp %cd%

cd ..

