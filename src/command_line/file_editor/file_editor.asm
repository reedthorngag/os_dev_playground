
#include "start_editor.asm"

folder_segment: dw 0
file offset: dw 0
file_path:  times 0x300 db 0
file_data:  times 0x300 db 0

