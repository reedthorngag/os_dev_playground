#include <typedefs.h>
#include <screen.h>
#include <convertions.h>
#include <exceptions.h>
#include <pmm.h>
#include <vmm.h>

#include <debugging.h>

uint64_t* pml4 = (uint64_t*)0x1000;
extern uint64_t pml3;
extern uint64_t pml2;
extern uint64_t pml1;

void vmm_init() {

    uint16_t buf[4];

    debug((uint64_t)(512<<12)<<27);

    translate_vaddr_to_pmap(0x0,buf);

    for (uchar i=4;i--;)
        debug(buf[i]);
    
    translate_vaddr_to_pmap(0x10000000000,buf);

    debug("hi?\n");
    for (uchar i=4;i--;)
        debug(buf[i]);

    debug("------\n");

}

// translate virtual address to an array of pml 4-1 addresses, 4 is highest (index 4)
void translate_vaddr_to_pmap(long virtual_address,word pml_map[4]) {

    virtual_address>>=12; // divide virtual_address by 4096 (page size) to get the absolute page number

    for (uchar i=0;i<4;virtual_address>>=9,i++)
        pml_map[i] = (short)(virtual_address&0x01ff);
    
    return;
}

void map_pages(uint64_t vaddress, uint64_t paddress, int num_pages) {

    word pml_map[4];
    translate_vaddr_to_pmap(vaddress,pml_map);

    desc_table:

    uint64_t* pml_n = (uint64_t*)0x1000;

    for (uchar level=4;--level;) {
        if (!pml_n[pml_map[level]]) {
            uint64_t pml_table = (uint64_t)kmalloc(0x2000);
            if (!pml_table) {
                panic(-100);
            }
            pml_table = ((pml_table>>12)+1)<<12;
            pml_n[pml_map[level]] = pml_table | 3;
        }
        pml_n = (uint64_t*)(pml_n[pml_map[level]]&~0xfff);
    }

    do {
        *pml_n++ = paddress | 3;
        paddress += 0x1000;
        if (!((long)pml_n&0xfff)) {
            pml_map[1]++;
            pml_map[0] = 0;
            goto desc_table;
        }
    } while (--num_pages);

    return;
}

