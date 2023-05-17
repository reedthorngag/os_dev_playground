#include <typedefs.h>

#include <paging.h>
#include <screen.h>
#include <convertions.h>

volatile void kernel_start() {

    screen_init();

    draw_rect(100,100,50,50,RGB(31,0,0));

    char buff[17] = {0};

    long value = (long)&_binary_zap_vga16_psf_start;

    long_to_hex(&value,buff);

    for (char n=0;n<16;n++)
        outb(0xe9,buff[n]);

    write_string(0,0,buff,RGB(31,31,31),RGB(0,0,0));

    hcf();
    
    return;
}
 

