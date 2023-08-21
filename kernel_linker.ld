OUTPUT_FORMAT(binary)
SECTIONS {

    . = 0x8b00;

    .text :
    {
        *(.kernel_data)
        . = 0x100;
        kernel.o
        *(.kernel)
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

    .data :
    {
        *(.data)
        . = ALIGN(0x1000);
        pml_tables.o
    }
}