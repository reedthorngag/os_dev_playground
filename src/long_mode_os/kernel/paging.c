#include <typedefs.h>


void paging_init() {

}

// translate virtual address to an array of pml 1-4 addresses
void linear_translate_v_to_pmap(int virtual_address,word map[4]) {
    int out = virtual_address>>12; // divide virtual_address by 4096 to get the absolute page number

    for (char i=0;i<4;out>>=9,i++)
        map[i] = (word)(out&0x001ff);
}

void map_section() {

}

void map_page() {
    
}

