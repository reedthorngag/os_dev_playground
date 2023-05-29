OUTPUT_FORMAT(binary)
SECTIONS {
    . = 0x7C00;
    
    .boot :
    {
        *(.boot)
    }

    . = 0xffff80000000;    

    .data :
    {
        kernel.o
        *(.kernel)
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