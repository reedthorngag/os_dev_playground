
#include <typedefs.h>
#include <convertions.h>
#include <debugging.h>

void debug_bool(bool out) {
    if (out)
        debug_str("true");
    else
        debug_str("false");
}

void debug_binary(char b) {
    for (uchar n=8;n--;)
        outb(0xe9,(b&(1<<n))>0?'1':'0');
    outb(0xe9,'\n');
    return;
}

void debug_short(short out) {
    char out_buf[4];
    word_to_hex(out,&out_buf[0]);
    for (uchar i=0;i<4;)
        outb(0xe9,out_buf[i++]);
    outb(0xe9,'\n');
    return;
}

void debug_int(int out) {
    char out_buf[8];
    word_to_hex((short)(out>>4),&out_buf[0]);
    word_to_hex((short)(out&0xffff),&out_buf[4]);
    for (uchar i=0;i<8;)
        outb(0xe9,out_buf[i++]);
    outb(0xe9,'\n');
    return;
}

void debug_long(long out) {
    char out_buf[16];
    for (uchar n=4;n--;out>>=16)
        word_to_hex(out,&out_buf[n<<2]);
    
    for (uchar i=0;i<16;)
        outb(0xe9,out_buf[i++]);
    outb(0xe9,'\n');
    return;
}

void debug_str(char str[]) {
    for (int n=0,c=str[n];c!=0;c=str[++n])
        outb(0xe9,c);
}
