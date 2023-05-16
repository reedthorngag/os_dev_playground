
#include <typedefs.h>

void int_to_hex(long value,char* out) {
    int shift_mod = 64;
    char i = 0;
    do {
        shift_mod-=4;
        char nibble = value>>shift_mod;
        char num = "0123456789abcdef"[nibble];
        if (out[0]!='0' || num != '0'){
            outb(0xe9,i);
            out[i++] = num;
        }

        value ^= nibble<<shift_mod;

    } while (shift_mod!=0);
}

