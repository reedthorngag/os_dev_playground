
#include <typedefs.h>

extern word x_res;
extern word y_res;
extern int screen_buffer_ptr_real;
extern int screen_buffer_size;
extern int virtual_scrn_buf_ptr;
extern word bytes_per_line;
extern char bytes_per_pixel;

extern long _binary_zap_vga16_psf_start;
extern long _binary_zap_vga16_psf_end;
extern long _binary_zap_vga16_psf_size;

extern word* screen_buffer_ptr;

void screen_init();

void draw_pixel(word x,word y,word color);

void draw_glyph(word x,word y,char character);

void map_screen_buffer();

