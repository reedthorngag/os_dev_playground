
#include <stdint.h>

// __attribute__((section(".kernel")))

volatile void setup_VESA_VBE();

volatile void main() {
    uint16_t a = 5;
    asm volatile inline ("add $0xaa55, %0":"=r" (a));
    setup_VESA_VBE();
    return;
}



