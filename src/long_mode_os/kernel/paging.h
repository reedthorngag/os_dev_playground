#include <typedefs.h>

extern uint64_t *pml4;
extern uint64_t pml3;
extern uint64_t pml2;
extern uint64_t pml1;

void paging_init();

void translate_vaddr_to_pmap(long virtual_address,word map[4]);

void map_section();

