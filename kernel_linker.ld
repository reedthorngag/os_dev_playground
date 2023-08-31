OUTPUT_FORMAT(binary)
SECTIONS {

    . = 0x8b00;

    second_stage_bootloader : 
    {
        . = 0x100;
        map_kernel.o
    }

    kernel_data  :
    {
        *(.kernel_data)
    }

    _physical_kernel_start = .;
    kernel_start :
    {
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

    .resources :
    {
        *(.resources)
        font.o
        . = ALIGN(0x1000);
        *(.pml_map)
        . = ALIGN(0x10000);
        *(.kmalloc_data)
    }

    
}