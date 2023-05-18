#include <typedefs.h>

#include <paging.h>
#include <screen.h>
#include <convertions.h>
#include <paging.h>

volatile void kernel_start() {

    hcf();

    screen_init();

    draw_rect(100,100,50,50,RGB(31,0,0));

    char buff[4] = {0};

    word* out = linear_translate_v_to_pmap(0x12345678);

    for (char i=4;i--;) {
        word_to_hex(out[i],buff);
        for (char n=0;n<16;n++)
            outb(0xe9,buff[n]);
    }

    write_string(0,0,buff,RGB(31,31,31),RGB(0,0,0));

    hcf();
    
    return; 
}
 

