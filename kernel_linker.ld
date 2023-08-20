OUTPUT_FORMAT(binary)
SECTIONS {

    . = 0xf00;

    .data :
    {
        *(.kernel_data)
        . = 0x1000;
        kernel.o
        *(.kernel)
        *(.data)
    }

    .text :
    {
        *(.text)
    }

    .resources :
    {
        *(.rodata)
        *(.resources)
        font.o
    }

    .bss :
    {
        *(.bss)
    }
}