
#include <stdbool.h>
#include <stdint.h>

#define word uint16_t
#define int uint32_t
#define long uint64_t

#define RGB(r,g,b) (word)(((char)r << 10 | (char)g << 5 | (char)b) & 0x7fff)

#define hcf() while (true) asm volatile ("hlt");

