*-----------------------------------------------------------
* Title      : Final project: Disassembler
* Group      : The disassemblers
* Written by : Pranav Sakthivel, Kaib Cropley, Yash Khanchandani
* Created    : 10/17/2019
* Project Description: 
*   Write an inverse assembler (disassembler) that will convert a memory image of instructions 
*   and data back to 68000 assembly language and output the disassembled code to the display. 
*   You will not be required to disassemble all of the instructions and addressing modes. 
*   The list of instructions and addressing modes is given at Required Opcodes page.
*-----------------------------------------------------------



*-----------------------------------------------------------
* Global Registers
*-----------------------------------------------------------
* D0 = System trap codes
* D6, D7 = Pass args
* 
* A1 = Print strings
* A6 = Pass addressing arguments
* A7 = Stack pointer
*-----------------------------------------------------------


*************************
*      Constants        *
*************************
CR                  EQU     $0D     * Ascii for carriage return
LF                  EQU     $0D     * Ascii for carriage return
StartAddress        EQU     $5000
EndAddress          EQU     $5008   * difference of 4 or 8?
MSG_INVALID_OP      DC.B    'Invalid op code: ',CR,LF,0
IntroMsg            DC.B    'Please enter start and end hexadecimal addresses, one after the other: ',0
OverflowError       DC.B    'Overflow Error',CR,LF,0
ErrorMsg            DC.B    'Error: Invalid characters were entered. Please try again.',CR,LF,0

*************************
*      Opcode Messages  *
*************************

MoveBMsg            DC.B    'MOVE.B '
MoveWMsg            DC.B    'MOVE.W '
MoveLMsg            DC.B    'MOVE.L '
NopMsg              DC.B    'NOP '
MoveaWMsg           DC.B    'MOVEA.W '
MoveaLMsg           DC.B    'MOVEA.L '
MovemMsg            DC.B    'MOVEM '
MoveqMsg            DC.B    'MOVEQ '
LeaMsg              DC.B    'LEA '
AddMsg              DC.B    'ADD '
AddaMsg             DC.B    'ADDA '
AddqMsg             DC.B    'ADDQ '
SubMsg              DC.B    'SUB '
OrMsg               DC.B    'OR '
AndMsg              DC.B    'AND '
JsrMsg              DC.B    'JSR '
RtsMsg              DC.B    'RTS '
BgtMsg              DC.B    'BGT '
BeqMsg              DC.B    'BEQ '
BltMsg              DC.B    'BLT '
LslMsg              DC.B    'LSL '
LsrMsg              DC.B    'LSR '
AslMsg              DC.B    'ASL '
AsrMsg              DC.B    'ASR '
RolMsg              DC.B    'ROL '
RorMsg              DC.B    'ROR '

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

CLEAR_ARGS_DATA_REGISTERS:
    CLR         D6
    CLR         D7
    RTS

CLEAR_OPEN_DATA_REGISTERS:
    CLR         D1
    CLR         D2
    CLR         D3
    CLR         D4
    CLR         D5
    RTS

GLOBAL_RTS:
    RTS

*************************
*    Actual Program     *
*************************

    ORG    $1000

START:                  ; first instruction of program
        JSR         GET_USER_INPUT      * Get user input as string
        
        MOVEA.L     A1,A2               * Move A1 into A2 so value does not get overwritten
        MOVEA.L     #$2000,A3           * Starting address for storing Hex number at A3

        MOVE.B      #9,D2               * Number of digits to be read, subtracted each iteration
        MOVE.B      #1,D7               * Set that we are on the first number
        BRA         ASCII_TO_HEX        * Branch to converting number to hex

*************************
*         I/O           *
*************************
    
GET_USER_INPUT:     * Get user hex input
        LEA         IntroMsg,A1         * Load intro message into A1
        
        JSR         PRINT_MSG_ENDL      * Print intro message
        JSR         GET_INPUT_AS_STRING * Get the user input as string
        
        RTS    
    
