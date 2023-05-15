
#include <typedefs.h>

extern uint16_t x_res;
extern uint16_t y_res;
extern uint32_t screen_buffer_ptr;
extern uint32_t screen_buffer_size;
extern uint32_t virtual_scrn_buf_ptr;

void draw_pixel(int x,int y,word color);


volatile void map_screen_buffer();
