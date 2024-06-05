
bubble_sort:

    lea si, .welcome_str
    call print_str
    call endl

    mov bx,word [.len]
.outer_loop:
    dec bx
    jz .end
    lea si, .data
    mov dx, word [.len]

.inner_loop:
    dec dx
    jz .outer_loop

    mov ax, word [si]
    add si,2
    cmp ax,word [si]
    jle .inner_loop

    mov cx, word [si]
    mov word [si], ax
    mov word [si-2], cx

    jmp .inner_loop

.end:
    lea si, .completed_str
    call print_str
    call endl

    lea si,.min_str
    call print_str
    mov bx, word [.data]
    call print_hex
    call endl

    lea si,.max_str
    call print_str
    mov bx, word [.data_last]
    call print_hex
    call endl

    xor ax,ax
    ret

.welcome_str: db 'welcome to my bubble sort demonstration',0
.completed_str: db 'sort completed!',0
.min_str: db 'min: 0x',0
.max_str: db 'max: 0x',0

.len: dw 20

.data:
    dw 525
    dw 997
    dw 877
    dw 348
    dw 581
    dw 473
    dw 154
    dw 546
    dw 134
    dw 687
    dw 784
    dw 297
    dw 668
    dw 17
    dw 651
    dw 722
    dw 145
    dw 39
    dw 636
.data_last:    dw 80
