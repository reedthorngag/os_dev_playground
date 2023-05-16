#include <typedefs.h>

#include <paging.h>
#include <screen.h>
#include <convertions.h>

extern void pause();

volatile void kernel_start() {

    outb(0xe9,'a');

    pause();

    screen_init();

    word* screen_buf = screen_buffer_ptr;

    long screen_buf_end = (long)screen_buf + (long)(screen_buffer_size<<5);


    for (int count=0;(long)screen_buf<screen_buf_end;screen_buf++,count++) {
        *screen_buf = RGB(0,0,31);
    }

    draw_rect(100,100,50,50,RGB(31,0,0));

    char buff[5] = {0};

    int_to_hex(0xDEAD,buff);

    for (char i=0;i<4;i++) {
        draw_glyph(i*8,0,buff[i],RGB(0,31,0),RGB(0,0,0));
    }

    hcf();
    
    return;
}
 

