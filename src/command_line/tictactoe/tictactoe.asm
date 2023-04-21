
#include "start_tictactoe.asm"

player1_name: times 0x100 db 0
player2_name: times 0x100 db 0

board: times 0x9 db 0

turn: db 0
