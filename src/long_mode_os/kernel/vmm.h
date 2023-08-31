#include <typedefs.h>

void vmm_init();

void translate_vaddr_to_pmap(long virtual_address,word map[4]);

void map_pages(uint64_t vaddress, uint64_t paddress, int num_pages);


