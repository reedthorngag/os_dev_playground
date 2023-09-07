#include <typedefs.h>
#include <debugging.h>

#include <screen.h>
#include <convertions.h>
#include <vmm.h>

extern uint64_t mem_map_buffer;

volatile void kernel_start() {

    debug(mem_map_buffer);
    debug(*(uint64_t*)&mem_map_buffer);
    debug(*((uint64_t*)&mem_map_buffer+1));
    debug(*((uint32_t*)&mem_map_buffer+4));

    hcf();

    vmm_init();
    screen_init();

    write_string(0,0,"Hello World!",RGB(255,255,255),RGB(0,0,0));

    hcf();
    
    return;
}
 

