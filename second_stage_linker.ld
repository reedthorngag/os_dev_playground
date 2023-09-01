OUTPUT_FORMAT(binary)
SECTIONS {

    . = 0x8b00;

    INCLUDE pml_tables.ob;

    second_stage_bootloader : 
    {
        *(.kernel_data)
        . = 0x100;
        map_kernel.o
        . = ALIGN(0x1000);
        *(.pml_map)
    }

}