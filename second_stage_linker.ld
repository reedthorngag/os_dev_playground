OUTPUT_FORMAT(binary)
SECTIONS {

    . = 0x8e00;

    second_stage_bootloader : 
    {
        *(.kernel_data)
        . = 0x400;
        second_stage.obj
        . = ALIGN(0x1000);
        _physical_kernel_start = .;
    }

}