PRINT_MSG_ENDL:     * Print message with CR LF
        MOVE.B      #13,D0
        TRAP        #15                 * Task 13: Display the NULL terminated string at (A1) with CR, LF.
        
        RTS

PRINT_MSG:          * Print message
        MOVE.B      #14,D0              * Loads task 14 (Print message without CRLF) into D0
        TRAP        #15                 * Execute Task 14: Display the NULL terminated string at (A1) without CR, LF.
        
        RTS
       
GET_INPUT_AS_STRING:                    * Get input from user as string
        MOVE.B      #2,D0               * Load code 2 into D0 to get string
        TRAP        #15                 * Execute code 2
        
        RTS
        
PRINT_NUM:          * Print number
        MOVE.B      #3,D0               * Move code 3 to D0
        TRAP        #15                 * Execute code 3: Display signed number in D1.L in decimal in smallest field
        
        RTS
        
ASCII_TO_HEX:       * Convert ASCII values to hex
        MOVE.B      (A2)+,D3            * Get value of each byte in string one by one
        SUB         #1,D2               * Decrement D2 by 1 for next loop
        
        CMP.B       #0,D2               * Check if the looping is over
        BEQ         DONE_WITH_HEX       * Exit to next instruction
        
        CMP.B       #$3A,D3             * Check if the character is a number
        BLT         CHECK_NUMBER        * Verify number
        
        CMP.B       #$40,D3             * Check if character is a letter
        BGT         CHECK_LETTER        * Branch to verify letter
        
CHECK_LETTER:       * Check if in valid letter range
        CMP.B       #$47,D3             * Check if letter is valid
        BLT         CONFIRM_LETTER      * Find exact letter
        BGE         INVALID
        
CONFIRM_LETTER:     * Find exact letter
        SUB.B       #$37,D3             * Subtract 37 to convert ASCII to hex
        MOVE.B      D3,(A3)+            * Add the hex digit to the address register, increment address register
       
        
        BRA         ASCII_TO_HEX        * Continue converting to hex
        
CHECK_NUMBER:       * Check if in valid number range
        CMP.B       #$2F,D3             * Check if valid number
        BGT         CONFIRM_NUMBER      * Branch to get value of exact number
        BLE         INVALID             * Branch to error case


CONFIRM_NUMBER:     * Confirm what number it exactly is
        SUB.B       #$30,D3             * Subtract $30 from D3 to convert to hex
        MOVE.B      D3,(A3)+            * Move to A3 and post increment
                
        BRA         ASCII_TO_HEX

        
DONE_WITH_HEX:  
        MOVE.B      #0,D2               * For loop constant
        MOVEA.L     #$2000,A3           * Clear start address
        
SAVE_HEX:
        ADD.B       #1,D2               * Increment loop
        BEQ         AFTER_ADDRESS       * Move to method after hex
        
        MOVE.B      (A3)+,D4            * Move hex digit to D4
        ADD.B       D4,D3               * Add digit to D3
        
        CMP.B       #8,D2               * Check if loop is over
        BEQ         AFTER_ADDRESS       * Move to method after hex
        
        LSL.L       #4,D3               * Move 4 bits 
        
        BRA         SAVE_HEX            * Loop until full number is saved
        
AFTER_ADDRESS:
        CMP.B       #1,D7
        BEQ         GET_2ND_NUMBER
        BNE         ALL_NUMBERS_DONE
        
GET_2ND_NUMBER:
        MOVE.L      D3,D5
        ADD.B       #1,D7
        
        JSR         GET_INPUT_AS_STRING  * Get user input as string
        
        MOVEA.L     A1,A2               * Move A1 into A2 so value does not get overwritten
        MOVEA.L     #$2000,A3           * Starting address for storing Hex number at A3

        MOVE.B      #9,D2               * Number of digits to be read, subtracted each iteration

        BRA         ASCII_TO_HEX        * Branch to converting number to hex
        
ALL_NUMBERS_DONE:

*************************
*       Op Codes        *
*************************

