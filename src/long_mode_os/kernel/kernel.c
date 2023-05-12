
#include <stdint.h>

#define int uint32_t


struct pml4t {
    uint32_t pdpt[0x200];
};

extern void setup_VESA_VBE();

volatile void main() {
    uint16_t a = 5;
    asm volatile inline ("add $0xaa55, %0":"=r" (a));
    return;
}

extern uint32_t screen_buffer_ptr;
extern uint32_t screen_buffer_size;
extern uint32_t virtual_scrn_buf_ptr;

volatile void map_screen_buffer_ptr() {
    
    int scrn_buf_virtual_address = (screen_buffer_ptr - screen_buffer_ptr % 0x1000) | 3;

    int* pdbt = (int*)0x3008;
    *pdbt = (int)0x5003;

    int* page_file_end = (int*)0x5000;

    int virtual_address = (0x200000 + screen_buffer_ptr % 0x1000);  


    for (int i=0; i<(screen_buffer_size>>7);i++,scrn_buf_virtual_address+=0x1000,page_file_end+=2) {
        *page_file_end = scrn_buf_virtual_address;
    }

    virtual_scrn_buf_ptr = virtual_address;

    return;

}


volatile void map_section() {

}



