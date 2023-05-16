
#include <stdbool.h>
#include <stdint.h>

#define char unsigned char
#define word uint16_t
#define int uint32_t
#define long uint64_t

#define RGB(r,g,b) (word)(((char)b | (((char)g) << 5) | (((char)r) << 10)) & 0x7fff)

#define hcf() asm volatile ("cli"); while (true) asm volatile ("hlt")

#define outb(port,value) asm volatile ("outb %0,%1" :: "a"((char)value),"Nd"((word)port))

