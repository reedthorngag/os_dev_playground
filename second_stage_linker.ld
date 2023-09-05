OUTPUT_FORMAT(binary)
SECTIONS {

    . = 0x8b00;

    second_stage_bootloader : 
    {
        asm.o
        . = 0x400;
        second_stage.obj
        . = ALIGN(0x1000);
        _physical_kernel_start = .;
    }

}