#include <typedefs.h>
#include <debugging.h>

void panic(int code) {
    char* str = "Kernel panic! error code: ";
    debug_str(str);
    debug_int(code);
    hcf();
}
