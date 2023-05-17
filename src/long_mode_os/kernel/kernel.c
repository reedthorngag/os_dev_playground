#include <typedefs.h>

#include <paging.h>
#include <screen.h>
#include <convertions.h>

extern void pause();

volatile void kernel_start() {

    screen_init();

    draw_rect(100,100,50,50,RGB(31,0,0));

    char buff[16] = {0};

    //int_to_hex((long)_binary_zap_vga16_psf_start,buff);

    long value = 0x100000000000dead;

    int_to_hex(&value,buff);

    for (char n=16;n--;)
        outb(0xe9,buff[n]);

    //word_to_hex(0x8001,buff);
    hcf();

    write_string(0,0,buff,16,RGB(31,31,31),RGB(0,0,0));

    hcf();
    
    return;
}
 

