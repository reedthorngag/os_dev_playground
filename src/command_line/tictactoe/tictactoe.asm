
#include "start_tictactoe.asm"

player1_name: times 0x100 db 0
player2_name: times 0x100 db 0

player1_score: dw 0
player2_score: dw 0

board: 
    times 0x9 db 0
    db 0

empty_board: 
    db 0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39
    db 0

turn: db 0
