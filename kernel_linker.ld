OUTPUT_FORMAT(binary)
SECTIONS {

    . = 0xfff7000000;

    kernel_start :
    {
        *(.kernel_data)
        . = 0x100;
        kernel.o
    }

    .text :
    {
        *(.text .text.* .gnu.linkonce.t.*)
    }

    .data :
    {
        *(.data)
        *(.rodata .rodata* .gnu.linkonce.r.*)
    }

    .bss :
    {
        *(.bss)
    }

    INCLUDE kmalloc_symbols.ob;

    .resources :
    {
        *(.resources)
        font.o
        . = ALIGN(0x10000);
        *(.kmalloc_data)
    }
    

    
}