; clears screen
clear:
    xor bx,bx
    call reset_page

    xor ax,ax
    ret
    
