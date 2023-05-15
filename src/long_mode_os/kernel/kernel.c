#include <typedefs.h>

#include <paging.h>
#include <screen.h>
 

volatile void kernel_start() {

    screen_init();

    word* screen_buf = screen_buffer_ptr;

    long screen_buf_end = (long)screen_buf + (long)(screen_buffer_size<<5);


    for (int count=0;(long)screen_buf<screen_buf_end;screen_buf++,count++) {
        *screen_buf = RGB(0,0,0);
    }

    draw_pixel(50,100,RGB(0xff,0xff,0xff));

    hcf();

    for (word x=0,y=50;x<5000;x++) {
        draw_pixel(x,y,RGB(0xff,0,0));
    }
    
    return;
}
 

