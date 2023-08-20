#include <typedefs.h>

#include <paging.h>
#include <screen.h>
#include <convertions.h>
#include <paging.h>

volatile void kernel_start() {

    while (true);

    outb(0xe9,'a');

    paging_init();

    screen_init();

    char* hello = (char*)"Hello World!";
    write_string(0,0,hello,RGB(100,100,100),RGB(0,0,0));

    hcf();
    
    return; 
}
 

