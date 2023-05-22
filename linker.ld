OUTPUT_FORMAT(binary)
SECTIONS {
    . = 0x7C00;
    
    .boot :
    {
        *(.boot)
    }

    . = 0x10000;

    .data :
    {
        kernel.o
        *(.data)
    }

    .text :
    {
        *(.text)
    }

    .bss :
    {
        *(.bss)
    }

    .resources :
    {
        font.o
        *(.rodata)
        *(.resources)
    }
}