* Will attempt to discover what the opcode in D2 is and will call a subrountine to execute based on that opcode
* Requires: opcode binary is in D7
*   Uses:   D3,D4
GET_OP_CODE:
    MOVE.W      D7,D3
    AND.L       #$0000F000,D3           * We only want to test the instructions first nibble, get rid of all other bits
    LSR.L       #8,D3
    LSR.L       #4,D3

    MOVE.W      D7,D4                   * For inconclusive nibbles then we need to check the next nibble (aka second byte from the right)
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
    JSR         PRINT_MSG
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
    CMP.W       #$4E75,D7               * 4E75 = RTS
    BEQ         OP_RTS 
    CMP.W       #$4E71,D7               * 4E71 = NOP
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
    MOVE.W      D7,D4                   * To check between if it's LS, AS or RO we need to check the 3rd and 4th bits
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
    BTST        #8,D7
    BNE         OP_LSL                  * If bit = 1 then left
    BEQ         OP_LSR                  * If bit = 0 then right

OP_ASL_OR_ASR:
    BTST        #8,D7
    BNE         OP_ASL                  * If bit = 1 then left
    BEQ         OP_ASR                  * If bit = 0 then right

OP_ROL_OR_ROR:
    BTST        #8,D7
    BNE         OP_ROL                  * If bit = 1 then left
    BEQ         OP_ROR                  * If bit = 0 then right

*************************
*       Opcode Branching*
*************************

OP_NOP:
    LEA         NopMsg,A1
    JSR         PRINT_MSG

OP_MOVE_BYTE:
    LEA         MovebMsg,A1
    JSR         PRINT_MSG

OP_MOVE_WORD:
    LEA         MovewMsg,A1
    JSR         PRINT_MSG

OP_MOVE_LONG:
    LEA         MovelMsg,A1
    JSR         PRINT_MSG

OP_MOVEA_WORD:
    LEA         MoveawMsg,A1
    JSR         PRINT_MSG

OP_MOVEA_LONG:
    LEA         MovealMsg,A1
    JSR         PRINT_MSG

OP_MOVEM:
    LEA         MovemMsg,A1
    JSR         PRINT_MSG

OP_MOVEQ:
    LEA         MoveqMsg,A1
    JSR         PRINT_MSG

OP_LEA:
    LEA         LeaMsg,A1
    JSR         PRINT_MSG
    
OP_ADD:
    LEA         AddMsg,A1
    JSR         PRINT_MSG
    
OP_ADDA:
    LEA         AddaMsg,A1
    JSR         PRINT_MSG

OP_ADDQ:
    LEA         AddqMsg,A1
    JSR         PRINT_MSG

OP_SUB:
    LEA         SubMsg,A1
    JSR         PRINT_MSG

OP_OR:
    LEA         OrMsg,A1
    JSR         PRINT_MSG

OP_AND:
    LEA         AndMsg,A1
    JSR         PRINT_MSG

OP_JSR:
    LEA         JsrMsg,A1
    JSR         PRINT_MSG

OP_RTS:
    LEA         RtsMsg,A1
    JSR         PRINT_MSG

OP_BGT:
    LEA         BgtMsg,A1
    JSR         PRINT_MSG    

OP_BEQ:
    LEA         BeqMsg,A1
    JSR         PRINT_MSG

OP_BLT:
    LEA         BltMsg,A1
    JSR         PRINT_MSG

OP_LSL:
    LEA         LslMsg,A1
    JSR         PRINT_MSG

OP_LSR:
    LEA         LsrMsg,A1
    JSR         PRINT_MSG

OP_ASL:
    LEA         AslMsg,A1
    JSR         PRINT_MSG

OP_ASR:
    LEA         AsrMsg,A1
    JSR         PRINT_MSG

OP_ROL:
    LEA         RolMsg,A1
    JSR         PRINT_MSG

OP_ROR:
    LEA         RorMsg,A1
    JSR         PRINT_MSG


*************************
*        Other          *
*************************
INVALID:
        LEA         ErrorMsg,A1         * Load error message
        JSR         PRINT_MSG_ENDL      * Print error message
        
        BRA         START               * Restart program

DONE:
    SIMHALT                 ; halt simulator


    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
