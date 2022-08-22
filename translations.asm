
; b0 61		    ; mov al,61
; b4 0e		    ; mov ah,0x0e
; ba 70 00      ; mov dx,hex_characters (a label) (70 is the position of the label from the start 0f the file)
; 8b 16 70 00   ; mov dx,[hex_characters]
; cd 10		    ; int 0x10
; eb fe		    ; jmp $
; c3            ; ret



