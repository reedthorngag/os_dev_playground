
; \n is 0x0a


#include "start_editor.asm"

#include "cursor/cursor.asm"

#include "actions/insert.asm"
#include "actions/delete.asm"
#include "actions/enter.asm"

folder_segment: dw 0
file_offset: dw 0
file_path:  times 0x300 db 0
file_data:  times 0x18*0x4f db 0

first_showen_line: db 0x0

