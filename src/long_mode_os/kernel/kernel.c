#include <stdbool.h>
#include <stdint.h>

#include <paging.h>

#define int uint32_t
#define long uint64_t

 
volatile void kernel_start() {

    //while (true) asm volatile ("hlt");

    while (true) asm volatile ("hlt");

    map_screen_buffer_ptr();

    uint16_t* screen_buf = (uint16_t*)(long)screen_buffer_ptr;

    long screen_buf_end = (long)screen_buffer_ptr + (long)screen_buffer_size;

    for (;(long)screen_buf<screen_buf_end;screen_buf++) {
        *screen_buf = (uint16_t)((0x00 | 0xff << 5 | 0xff << 10) & 0x7fff);
    }

    asm volatile ("cli");
    while (true) {
        asm volatile ("hlt"); 
    }
    
    return;
}
 

