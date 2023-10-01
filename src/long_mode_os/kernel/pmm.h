#include <typedefs.h>

void pmm_init();

void map_p_range(uint64_t addr,int pages,uchar type);

uint64_t pmalloc(int pages);

void* kmalloc(int size);

void print_kmalloc_allocated_table();

void kfree(void* ptr);
