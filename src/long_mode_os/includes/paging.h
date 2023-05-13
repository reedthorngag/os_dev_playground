#include <kernel.h>


extern uint32_t screen_buffer_ptr;
extern uint32_t screen_buffer_size;
extern uint32_t virtual_scrn_buf_ptr;

volatile void map_screen_buffer_ptr();

volatile void map_section();

