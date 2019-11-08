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
CR                  EQU     $0D     * Ascii for carriage return
LF                  EQU     $0D     * Ascii for carriage return
MSG_INVALID_OP          DC.B        "Invalid op code: ",CR,LF,0

*************************
*  Global subrountines  *
*************************

CLEAR_ALL_DATA_REGISTERS:
    CLR         D0
    CLR         D1
    CLR         D2
    CLR         D3
    CLR         D4
    CLR         D5
    CLR         D6
    CLR         D7
    RTS

CLEAR_INPUT_DATA_REGISTERS:
    CLR         D1
    CLR         D2
    CLR         D3
    RTS

CLEAR_OPEN_DATA_REGISTERS:
    CLR         D4
    CLR         D5
    CLR         D6
    CLR         D7
    RTS

GLOBAL_RTS:
    RTS

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
*   Uses:   D3,D4
GET_OP_CODE:
    MOVE.W      D2,D3
    AND.L       #$0000F000,D3           * We only want to test the instructions first nibble, get rid of all other bits
    LSR.L       #8,D3
    LSR.L       #4,D3

    MOVE.W      D2,D4                   * For inconclusive nibbles then we need to check the next nibble (aka second byte from the right)
    LSR.L       #8,D4                   * Get rid of the right most byte and replace it with the left most
    
    CMP.B       #$00,D3                 * Check if nibble = 0 - INVALID
    BEQ         INVALID_OP
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
    BEQ         INVALID_OP
    CMP.B       #$0B,D3                 * Check if nibble = B - INVALID
    BEQ         INVALID_OP
    CMP.B       #$0C,D3                 * Check if nibble = C - AND
    BEQ         OP_AND
    CMP.B       #$0D,D3                 * Check if nibble = D - ADD, ADDA
    BEQ         OP_NIBBLE_D
    CMP.B       #$0E,D3                 * Check if nibble = E - LSL, LSR, ASL, ASR, ROL, ROR
    BEQ         OP_NIBBLE_E
    CMP.B       #$0F,D3                 * Check if nibble = F - INVALID
    BEQ         INVALID_OP
    BRA         INVALID_OP              * Assume if we haven't branched yet something is wrong
    

INVALID_OP:
    LEA         MSG_INVALID_OP,A1
    JSR         PRINT_STR
    RTS

OP_NIBBLE_2:    * MOVE.L, MOVEA.L

OP_NIBBLE_3:    * MOVE.W, MOVEA.W

OP_NIBBLE_4:    * NOP, MOVEM, LEA, JSR, RTS
    CMP.B       #$4E,D3                 * 4E = NOP, JSR, RTS
    BEQ         OP_BYTE_4E
    
    BTST        #8,D3                   * MOVEM is the only nibble 4 with a 1 as the 8th bit
    BNE         OP_MOVEM                * There is a 1 at the 8th bit
    BRA         OP_LEA                  * If no 1 at 8th bit then default to LEA <--- CHANGE TO CATCH FALSE POSITIVES

OP_BYTE_4E:     * NOP, JSR, RTS
    CMP.W       #$4E75,D2               * 4E75 = RTS
    BEQ         OP_RTS 
    CMP.W       #$4E71,D2               * 4E71 = NOP
    BEQ         OP_NOP
    BRA         OP_JSR                  * Default: JSR <--- CHANGE TO CATCH FALSE POSITIVES

OP_NIBBLE_6:    * BGT, BEQ, BLE
    CMP.W       #$6E,D4                 * 6E = BGT
    BEQ         OP_BGT
    CMP.W       #$67,D4                 * 67 = BEQ
    BEQ         OP_BEQ
    CMP.W       #$6F,D4                 * 6F = BLT
    BEQ         OP_BLT
    BRA         INVALID_OP              * If doesn't match the bytes from above then it's invalid


OP_NIBBLE_D:    * ADD, ADDA

OP_NIBBLE_E:    * LSL, LSR, ASL, ASR, ROL, ROR
    MOVE.W      D2,D4                   * To check between if it's LS, AS or RO we need to check the 3rd and 4th bits
    LSR.L       #3,D4                   * Move the bits we need to the right most places
    AND.W       #%0000000000000011,D4   * Get rid of all other bits
                                        * Note to compare Left or Right use the 8th bit of D2
    CMP.B       #$01,D4                 * If bits are 01 = LS
    BEQ         OP_LSL_OR_LSR
    CMP.B       #$00,D4                 * If bits are 00 = AS
    BEQ         OP_ASL_OR_ASR
    CMP.B       #$02,D4                 * If bits are 11 = RO
    BEQ         OP_ROL_OR_ROR

    BRA         INVALID_OP              * If bits are 10 = INVALID

OP_LSL_OR_LSR:
    BTST        #8,D2
    BNE         OP_LSL                  * If bit = 1 then left
    BEQ         OP_LSR                  * If bit = 0 then right

OP_ASL_OR_ASR:
    BTST        #8,D2
    BNE         OP_ASL                  * If bit = 1 then left
    BEQ         OP_ASR                  * If bit = 0 then right

OP_ROL_OR_ROR:
    BTST        #8,D2
    BNE         OP_ROL                  * If bit = 1 then left
    BEQ         OP_ROR                  * If bit = 0 then right

 

OP_NOP:

OP_MOVE_BYTE:

OP_MOVE_WORD:

OP_MOVE_LONG:

OP_MOVEA_WORD:

OP_MOVEA_LONG:

OP_MOVEM:

OP_MOVEQ:

OP_LEA:

OP_ADD:

OP_ADDA:

OP_ADDQ:

OP_SUB:

OP_OR:

OP_AND:

OP_JSR:

OP_RTS:

OP_BGT:

OP_BEQ:

OP_BLT:

OP_LSL:

OP_LSR:

OP_ASL:

OP_ASR:

OP_ROL:

OP_ROR:


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
