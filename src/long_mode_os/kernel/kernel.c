#include <typedefs.h>

#include <paging.h>
#include <screen.h>

 
volatile void kernel_start() {

    //while (true) asm volatile ("hlt");

    map_screen_buffer();

    uint16_t* screen_buf = (uint16_t*)(long)virtual_scrn_buf_ptr;

    long screen_buf_end = (long)screen_buf + (long)(screen_buffer_size<<5);

    // x/10%500

    for (int count=0;(long)screen_buf<screen_buf_end;screen_buf++,count++) {
        *screen_buf = (uint16_t)((0xff << 10 | 0x00 << 5 | 0x00 ) & 0x7fff);
    }

    //(uint16_t)((0x00 << 10 | 0xff << 5 | 0xff) & 0x7fff);
    
    return;
}
 

