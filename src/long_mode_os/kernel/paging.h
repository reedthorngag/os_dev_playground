#include <typedefs.h>

void paging_init();

void translate_vaddr_to_pmap(long virtual_address,word map[4]);

void map_pages(uint64_t vaddress, uint64_t paddress, int num_pages);

void* kmalloc(int size);

void print_kmalloc_allocated_table();

void kfree(void* ptr);
