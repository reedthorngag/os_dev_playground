#include <pmm.h>
#include <vmm.h>
#include <typedefs.h>
#include <debugging.h>


extern int pml_table_end;

extern char kmalloc_data_start;

char* kmalloc_table;
void* kmalloc_data;
const short kmalloc_blk_size = 128;
int kmalloc_table_size; // in blocks


void pmm_init(uint64_t direct_mapping_end) {

    uint64_t abs_size = (abs^3)-(uint64_t)&kmalloc_data_start;
    kmalloc_table_size = (int)(abs_size>>(kmalloc_blk_size>>5));

    kmalloc_table = (char*)&kmalloc_data_start;
    kmalloc_data = (void*)(&kmalloc_data_start+kmalloc_table_size);

    for (int i=kmalloc_table_size;i--;)
        kmalloc_table[i] = 0;
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



