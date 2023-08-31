#include <typedefs.h>
#include <debugging.h>
#include <map_kernel.h>

uint64_t* pml4_tmp = (uint64_t*)0x1000;
extern uint64_t pml_space_start;
uint64_t* pml_space_ptr;
extern char _physical_kernel_start;

void map() {

    pml_space_ptr = (uint64_t*)&pml_space_start;

    debug((uint64_t)(1<<12)<<27);

    map_kernel(0xfff7000000,(uint64_t)&_physical_kernel_start,0x80);

    hcf();

    ((void(*)())0xfff7000000)();

    uint16_t buf[4];

    //translate_vaddr_to_pmap(0xfff7000000,buf);

    for (uchar i=4;i--;)
        debug(buf[i]);

    hcf();

}

void* alloc_page() {
    uint64_t* page = pml_space_ptr;
    pml_space_ptr += 512;
    return page;
}

// translate virtual address to an array of pml 4-1 addresses, 4 is highest (index 4)
void vaddr_to_pmap(long virtual_address,word pml_map[4]) {

    virtual_address>>=12; // divide virtual_address by 4096 (page size) to get the absolute page number

    for (uchar i=0;i<4;virtual_address>>=9,i++)
        pml_map[i] = (short)(virtual_address&0x01ff);
    
    return;
}

void map_kernel(uint64_t vaddress, uint64_t paddress, int num_pages) {

    word pml_map[4];
    vaddr_to_pmap(vaddress,pml_map);

    desc_table:

    uint64_t* pml_n = pml4_tmp;

    for (uchar level=4;--level;) {
        if (!pml_n[pml_map[level]]) {
            uint64_t pml_table = (uint64_t)alloc_page();

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

