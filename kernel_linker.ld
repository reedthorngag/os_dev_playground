OUTPUT_FORMAT(binary)
SECTIONS {

    . = 0x8b00;

    .data :
    {
        *(.kernel_data)
        . = 0x100;
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