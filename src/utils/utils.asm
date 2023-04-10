; offset in si, preserves si
write_to_file_path_buffer:
	xor bx,bx
	mov di,[file_path_buffer_offset]
.loop:
	mov al,[si+bx]
	cmp al,0
	je .end
	mov [di+bx], al
	inc bx
	jmp .loop
.end:
	ret

