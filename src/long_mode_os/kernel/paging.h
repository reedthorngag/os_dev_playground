#include <typedefs.h>

void paging_init();

void translate_vaddr_to_pmap(long virtual_address,word map[4]);

void direct_map_paddr(uint64_t address, int size);

void* kmalloc(int size);

