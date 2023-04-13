; offset in si, preserves si
write_to_file_path_buffer:
	xor bx,bx
	mov di,[file_path_buffer_offset]
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

