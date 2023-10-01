#include <pmm.h>
#include <vmm.h>
#include <typedefs.h>
#include <debugging.h>

extern char kernel_start;
extern char kernel_end;
extern uint64_t pml_space_start;
extern uint64_t pml_space_end;

extern int screen_buffer_ptr_real;

char* kmalloc_table;
void* kmalloc_data;
const short kmalloc_blk_size = 128;
int kmalloc_table_size; // in blocks

uint8_t* nibble_map_ptr; // physical memory map start ptr
uint32_t nibble_map_size; // in bytes

extern uint64_t mem_map_buffer;
extern uint16_t mem_map_size;

struct mem_map_ent {
    uint64_t addr;
    uint64_t size;
    uint32_t type;
};

void create_physical_mem_map() {
    struct mem_map_ent* map = (struct mem_map_ent*)&mem_map_buffer;

    uint64_t highestaddr = 0;
    uint64_t highestsize = 0;
    uint64_t largestaddr = 0;
    uint64_t largestsize = 0;

    for (int i=0;i<mem_map_size;i++) {
        debug("\nmem_ent:\n");
        debug_("\taddr: ",map[i].addr);
        debug_("\tsize: ",map[i].size);
        debug_("\ttype: ",map[i].type);

        if (map[i].type != 1 && map[i].type != 3) continue;

        if (map[i].size > largestsize) {
            largestaddr = map[i].addr;
            largestsize = map[i].size;
        }

        if (map[i].addr > highestaddr) {
            highestaddr = map[i].addr;
            highestsize = map[i].size;
        }
    }

    uint64_t size = highestaddr + highestsize;

    debug_("\nmemory size: ",size);
    debug_("addr: ",highestaddr);
    debug_("size: ",highestsize);

    nibble_map_size = (size >> 13) + 1; // divide by 4096 (= one page per byte) then by 2 (= 2 pages per byte / 1 per nibble), add one for odd numbers of pages

    nibble_map_ptr = (uint8_t*)largestaddr;

    debug_("nibble_map_start:",(uint64_t)nibble_map_ptr);
    debug_("size: ",nibble_map_size);
    map_pages((uint64_t)nibble_map_ptr, (uint64_t)nibble_map_ptr, (nibble_map_size>>12)+((nibble_map_size&0xfff)>0));
    debug("here!\n");

    uint64_t* ptr = (uint64_t*)nibble_map_ptr;
    for (uint64_t target = (uint64_t)ptr + nibble_map_size; (uint64_t)++ptr < target;) {
        *ptr = ~0;
    }
    *(uint64_t*)(nibble_map_ptr+nibble_map_size-8) = ~0;

    for (int i=0;i<mem_map_size;i++) {
        struct mem_map_ent ent = map[i];
        if (ent.type != 1 && ent.type != 3) continue;
        map_p_range(ent.addr&(~0xfff),(ent.size>>12)+1,0); // assume (exceds the bounds if not) page aligned, this could/will break on real hardware
    }
}

void map_p_range(uint64_t addr,int pages,uchar type) {
    int rel_addr = (addr>>12) + pages;

    uchar* ptr = nibble_map_ptr + (rel_addr>>1);

    for (;pages--;rel_addr--) {
        if (rel_addr&1) {
            *ptr &= (uchar)0xf0;
            *ptr |= type;
        } else {
            *ptr &= (uchar)0x0f;
            *ptr-- |= (uchar)(type<<4);
        }
    }
}

uint64_t pmalloc(int pages) {
    uchar* ptr = nibble_map_ptr;
    for (int size=nibble_map_size<<1;size--;) {

        if ((*ptr++)>0xf*(1-(size&1))) continue;

        for (int n=pages<<1;--n && size--;) {

            if ((*ptr++)>0xf*(1-(size&1))) break;
        }

        if (size) continue;

        for (int n=pages<<1;n--;size++) {
            *(--ptr) |= (uchar)(1<<);
        }
    }
}

void pmm_init() {

    uint64_t abs_size = (uint64_t)(screen_buffer_ptr_real&~0xfff)-(uint64_t)pml_space_end;
    kmalloc_table_size = (int)(abs_size>>(kmalloc_blk_size>>5));

    kmalloc_table = (char*)pml_space_end;
    kmalloc_data = (void*)(pml_space_end+kmalloc_table_size);

    create_physical_mem_map();

    debug("made it this far?");
    hcf();

    debug(pml_space_end);

    for (int i=kmalloc_table_size;i--;) {
        if (kmalloc_table[i]) {
            debug((uint64_t)kmalloc_table+i);
            hcf();
        }
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



