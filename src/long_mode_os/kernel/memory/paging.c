#include <typedefs.h>

// translate virtual address to an array of pml 1-4 addresses
word[4] linear_translate_v_to_pmap(int virtual_address) {
    int out = virtual_address>>12; // divide virtual_address by 4096 to get the absolute page number
    word map[4] = {0};

    for (i=0;i<4;out = out>>4)
        map[i] = out = out>>10;
    
    512 >> 3


}

volatile void map_section() {

}

void map_page() {
    
}

