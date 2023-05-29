OUTPUT_FORMAT(binary)
SECTIONS {

    . = 0xffff80000000;

    .data :
    {
        *(.kernel_data)
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