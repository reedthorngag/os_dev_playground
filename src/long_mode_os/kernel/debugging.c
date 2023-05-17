
#include <typedefs.h>

void debug_binary_b(char b) {
    for (char n=8;n--;)
        outb(0xe9,(b&(1<<n))>0?'1':'0');
    outb(0xe9,' ');
}
