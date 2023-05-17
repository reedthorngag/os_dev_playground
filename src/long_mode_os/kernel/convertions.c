
#include <typedefs.h>
#include <debugging.h>
#include <convertions.h>

void int_to_hex(long* value,char* out) {
    for (char i=4;i--;out+=4)
        word_to_hex((word)(*value&(0xffff<<(i<<4))),out);
}

void word_to_hex(word value,char* out) {
    for (char i=4;i--;value=value>>2) {
        out[i] = "0123456789abcdef"[value&0xf];
    }
}

