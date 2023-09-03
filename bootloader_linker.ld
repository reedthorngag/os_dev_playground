OUTPUT_FORMAT(binary)
SECTIONS {
    
    . = 0x7C00;
    
    .boot :
    {
        *(.boot)
    }

    . = 0x8b00;

    .data :
    {
        *(.kernel_data)
    }
}