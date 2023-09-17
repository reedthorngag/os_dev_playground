
#include <typedefs.h>
#include <convertions.h>

#define debug(x) _Generic((x),\
                            char: debug_binary, \
                            short: debug_short, \
                            int: debug_int,     \
                            long: debug_long,   \
                            char*: debug_str   \
                            )(x);

#define debug_(x,j) debug(x);debug(j);

void debug_bool(bool out);

void debug_binary(char b);

void debug_short(short out);

void debug_int(int out);

void debug_long(long out);

void debug_str(char str[]);
