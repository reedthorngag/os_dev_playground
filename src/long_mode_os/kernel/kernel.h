#include <debugging.h>
#include <paging.h>
#include <screen.h>

volatile void kernel_start();

void panic(int code);
