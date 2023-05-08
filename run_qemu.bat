

:: -debugcon stdio means any characters written to port 0xe9 are outputted in qemu terminal
qemu-system-x86_64 -enable-kvm -S -smp cpus=2 -cpu host -hda boot.img -m 4G -debugcon stdio -no-reboot -monitor stdio -d int -no-shutdown

