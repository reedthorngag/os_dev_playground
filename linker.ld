OUTPUT_FORMAT(binary)
SECTIONS {
    . = 0x7C00;
    
    .boot :
    {
        *(.boot)
    }

    . = 0xa000;

    .out :
    {
        bin/kernel.o
        *(.out)
    }

    . = 0x10000;

    .resources :
    {
        *(.resources)
    }
}