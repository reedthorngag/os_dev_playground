; THIS FILE IS USELESS WHEN USING BIOS INT 0x16 FUNCTION!!! (ascii character is in al)


; key to translate in ax
; returns ascii character in al
; ZF set if successful, unset if key not found
translate_key:
    push ax     ; save key
    mov bx,keymap
.find_key:
    mov al,[bx]
    cmp al,ah
    je .load_key
    add bx,2
    cmp bx,keymap.end
    je .failed
    jmp .find_key


.load_key:
    inc bx
    mov al,[bx]
    pop bx
    and bl,0x80     ; 10000000
    jnz .success    ; register is not zeroed, so shift key not pressed


.success:
    xor ax,ax	; set ZF
	ret
.failed:
    mov ax,0
	cmp ax,1	; unset ZF
	ret

keymap:

.end: