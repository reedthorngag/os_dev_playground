
#include <typedefs.h>
#include <screen.h>

extern word screen_res_x;
extern word screen_res_y;
extern int screen_buffer_ptr_real;
extern int screen_buffer_size;
extern int virtual_scrn_buf_ptr;
extern word bytes_per_line;
extern char bytes_per_pixel;

extern char* _binary_zap_vga16_psf_start;
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
    pointer += x;
    pointer += y*screen_res_x;
    *pointer = color;
}

void draw_rect(word x,word y, word width,word height, word color) {
    word* pointer = screen_buffer_ptr;
    pointer += x;
    pointer += y*screen_res_x;

    for (;height--;pointer+=screen_res_x-width)
        for (word x=width;x--;pointer++)
            *pointer = color;
}

void draw_glyph(word x,word y,char character,word color,word background) {
    word* pointer = screen_buffer_ptr;
    pointer += x;
    pointer += y*screen_res_x;
    char* char_ptr = (char*)(long)(0x9101+3+character*16);//_binary_zap_vga16_psf_start;

    for (char n=16;n--;) {
        decode_line(pointer,&char_ptr,color,background);
        pointer+=screen_res_x;
    }
}

void decode_line(word* pointer,char** char_ptr,word color,word background) {
    char line = *((*char_ptr)++);
    for (char n=8;n--;) {
        *(pointer++) = (line & 1<<n) ? background : color;
    }
}

