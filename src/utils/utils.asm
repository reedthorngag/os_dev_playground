
#include "print_utils.asm"
#include "get_random.asm"
#include "copy_str.asm"
#include "pause.asm"
#include "str_len.asm"


; offset in si, preserves si
write_to_file_path_buffer:
	xor bx,bx
	mov di,file_path_buffer
.loop:
	mov al,[si+bx]
	cmp al,0
	je .clear_path
	mov byte [di+bx], al
	inc bx
	jmp .loop
.clear_path:
	mov al,[di+bx]
	cmp al,0
	je .end
	mov byte [di+bx],0
	inc bx
	cmp bx,0x200
	je .end
	jmp .clear_path
.end:
	ret

