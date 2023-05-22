#include <typedefs.h>

#include <paging.h>
#include <screen.h>
#include <convertions.h>
#include <paging.h>

volatile void kernel_start() {

    screen_init();

    paging_init();

    char* hello = (char*)"Hello World!";
    write_string(0,0,hello,RGB(31,31,31),RGB(0,0,0));

    char buff[4] = {0};

    word out[4] = {0};
    
    linear_translate_v_to_pmap(0x00020000,out);

    for (char i=4;i--;) {
        word_to_hex(out[i],buff);
        for (char n=0;n<4;n++)
            outb(0xe9,buff[n]);
    }


    hcf();
    
    return; 
}
 

