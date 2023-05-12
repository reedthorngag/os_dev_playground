
#include <stdint.h>

#define int uint32_t

// __attribute__((section(".kernel")))

extern void setup_VESA_VBE();

volatile void main() {
    return;
}

extern uint32_t screen_buffer_ptr;
extern uint32_t screen_buffer_size;
extern uint32_t virtual_scrn_buf_ptr;

volatile void map_screen_buffer_ptr() {
    uint16_t a = 5;
    asm volatile inline ("add $0xaa55, %0":"=r" (a));
    

    return;
    
    int scrn_buf_virtual_address = screen_buffer_ptr - screen_buffer_ptr % 0x1000;

    int* pdbt = (int*)0x3008;
    *pdbt = (int)0x5003;

    int* page_file_end = (int*)0x5000;

    int virtual_address = (0x200000 + screen_buffer_ptr % 0x1000);

    return;

    for (int i=0; i<(screen_buffer_size>>10);i++,scrn_buf_virtual_address+=0x1000) {
        page_file_end[i] = scrn_buf_virtual_address;
    }

    virtual_scrn_buf_ptr = virtual_address;

    return;

}



