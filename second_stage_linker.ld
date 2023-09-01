OUTPUT_FORMAT(binary)
SECTIONS {

    . = 0x8b00;

    second_stage_bootloader : 
    {
        *(.kernel_data)
        . = 0x100;
        map_kernel.obj
        . = ALIGN(0x1000);
        pml_tables.obj
    }

}