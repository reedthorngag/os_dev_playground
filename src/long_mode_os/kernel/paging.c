#include <typedefs.h>
#include <screen.h>
#include <paging.h>
#include <convertions.h>
#include <exceptions.h>

#include <debugging.h>

uint64_t* pml4 = (uint64_t*)0x1000;
extern uint64_t pml3;
extern uint64_t pml2;
extern uint64_t pml1;

extern int pml_table_end;

extern char kmalloc_data_start;

char* kmalloc_table;
void* kmalloc_data;
const short kmalloc_blk_size = 128;
int kmalloc_table_size; // in blocks

void paging_init() {

    uint16_t buf[4];

    translate_vaddr_to_pmap(0x40200000,buf);

    for (uchar i=4;i--;)
        debug(buf[i]);
    
    translate_vaddr_to_pmap(0x10000000000,buf);

    debug("hi?\n");
    for (uchar i=4;i--;)
        debug(buf[i]);

    debug("------\n");

    uint64_t pml0 = 0 | 3; // backing memory physical address
    uint64_t* pml1_tmp = &pml1;
    uint64_t* pml2_tmp = &pml2;

    for (short i=0;i<0x8f;i++,pml2_tmp++) {
        *pml2_tmp = (uint64_t)pml1_tmp | 3;

        for (short j=0;j<0x200;j++,pml1_tmp++,pml0+=0x1000) {
            *pml1_tmp = pml0;
        }
    }

    *(uint64_t*)(0x2000) = (uint64_t)pml2_tmp | 3;

    uint64_t abs_size = (pml0^3)-(uint64_t)&kmalloc_data_start;
    kmalloc_table_size = (int)(abs_size>>(kmalloc_blk_size>>5));

    kmalloc_table = (char*)&kmalloc_data_start;
    kmalloc_data = (void*)(&kmalloc_data_start+kmalloc_table_size);

    for (int i=kmalloc_table_size;i--;)
        kmalloc_table[i] = 0;

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

    uint64_t* pml_n = pml4;

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

void* kmalloc(int size) {
    // remember to fix equivelent problems in kfree() if fixing stuff

    size += 4;

    int large_blks = size >> 10; // TODO: calculate bitshift based on kmalloc_blk_size
    int blks = ((size & (kmalloc_blk_size*8-1)) >> 7) + 1; // TODO: check not exactly equal before adding 1

    if (large_blks) {
        char find = ((1<<blks)-1)<<(8-blks);
        char* kmalloc_ptr = kmalloc_table;
        for (;(uint64_t)kmalloc_ptr!=(uint64_t)kmalloc_data;kmalloc_ptr++) { // loop through the kmalloc table
            
            if (*kmalloc_ptr) // block not free
                continue;
            
            int b = (int)(kmalloc_ptr-kmalloc_table);
            for (int j=large_blks;--j;) { // check enough are free
                if (*++kmalloc_ptr)
                    break;
            }
            if (find & *++kmalloc_ptr) // block part not free
                continue;
            
            // check still smaller than the end of the table
            if ((uint64_t)kmalloc_ptr>=(uint64_t)kmalloc_data)
                return 0;
            
            *kmalloc_ptr |= find; // set block part taken
            for (int k=large_blks;k--;) // fill taken blocks
                *--kmalloc_ptr = 0xff;
            
            int* data = (int*)(kmalloc_data+(b<<10)+4);
            *data = large_blks*8+blks;

            return (void*)(++data);
        }
    } else {
        char find = ((1<<blks)-1);
        char* kmalloc_ptr = kmalloc_table;
        for (;(uint64_t)kmalloc_ptr!=(uint64_t)kmalloc_data;kmalloc_ptr++) {
            
            if (find & *kmalloc_ptr)
                continue;

            int j=0;
            for (char c=*kmalloc_ptr; j<9-blks && !(find<<++j & c););
            *kmalloc_ptr |= find << --j;
            int* data = (int*)(kmalloc_data+((int)(kmalloc_ptr-kmalloc_table)<<10)+((8-(j+blks))<<7));
            *data = blks;
            return (void*)(++data);
        }
    }

    // TODO: do some fancy paging shit to extend the kmalloc table/space when (nearly, or we are fucked anyway) full
    return 0;
}

void kfree(void* ptr) {

    int size = *(int*)(ptr-sizeof(int));
    int large_blks = size >> 10;
    int blks = ((size & (kmalloc_blk_size*8-1)) >> 7) + 1;

    if (large_blks) {
        return;
        char bits = ((1<<blks)-1)<<(8-blks);
        char* kmalloc_ptr = kmalloc_table + ((ptr-kmalloc_data)>>10);
        for (;large_blks--;)
            *kmalloc_ptr++ = 0;
        *kmalloc_ptr ^= bits;
    } else {
        char* kmalloc_ptr = kmalloc_table + ((ptr-kmalloc_data)>>10);
        char bits = ((1<<blks)-1) << (8-((ptr-kmalloc_data)>>7 & 0b111)-blks);
        *kmalloc_ptr ^= bits;
    }
}

void print_kmalloc_allocated_table() {
    char* str = "kmalloc table:\n";
    debug_str(str);
    for (int i=0;i<kmalloc_table_size;i++) {
        if (!kmalloc_table[i]) {
            debug_binary(0);
            return;
        }
        debug_binary(kmalloc_table[i]);
    }
}

