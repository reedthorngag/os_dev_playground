
#include <stdint.h>

uint16_t RGB(char r,char g,char b) {
    return (uint16_t)((r << 10 | g << 5 | b) & 0x7fff);
}
