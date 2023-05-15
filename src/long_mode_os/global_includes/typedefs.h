
#include <stdbool.h>
#include <stdint.h>

#define word uint16_t
#define int uint32_t
#define long uint64_t

#define RGB(r,g,b) (word)(((char)b | (((char)g) << 5) | (((char)r) << 10)) & 0x7fff)

#define hcf() asm volatile ("cli"); while (true) asm volatile ("hlt");

