OUTPUT_FORMAT(binary)
SECTIONS {

    . = 0xffff80000000;

    .data :
    {
        kernel.o
        *(.kernel)
        *(.data)
        *(.kernel_data)
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