#include <typedefs.h>
#include <screen.h>
#include <paging.h>
#include <convertions.h>

void paging_init() {
    word pml_map[4] = {0};
    linear_translate_v_to_pmap(0xffffffff70000000,pml_map);
    char buff[5] = {0};
    for (char i=4;i--;) {
        word_to_hex(pml_map[i],buff);
        write_string(0,16,buff,Color_WHITE,Color_BLACK);
    }
}

// translate virtual address to an array of pml 1-4 addresses
void linear_translate_v_to_pmap(long virtual_address,word map[4]) {
    int out = virtual_address>>12; // divide virtual_address by 4096 to get the absolute page number

    for (char i=0;i<4;out>>=9,i++)
        map[i] = (word)(out&0x001ff);
}

void map_section() {

}

void map_page() {
    
}

