#include <typedefs.h>
#include <screen.h>
#include <paging.h>
#include <convertions.h>

#include <debugging.h>

uint64_t* pml4 = (uint64_t*)0x1000;
extern uint64_t pml3;
extern uint64_t pml2;
extern uint64_t pml1;

extern int pml_table_end;

void paging_init() {

    debug_long((long)screen_buffer_ptr_real);

    uint64_t pml0 = 0 | 3; // backing memory physical address
    uint64_t* pml1_tmp = &pml1;
    uint64_t* pml2_tmp = &pml2;
    uint64_t* pml3_tmp = &pml3;

    for (short i=0;i<0x100;i++,pml2_tmp++) {
        if (pml0>(uint64_t)screen_buffer_ptr_real)
            pml0 += screen_buffer_size<<5;
        *pml2_tmp = (uint64_t)pml1_tmp | 3;
        for (short j=0;j<0x200;j++,pml1_tmp++,pml0+=0x1000) {
            *pml1_tmp = pml0;
        }
    }

    debug_long(*(uint64_t*)0x2000);

    *(uint64_t*)0x2000 = (uint64_t)pml2_tmp | 3;

    //pml4[0] = (uint64_t)&pml3 | 3;

    char* s = "done!";
    debug_str(s);

    //debug_long(pml4[0]);
    debug_long(*(uint64_t*)0x2000);

    hcf();

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

