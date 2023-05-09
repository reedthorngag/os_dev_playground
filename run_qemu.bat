

:: -debugcon stdio means any characters written to port 0xe9 are outputted in qemu terminal
:: note: add -enable-kvm once ive restarted my laptop
qemu-system-x86_64 -smp cpus=2 -cpu max -drive file=bin/os.img,format=raw -m 4G -no-reboot -monitor stdio -d int -no-shutdown

