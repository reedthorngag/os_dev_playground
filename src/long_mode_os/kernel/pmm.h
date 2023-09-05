#include <typedefs.h>

void pmm_init();

void* kmalloc(int size);

void print_kmalloc_allocated_table();

void kfree(void* ptr);
