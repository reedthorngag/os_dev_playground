#include <typedefs.h>

void pmm_init(uint64_t abs);

void* kmalloc(int size);

void print_kmalloc_allocated_table();

void kfree(void* ptr);
