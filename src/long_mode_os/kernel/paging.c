#include <typedefs.h>
#include <screen.h>
#include <paging.h>
#include <convertions.h>

#include <debugging.h>

extern uint64_t* pml4;
extern uint64_t* pml3;

void paging_init() {
    word pml_map[4] = {0};
    translate_vaddr_to_pmap(0xffff80000000,pml_map);

    for (uchar i=4;i--;) {
        debug_short(pml_map[i]);
    }
}

// translate virtual address to an array of pml 4-1 addresses, 4 is highest (index 4)
void translate_vaddr_to_pmap(long virtual_address,word pml_map[4]) {

    virtual_address>>=12; // divide virtual_address by 4096 (page size) to get the absolute page number

    for (uchar i=0;i<4;virtual_address>>=9,i++)
        pml_map[i] = (short)(virtual_address&0x01ff);
    
    return;
}

void map_section() {

}

void map_page() {
    
}

