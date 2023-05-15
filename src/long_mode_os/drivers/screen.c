
#include <typedefs.h>
#include <screen.h>

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

word* screen_buffer_ptr;


void map_screen_buffer() {
    
    int scrn_buf_virtual_address = (screen_buffer_ptr_real - screen_buffer_ptr_real % 0x1000) | 3;

    int* pdbt = (int*)0x3008;
    *pdbt = (int)0x5003;

    int* page_file_end = (int*)0x5000;
    int virtual_address = (0x200000 + screen_buffer_ptr_real % 0x1000);  

    for (int i=0; i<(screen_buffer_size>>7);i++,scrn_buf_virtual_address+=0x1000,page_file_end+=2) {
        *page_file_end = scrn_buf_virtual_address;
    }

    virtual_scrn_buf_ptr = virtual_address;
    return;
}


void screen_init() {
    map_screen_buffer();
    screen_buffer_ptr = (word*)(long)virtual_scrn_buf_ptr;
}

void draw_pixel(word x,word y,word color) {
    word* pointer = screen_buffer_ptr;
    if (bytes_per_pixel==0) while (true);
    pointer += x*bytes_per_pixel;
    pointer += y*bytes_per_line;
    *pointer = color;
}

void draw_glyph(word x,word y,char character) {}

