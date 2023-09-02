
#include <typedefs.h>
#include <screen.h>
#include <debugging.h>
#include <vmm.h>

extern word screen_res_x;
extern word screen_res_y;
extern int screen_buffer_ptr_real;
extern int screen_buffer_size;
extern word bytes_per_line;
extern char bytes_per_pixel;

extern long _binary_zap_vga16_psf_start;
extern long _binary_zap_vga16_psf_end;
extern long _binary_zap_vga16_psf_size;

word* screen_buffer_ptr = (uint16_t*)0x1000000;
word screen_default_background = RGB(0,0,0);


void screen_init() {

    map_pages((long)screen_buffer_ptr,screen_buffer_ptr_real&~0xfff,screen_buffer_size>>2);

    wipe_screen();
}

void wipe_screen() {
    uint16_t* screen_buf = screen_buffer_ptr;

    long screen_buf_end = (long)screen_buf + (long)(screen_buffer_size<<2);

    for (;(long)screen_buf<screen_buf_end;screen_buf++) {
        *screen_buf = screen_default_background;
    }
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


void write_string(word x,word y,char string[], word color, word background) {
    for (int i=0;string[i];i++){
        draw_glyph(x+i*8,y,string[i],color,background);}
}

void draw_glyph(word x,word y,char character,word color,word background) {
    word* pointer = screen_buffer_ptr;
    pointer += x+1;
    pointer += y*screen_res_x;
    char* char_ptr = ((char*)&_binary_zap_vga16_psf_start)+3+character*16;

    for (char n=16;n--;) {
        decode_line(pointer,&char_ptr,color,background);
        pointer+=screen_res_x;
    }
}

void decode_line(word* pointer,char** char_ptr,word color,word background) {
    char line = *((*char_ptr)++);
    for (char n=8;n--;) {
        *(pointer++) = (line & 1<<n) ? color : background;
    }
}

