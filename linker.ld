OUTPUT_FORMAT(binary)
ENTRY(start)
SECTIONS {
    . = 0x7C00;
    
    .boot :
    {
        *(.boot)
        *(.text)
    }
    .data : 
    {
        *(.data)
    }
    .resources :
    {
        *(.resources)
    }
    .kernel :
    {
        *(.kernel)
    }
}