*-----------------------------------------------------------
* Title      : Final project
* Written by : 
* Created    : 10/17/2019
* Description:
*-----------------------------------------------------------



*-----------------------------------------------------------
* Registers
*-----------------------------------------------------------
* D0 - DX = Free
* 
* 
* 
*-----------------------------------------------------------


*************************
*      Constants        *
*************************
BASE    dc.b    15      * New base we want
VALUE   dc.l    $973D4  * Hex val to convert

*************************
*    Actual Program     *
*************************

    ORG    $1000
START:                  ; first instruction of program
    MOVE.L      #$FFFF2FFF,D2
    JSR         GET_OP_CODE

*************************
*         I/O           *
*************************
* Return:   String from user in A1
*           Length of string in D1, (max 80)
GET_USER_STR:
    MOVE.B      #2,D0       * Task 2: Read string from the keyboard
    TRAP        #15         * Execute task 2       
    RTS
    
* Return:   Number from user in D1
GET_USER_NUM:
    MOVE.B      #4,D0       * Task 4: Read number from the keyboard
    TRAP        #15         * Execute task 4
    RTS

* Requires: Address of string to print in A1
PRINT_STR:      
    MOVE.B      #14,D0      * Task 14: Print string from A1
    TRAP        #15         * Execute task 14
    RTS
    
* Requires: Number in D1
PRINT_NUM:
    MOVE.B      #3,D0       * Task 3: Print signed number from D1.L
    TRAP        #15         * Execute task 3
    RTS

*************************
*       Op Codes        *
*************************

* Will attempt to discover what the opcode in D2 is and will call a subrountine to execute based on that opcode
* Requires: opcode binary is in D2
GET_OP_CODE:
    MOVE.L      D2,D3
    AND.L       #$0000F000,D3           * We only want to test the instructions first nibble, get rid of all other bits
    LSR.L       #8,D3
    LSR.L       #4,D3
    
    CMP.B       #$00,D3                 * Check if nibble = 0 - INVALID
    BEQ         INVALID_NIBBLE
    CMP.B       #$01,D3                 * Check if nibble = 1 - MOVE.B
    BEQ         OP_MOVE_BYTE
    CMP.B       #$02,D3                 * Check if nibble = 2 - MOVE.L, MOVEA.L
    BEQ         OP_NIBBLE_2
    CMP.B       #$03,D3                 * Check if nibble = 3 - MOVE.W, MOVEA.W
    BEQ         OP_NIBBLE_3
    CMP.B       #$04,D3                 * Check if nibble = 4 - NOP, MOVEM, LEA, JSR, RTS
    BEQ         OP_NIBBLE_4
    CMP.B       #$05,D3                 * Check if nibble = 5 - ADDQ
    BEQ         OP_ADDQ
    CMP.B       #$06,D3                 * Check if nibble = 6 - BGT, BEQ, BLE
    BEQ         OP_NIBBLE_6
    CMP.B       #$07,D3                 * Check if nibble = 7 - MOVEQ
    BEQ         OP_MOVEQ
    CMP.B       #$08,D3                 * Check if nibble = 8 - OR
    BEQ         OP_OR
    CMP.B       #$09,D3                 * Check if nibble = 9 - SUB
    BEQ         OP_SUB
    CMP.B       #$0A,D3                 * Check if nibble = A - INVALID
    BEQ         INVALID_NIBBLE
    CMP.B       #$0B,D3                 * Check if nibble = B - INVALID
    BEQ         INVALID_NIBBLE
    CMP.B       #$0C,D3                 * Check if nibble = C - AND
    BEQ         OP_AND
    CMP.B       #$0D,D3                 * Check if nibble = D - ADD, ADDA
    BEQ         OP_NIBBLE_D
    CMP.B       #$0E,D3                 * Check if nibble = E - LSL, LSR, ASL, ASR, ROL, ROR
    BEQ         OP_NIBBLE_E
    CMP.B       #$0F,D3                 * Check if nibble = F - INVALID
    BEQ         INVALID_NIBBLE
    BRA         INVALID_NIBBLE          * Assume if we haven't branched yet something is wrong
    

INVALID_NIBBLE:

OP_NIBBLE_2:

OP_NIBBLE_3:

OP_NIBBLE_4:

OP_NIBBLE_6:

OP_NIBBLE_7:

OP_NIBBLE_D:

OP_NIBBLE_E:



OP_MOVE_BYTE:

OP_MOVE_WORD:

OP_MOVE_LONG:

OP_MOVEA_WORD:

OP_MOVEA_LONG:

OP_ADD:

OP_ADDA:

OP_ADDQ:

OP_MOVEQ:

OP_OR:

OP_SUB:

OP_AND:



*************************
*        Other          *
*************************


DONE:
    SIMHALT                 ; halt simulator


    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
