#include <pmm.h>
#include <vmm.h>
#include <typedefs.h>
#include <debugging.h>

extern char kernel_start;
extern char kernel_end;
extern uint64_t pml_space_start;
extern uint64_t pml_space_end;

char* kmalloc_table;
void* kmalloc_data;
const short kmalloc_blk_size = 128;
int kmalloc_table_size; // in blocks

extern uint64_t mem_map_buffer;
extern uint16_t mem_map_size;

struct mem_map_ent {
    uint64_t addr;
    uint64_t size;
    uint32_t type;
};

void create_pbm() {
    uint64_t addr = 0;
    uint32_t index;
    struct mem_map_ent* map = (struct mem_map_ent*)&mem_map_buffer;

    for (int i=0;i<mem_map_size;i++) {
        if (map->addr>addr) {
            addr = map->addr;
            index = i;
        }
    }

    uint64_t max = addr+map[index].size;
    debug("memory size: ");
    debug(max);
}

void pmm_init() {

    create_pbm();

    uint64_t abs_size = ((uint64_t)&kernel_start+0x2000*0x1000)-(uint64_t)pml_space_end;
    kmalloc_table_size = (int)(abs_size>>(kmalloc_blk_size>>5));

    kmalloc_table = (char*)pml_space_end;
    kmalloc_data = (void*)(pml_space_end+kmalloc_table_size);

    debug(pml_space_end);

    for (int i=kmalloc_table_size;i--;) {
        if (kmalloc_table[i]) {
            debug((uint64_t)kmalloc_table+i);
            hcf();
        }
        kmalloc_table[i] = 0;
    }
    
    hcf();

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



