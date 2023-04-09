@echo off

cls

echo %cd%

if exist "src/test_os_1.asm" (echo hello)

xcopy /Y /-I ".\src\test_os_1.asm" ".\cdiso\test_os_1.asm"

cd cdiso

nasm -f bin -o test_os_1.flp test_os_1.asm


mkisofs -no-emul-boot -boot-load-size 1 -exclude-list exclude.txt -o test_os_1.iso -b test_os_1.flp %cd%

cd ..

