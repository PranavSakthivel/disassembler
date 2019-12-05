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
CntrlCounterAddr    EQU     $5012
EndlMsg             DC.B    '',CR,LF,0
SpaceMsg            DC.B    ' ',0
MSG_INVALID_OP      DC.B    'Invalid op code: ',0
MSG_INVALID_EA      DC.B    'Invalid ea code: ',CR,LF,0
IntroMsg            DC.B    'Please enter start and end hexadecimal addresses, one after the other: ',0
ContinueReadingMsg  DC.B    'Please press "enter" to read another 15 lines, any other key will terminate the program',0
RestartMsg          DC.B    'If you would like to start over type "y", if you would like to terminate type anything else',0
OverflowError       DC.B    'Overflow Error',CR,LF,0
MSG_INVALID_INPUT   DC.B    'Error: Invalid characters were entered. Valid characters are 0-9 and A-F.',CR,LF,0
InvalidIOLengthMsg  DC.B    'Error: Invalid number of characters were entered. Each address must be 8 characters. Please try again.',CR,LF,0
addrOnePrompt       DC.B    'Start address: ',0
addrTwoPrompt       DC.B    'End address: ',0
MSG_INVALID_GREATER DC.B    'Start address cannot be greater than end address',0
MSG_INVALID_EQUAL   DC.B    'Start address cannot be equal to end address',0
IS_REV              DS.W    2 
CNTRI               DS.W    2 
CNTRJ               DS.W    2 
CNTR                DS.W    2 
REVERSEBITS         DS.W    2 
ISLONG              DS.W    2
*****************************
* Hex Jump Table Messages:
*****************************

HexMsg      DC.B    '$',0
Zero        DC.B    '0',0
One         DC.B    '1',0
Two         DC.B    '2',0
Three       DC.B    '3',0
Four        DC.B    '4',0
Five        DC.B    '5',0
Six         DC.B    '6',0
Seven       DC.B    '7',0    
Eight       DC.B    '8',0
Nine        DC.B    '9',0
A           DC.B    'A',0
B           DC.B    'B',0
C           DC.B    'C',0               
D           DC.B    'D',0
E           DC.B    'E',0
F           DC.B    'F',0

*************************
*      Opcode Messages  *
*************************

ByteMsg             DC.B    '.B ',0
WordMsg             DC.B    '.W ',0
LongMsg             DC.B    '.L ',0
MoveMsg             DC.B    'MOVE',0
NotMsg              DC.B    'NOT',0
NopMsg              DC.B    'NOP ',0
MoveaMsg            DC.B    'MOVEA',0
MovemMsg            DC.B    'MOVEM',0
MoveqMsg            DC.B    'MOVEQ ',0
LeaMsg              DC.B    'LEA ',0
AddMsg              DC.B    'ADD',0
AddaMsg             DC.B    'ADDA',0
AddqMsg             DC.B    'ADDQ',0
SubMsg              DC.B    'SUB',0
OrMsg               DC.B    'OR',0
AndMsg              DC.B    'AND',0
JsrMsg              DC.B    'JSR ',0
RtsMsg              DC.B    'RTS ',0
BraMsg              DC.B    'BRA ',0
BgtMsg              DC.B    'BGT ',0
BeqMsg              DC.B    'BEQ ',0
BleMsg              DC.B    'BLE ',0
LslMsg              DC.B    'LSL',0
LsrMsg              DC.B    'LSR',0
AslMsg              DC.B    'ASL',0
AsrMsg              DC.B    'ASR',0
RolMsg              DC.B    'ROL',0
RorMsg              DC.B    'ROR',0

*************************
*    Actual Program     *
*************************

    ORG    $1000

START:                  ; first instruction of program
    * JSR             CLEAR_ALL_DATA_REGISTERS *TBD THIS MUST BE BELOW THE ORG TO WORK
    * JSR             RUN_ALL_TESTS       * TBD Comment out for prod

    JSR             CALL_GET_USER_INPUT     * Get and save user input
    BRA             CHECK_IF_DONE_READING   * Begin loop of reading and printing

CHECK_IF_DONE_READING:
    BRA             READ_AND_WAIT_LOOP
    * Ignore below until reading works
    * CMPA            StartAddress,EndAddress   * Check if start and end addresses are equal
    BGE             CHECK_IF_RESTART    * If equal (or greater), assume done but first check if they want to restart
    BLT             READ_AND_WAIT_LOOP  * Else continue to loop


READ_AND_WAIT_LOOP:
    CMP.L           #15,D2              * Check loop counter
    BEQ             WAIT_FOR_USER       * If done printing required lines then we need to wait for user before we continue to read
    ADDQ            #1,D2               * Increment counter

    JSR             READ_NEXT_WORD      * Read and store next instruction
    JSR             CALL_GET_OP         * Get opcode, which will call into the correct EA
    JSR             PRINT_NEWLINE
    BRA             READ_AND_WAIT_LOOP  * Continue the loop

WAIT_FOR_USER:
    CLR         D1                      * Clear relevant data registers
    CLR         D2
    LEA         ContinueReadingMsg,A1   * Print message asking if they want to continue
    JSR         PRINT_MSG_ENDL
    MOVE.B      #5,D0  
    TRAP        #15                     * Task 5: Read single character from the keyboard into D1.B

    CMP.B       #$0D,D1                 * #$0D = 'enter' (key)
    BEQ         CHECK_IF_DONE_READING   * If enter continue to read
    BNE         CHECK_IF_RESTART        * Else check if they would like to restart

CHECK_IF_RESTART:
    CLR         D1                      * Clear D1 because Trap task #5 only will write a byte into it
    JSR         PRINT_NEWLINE           * Required formatting if they decided to stop midway through the program
    LEA         RestartMsg,A1           * Ask if they would like to restart
    JSR         PRINT_MSG_ENDL
    MOVE.B      #5,D0  
    TRAP        #15                     * Task 5: Read single character from the keyboard into D1.B

    CMP.B       #$79,D1                 * #$79 = 'y'
    BEQ         START                   * If y then restart
    BNE         DONE                    * Else finish

* CALL_GET_USER_INPUT and CALL_GET_OP are both wrapper methods for GET_USER_INPUT and GET_OP_CODE
* Uses a wrapper so the control can easily manage saving their counter and retrieving it before 
*   and after each of these calls.
*
* Uses D2 for the counter
* Uses the address at CntrlCounterAddr for storage

CALL_GET_USER_INPUT:
    JSR         SAVE_CONTROL_COUNTER
    JSR         GET_USER_INPUT
    JSR         READ_CONTROL_COUNTER
    RTS

CALL_GET_OP:
    JSR         SAVE_CONTROL_COUNTER
    JSR         GET_OP_CODE
    JSR         READ_CONTROL_COUNTER
    RTS

SAVE_CONTROL_COUNTER:
    MOVE.B      D2,CntrlCounterAddr
    CLR         D2
    RTS

READ_CONTROL_COUNTER:
    CLR         D2
    MOVE.B      CntrlCounterAddr,D2
    RTS

* Reading Memory
* READ_NEXT_WORD & READ_NEXT_LONG are for normal reading of the next instruction
* READ_WORD & READ_LONG are for EA to call and have the data be put in D6 so that the instruction stays in D7
* 
* Requires: A6 to have a memory address of current instruction
* Output:   D7 as instruction, 
*           D6 as other data, 
*           A5 as the previous instruction (aka current instruction being evaluated)

READ_NEXT_WORD:
    MOVEA.L     A6,A5
    MOVE.W      (A6)+,D7
    JSR         PRINT_CURRENT_ADDRESS
    RTS

READ_NEXT_LONG:
    MOVEA.L     A6,A5
    MOVE.L      (A6)+,D7
    JSR         PRINT_CURRENT_ADDRESS
    RTS

READ_WORD:
    MOVE.W      (A6)+,D6
    RTS

READ_LONG:
    MOVE.L      (A6)+,D6
    RTS

PRINT_CURRENT_ADDRESS:
    MOVE.L      A5,D5
    JSR         HEX_TO_ASCII_LONG
    JSR         PRINT_TAB
    RTS

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
*         I/O           *
*************************
    
GET_USER_INPUT:     * Get user hex input
        LEA         IntroMsg,A1         * Load intro message into A1
        JSR         PRINT_MSG_ENDL      * Print intro message

        LEA         addrOnePrompt,A1    * Load intro message into A1
        JSR         PRINT_MSG           * Print prompt

        JSR         GET_INPUT_AS_STRING * Get the user input as string
        CMP.W       #$0008,D1           * User input length retuned in D1.W (max 80)
        BNE         INVALID_IO_LENGTH   * Invalid length (aka address was less than 8 chars)
        
        MOVEA.L     A1,A2
        
        MOVE.B      #1,D7
        
        MOVEA.L     #$3500,A3           * Starting address for storing Hex number at A3

        MOVE.B      #9,D2               * Number of digits to be read, subtracted each iteration
        
        BRA         ASCII_TO_HEX 
          
    
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

PRINT_NEWLINE:
        LEA         EndlMsg,A1          * Prints a new line
        JSR         PRINT_MSG_ENDL

        RTS

PRINT_SPACE:
        LEA         SpaceMsg,A1          * Prints a space
        JSR         PRINT_MSG
        RTS

PRINT_TAB:
        JSR         PRINT_SPACE
        JSR         PRINT_SPACE
        JSR         PRINT_SPACE
        JSR         PRINT_SPACE
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
        BGE         INVALID_IO
        
CONFIRM_LETTER:     * Find exact letter
        SUB.B       #$37,D3             * Subtract 37 to convert ASCII to hex
        MOVE.B      D3,(A3)+            * Add the hex digit to the address register, increment address register
       
        BRA         ASCII_TO_HEX        * Continue converting to hex
        
CHECK_NUMBER:       * Check if in valid number range
        CMP.B       #$2F,D3             * Check if valid number
        BGT         CONFIRM_NUMBER      * Branch to get value of exact number
        BLE         INVALID_IO          * Branch to error case

CONFIRM_NUMBER:     * Confirm what number it exactly is
        SUB.B       #$30,D3             * Subtract $30 from D3 to convert to hex
        MOVE.B      D3,(A3)+            * Move to A3 and post increment
                
        BRA         ASCII_TO_HEX
        
DONE_WITH_HEX:  
        MOVE.B      #0,D2               * For loop constant
        MOVEA.L     #$3500,A3           * Clear start address
        
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
        
        * CMP.L       D5,D3
        * BGT         INVALID_START_GREATER
        * BEQ         INVALID_EQUAL
        
        BRA         GLOBAL_RTS
        
GET_2ND_NUMBER:
        MOVEA.L     D3,A6
        MOVE.L      D3,D5
        ADD.B       #1,D7
        LEA         addrTwoPrompt,A1    * Load intro message into A1
        JSR         PRINT_MSG           * Print prompt
        
        JSR         GET_INPUT_AS_STRING  * Get user input as string
        
        MOVEA.L     A1,A2               * Move A1 into A2 so value does not get overwritten
        MOVEA.L     #$3500,A3           * Starting address for storing Hex number at A3

        MOVE.B      #9,D2               * Number of digits to be read, subtracted each iteration

        BRA         ASCII_TO_HEX        * Branch to converting number to hex

PRINT_BYTE:
    LEA         ByteMsg,A1
    JSR         PRINT_MSG
    RTS

PRINT_WORD:
    LEA         WordMsg,A1
    JSR         PRINT_MSG
    RTS

PRINT_LONG:
    LEA         LongMsg,A1
    JSR         PRINT_MSG
    RTS

ALL_NUMBERS_DONE:

        
        SIMHALT     * debugging
        
INVALID_EQUAL:
        LEA         MSG_INVALID_EQUAL,A1
        JSR         PRINT_MSG_ENDL
        
        BRA         GET_USER_INPUT
INVALID_START_GREATER:
        LEA         MSG_INVALID_GREATER,A1
        JSR         PRINT_MSG_ENDL
        
        BRA         GET_USER_INPUT
INVALID_IO:
        LEA         MSG_INVALID_INPUT,A1    * Load error message
        JSR         PRINT_MSG_ENDL      * Print error message
        
        BRA         GET_USER_INPUT               * Restart program

INVALID_IO_LENGTH:
    LEA         InvalidIOLengthMsg,A1       * Load error message
    JSR         PRINT_MSG_ENDL              * Print error message
    
    BRA         GET_USER_INPUT              * Restart IO
    
*************************
*  Print Hex Methods    *
*  Put Hex value in D5  *
*************************

HEX_TO_ASCII_WORD:

        
        LSL.L       #8,D5
        LSL.L       #8,D5
        MOVE.L      D5,$3000
        JSR         HEX_TO_ASCII
        
        RTS
HEX_TO_ASCII_LONG:
        MOVE.L      D5,$3000
        JSR         HEX_TO_ASCII
        
        LSL.L       #8,D5
        LSL.L       #8,D5
        
        MOVE.L      D5,$3000
        JSR         HEX_TO_ASCII
        
        RTS

HEX_TO_ASCII:
        LEA         HEX_JUMP_TABLE,A2
        MOVE.W      $3000,D3
        
        * First nibble
        LSR         #8,D3
        LSR         #4,D3
        
        MULU        #6,D3
        JSR         0(A2,D3)
        
        MOVE.W      $3000,D3
        
        * Second nibble
        LSL         #4,D3
        LSR         #4,D3
        LSR         #8,D3
        
        MULU        #6,D3
        JSR         0(A2,D3)
        
        MOVE.W      $3000,D3
        
        * Third nibble
        LSL         #8,D3
        LSR         #8,D3
        LSR         #4,D3
        
        MULU        #6,D3
        JSR         0(A2,D3)
        
        MOVE.W      $3000,D3
        
        * Fourth nibble
        LSL         #8,D3
        LSL         #4,D3
        LSR         #8,D3
        LSR         #4,D3

        MULU        #6,D3
        JSR         0(A2,D3)
        CLR.W       D3
        
        RTS


***************************    
* HEX JUMP TABLE STUFF:
***************************
HEX_JUMP_TABLE
        JMP         PRINT_0
        JMP         PRINT_1
        JMP         PRINT_2
        JMP         PRINT_3
        JMP         PRINT_4
        JMP         PRINT_5
        JMP         PRINT_6
        JMP         PRINT_7
        JMP         PRINT_8
        JMP         PRINT_9
        JMP         PRINT_A
        JMP         PRINT_B
        JMP         PRINT_C
        JMP         PRINT_D
        JMP         PRINT_E
        JMP         PRINT_F
        
PRINT_0:
        LEA         Zero,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_1:
        LEA         One,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_2:
        LEA         Two,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_3:
        LEA         Three,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_4:
        LEA         Four,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_5:
        LEA         Five,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_6:
        LEA         Six,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_7:
        LEA         Seven,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_8:
        LEA         Eight,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_9:
        LEA         Nine,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_A:
        LEA         A,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_B:
        LEA         B,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_C:
        LEA         C,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_D:
        LEA         D,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_E:
        LEA         E,A1
        JSR         PRINT_MSG
        
        RTS
PRINT_F:
        LEA         F,A1
        JSR         PRINT_MSG
        
        RTS


*************************
*  Op Codes branching   *
*************************

* Will attempt to discover what the opcode in D2 is and will call a subrountine to execute based on that opcode
* Requires: opcode binary is in D7
*   Uses:   D3,D4
GET_OP_CODE:
    MOVE.W      D7,D3
    AND.L       #$0000F000,D3           * We only want to check if the instructions first nibble, get rid of all other bits
    LSR.L       #8,D3
    LSR.L       #4,D3

    CLR         D4                      * Clear in case a long was previously stored here
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
    CMP.B       #$04,D3                 * Check if nibble = 4 - NOP, NOT, MOVEM, LEA, JSR, RTS
    BEQ         OP_NIBBLE_4
    CMP.B       #$05,D3                 * Check if nibble = 5 - ADDQ
    BEQ         OP_ADDQ
    CMP.B       #$06,D3                 * Check if nibble = 6 - BGT, BEQ, BLE, BRA
    BEQ         OP_NIBBLE_6
    CMP.B       #$07,D3                 * Check if nibble = 7 - MOVEQ (Most likely)
    BEQ         OP_CHECK_MOVEQ
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
    MOVE.W      D7,D4                   * To check between if it's MOVE or MOVEA we must check its bits at indices 6, 7 and 8
    LSR.L       #6,D4                   * Move most important bits to the right
    AND.L       #$00000007,D4           * AND with 00000007 leaves us with only the three right most bits

    CMP.B       #01,D4                  * If the 3 bits are 001 then it's MOVEA, else MOVE
    BEQ         OP_MOVEA_LONG
    BNE         OP_MOVE_LONG

OP_NIBBLE_3:    * MOVE.W, MOVEA.W
    MOVE.W      D7,D4                   * To check between if it's MOVE or MOVEA we must check its bits at indices 6, 7 and 8
    LSR.L       #6,D4                   * Move most important bits to the right
    AND.L       #$00000007,D4           * AND with 00000007 leaves us with only the three right most bits

    CMP.B       #01,D4                  * If the 3 bits are 001 then it's MOVEA, else MOVE
    BEQ         OP_MOVEA_WORD
    CMP.B       #08,D4    
    BLT         OP_MOVE_WORD

    BRA         INVALID_OP

OP_NIBBLE_4:    * NOP, MOVEM, LEA, JSR, RTS
    CMP.B       #$4E,D4                 * 4E = NOP, JSR, RTS
    BEQ         OP_BYTE_4E

    CMP.B       #$46,D4                 * 46 = NOT
    BEQ         OP_NOT
    
    MOVE.W      D7,D4
    AND.W       #%1111101110000000,D4   * Get rid of all bits that aren't constant in MOVEM
    CMP.W       #%0100100010000000,D4   * Check if it is equal to the constant values in MOVEM
    BEQ         OP_MOVEM

    MOVE.W      D7,D4
    AND.W       #%1111000111000000,D4   * Get rid of all bits that aren't constant in LEA
    CMP.W       #%0100000111000000,D4   * Check if it is equal to the constant values in LEA
    BEQ         OP_LEA
    BRA         INVALID_OP

OP_BYTE_4E:     * NOP, JSR, RTS
    CMP.W       #$4E75,D7               * 4E75 = RTS
    BEQ         OP_RTS 
    CMP.W       #$4E71,D7               * 4E71 = NOP
    BEQ         OP_NOP

    MOVE.W      D7,D4
    AND.L       #$0000FFC0,D4           * Get rid of the last 6 bits because they aren't constant in JSR
    CMP.W       #$00004E80,D4           * Check if it is equal to the constant values in JSR
    BEQ         OP_JSR
    BRA         INVALID_OP

OP_NIBBLE_6:    * BGT, BEQ, BLE
    CMP.W       #$60,D4                 * 60 = BRA
    BEQ         OP_BRA
    CMP.W       #$6E,D4                 * 6E = BGT
    BEQ         OP_BGT
    CMP.W       #$67,D4                 * 67 = BEQ
    BEQ         OP_BEQ
    CMP.W       #$6F,D4                 * 6F = BLE
    BEQ         OP_BLE
    BRA         INVALID_OP              * If doesn't match the bytes from above then it's invalid

OP_CHECK_MOVEQ:
    BTST        #8,D7
    BNE         INVALID_OP              * If bit = 1 then INVALID
    BEQ         OP_MOVEQ                * If bit = 0 then MOVEQ

OP_NIBBLE_D:    * ADD, ADDA
    MOVE.W      D7,D4                   * Make sure we have the value in D4
    LSR.L       #6,D4                   * Move the wanted bits (bits: 6,7,8)
    AND.W       #%0000000000000111,D4   * Get rid of all other bits

    CMP.B       #%00000011,D4           * If op mode is 011 we know it's ADDA
    BEQ         OP_ADDA
    CMP.B       #%00000111,D4           * If op mode is 111 we know it's ADDA
    BEQ         OP_ADDA
    BRA         OP_ADD                  * If it's not 011 or 111 we assume it's ADD

OP_NIBBLE_E:    * LSL, LSR, ASL, ASR, ROL, ROR
    MOVE.W      D7,D4                   * To check between if it's LS, AS or RO we need to check the 3rd and 4th bits
    AND.W       #%1111111011000000,D4   * Must check if its an address shift or its a register shift
    
    * Begin by check if its an address shift
    CMP.W       #%1110000011000000,D4   * Exact ARx binary
    BEQ         OP_ASL_OR_ASR_NO_SIZE   * Going to no size version because the address shift is always a word
    CMP.W       #%1110001011000000,D4   * Exact LSx binary
    BEQ         OP_LSL_OR_LSR_NO_SIZE   * Going to no size version because the address shift is always a word
    CMP.W       #%1110011011000000,D4   * Exact ROx binary
    BEQ         OP_ROL_OR_ROR_NO_SIZE   * Going to no size version because the address shift is always a word

    * If not an address shift then check its if a register shift
    CLR         D4                      * Clear just to ensure there is nothing left over
    MOVE.W      D7,D4
    LSR.L       #3,D4                   * Move the bits we need to the right most places
    AND.W       #%0000000000000011,D4   * Get rid of all other bits
                                        * Note to compare Left or Right use the 8th bit of D2
    CMP.B       #$01,D4                 * If bits are 01 = LS
    BEQ         OP_LSL_OR_LSR
    CMP.B       #$00,D4                 * If bits are 00 = AS
    BEQ         OP_ASL_OR_ASR
    CMP.B       #$03,D4                 * If bits are 11 = RO
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


OP_LSL_OR_LSR_NO_SIZE:
    BTST        #8,D7
    BNE         OP_LSL_NO_SIZE                  * If bit = 1 then left
    BEQ         OP_LSR_NO_SIZE                  * If bit = 0 then right

OP_ASL_OR_ASR_NO_SIZE:
    BTST        #8,D7
    BNE         OP_ASL_NO_SIZE                  * If bit = 1 then left
    BEQ         OP_ASR_NO_SIZE                  * If bit = 0 then right

OP_ROL_OR_ROR_NO_SIZE:
    BTST        #8,D7
    BNE         OP_ROL_NO_SIZE                  * If bit = 1 then left
    BEQ         OP_ROR_NO_SIZE                  * If bit = 0 then right

*************************
*   Opcode Printing     *
*************************

OP_NOP:
    LEA         NopMsg,A1
    JSR         PRINT_MSG
    RTS

OP_NOT:
    LEA         NotMsg,A1
    JSR         PRINT_MSG
    JSR         OP_OPMODE_EA
    RTS

OP_MOVE_BYTE:
    LEA         MoveMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_BYTE
    BRA         OP_MOVE_EA

OP_MOVE_WORD:
    LEA         MoveMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_WORD
    BRA         OP_MOVE_EA

OP_MOVE_LONG:
    LEA         MoveMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_LONG
    BRA         OP_MOVE_EA

OP_MOVEA_WORD:
    LEA         MoveaMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_WORD
    BRA         OP_MOVE_EA

OP_MOVEA_LONG:
    LEA         MoveaMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_LONG
    BRA         OP_MOVE_EA

OP_MOVE_EA:
    JSR         MOVE_SEA
    JSR         MOVE_DEA
    JSR         PRINT_FINAL
    RTS

OP_MOVEM:
    LEA         MovemMsg,A1
    JSR         PRINT_MSG
    JSR         MOVEM_SUB
    MOVE.W      D7,D4
    LSR.L       #6,D4
    AND.B       #%00000001,D4
    CMP.B       #$00,D4
    BEQ         OP_MOVEM_WORD
    CMP.B       #$01,D4
    BEQ         OP_MOVEM_LONG
OP_MOVEM_WORD
    JSR         OP_PRINT_WORD
    BRA         OP_MOVEM_RET
OP_MOVEM_LONG
    JSR         OP_PRINT_LONG
OP_MOVEM_RET
    JSR         PRINT_FINAL
    RTS

OP_MOVEQ:
    LEA         MoveqMsg,A1
    JSR         PRINT_MSG
    JSR         MOVEQ_SUB
    JSR         PRINT_FINAL
    RTS

OP_LEA:
    LEA         LeaMsg,A1
    JSR         PRINT_MSG
    JSR         LEA_SUB
    JSR         PRINT_FINAL
    RTS
    
OP_ADD:
    LEA         AddMsg,A1
    JSR         PRINT_MSG
    JSR         OP_OPMODE_EA
    RTS
    
OP_ADDA:
    LEA         AddaMsg,A1
    JSR         PRINT_MSG
    JSR         ADDA_SUB
    JSR         PRINT_FINAL
    RTS

OP_ADDQ:
    LEA         AddqMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_OP_SIZE
    JSR         ADDQ_SUB
    JSR         PRINT_FINAL
    RTS

OP_SUB:
    LEA         SubMsg,A1
    JSR         PRINT_MSG
    JSR         OP_OPMODE_EA
    RTS

OP_OR:
    LEA         OrMsg,A1
    JSR         PRINT_MSG
    JSR         OP_OPMODE_EA
    RTS

OP_AND:
    LEA         AndMsg,A1
    JSR         PRINT_MSG
    JSR         OP_OPMODE_EA
    RTS

OP_OPMODE_EA:
    JSR         OPMODE_SUB
    JSR         PRINT_FINAL
    RTS


OP_JSR:
    LEA         JsrMsg,A1
    JSR         PRINT_MSG
    JSR         JSR_SUB
    JSR         PRINT_FINAL
    RTS

OP_RTS:
    LEA         RtsMsg,A1
    JSR         PRINT_MSG
    RTS

OP_BGT:
    LEA         BgtMsg,A1
    JSR         PRINT_MSG
    JSR         OP_BRANCHING_EA
    RTS 

OP_BEQ:
    LEA         BeqMsg,A1
    JSR         PRINT_MSG
    JSR         OP_BRANCHING_EA
    RTS

OP_BLE:
    LEA         BleMsg,A1
    JSR         PRINT_MSG
    JSR         OP_BRANCHING_EA
    RTS

OP_BRA:
    LEA         BraMsg,A1
    JSR         PRINT_MSG
    JSR         OP_BRANCHING_EA
    RTS

OP_BRANCHING_EA:
    JSR         DISP_8_BITS
    JSR         PRINT_FINAL
    RTS

* OP shifting (ASx LSx ROx)
* There are two subroutines for each op code because if affects an address than it doesn't need a size
*    Instead of printing a size we will print a space

OP_LSL:
    LEA         LslMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_OP_SIZE
    JSR         OP_SHIFTS_EA
    RTS

OP_LSR:
    LEA         LsrMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_OP_SIZE
    JSR         OP_SHIFTS_EA
    RTS

OP_ASL:
    LEA         AslMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_OP_SIZE
    JSR         OP_SHIFTS_EA
    RTS

OP_ASR:
    LEA         AsrMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_OP_SIZE
    JSR         OP_SHIFTS_EA
    RTS

OP_ROL:
    LEA         RolMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_OP_SIZE
    JSR         OP_SHIFTS_EA
    RTS

OP_ROR:
    LEA         RorMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_OP_SIZE
    JSR         OP_SHIFTS_EA
    RTS

OP_LSL_NO_SIZE:
    LEA         LslMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_SPACE
    JSR         OP_SHIFTS_EA
    RTS

OP_LSR_NO_SIZE:
    LEA         LsrMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_SPACE
    JSR         OP_SHIFTS_EA
    RTS

OP_ASL_NO_SIZE:
    LEA         AslMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_SPACE
    JSR         OP_SHIFTS_EA
    RTS

OP_ASR_NO_SIZE:
    LEA         AsrMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_SPACE
    JSR         OP_SHIFTS_EA
    RTS

OP_ROL_NO_SIZE:
    LEA         RolMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_SPACE
    JSR         OP_SHIFTS_EA
    RTS

OP_ROR_NO_SIZE:
    LEA         RorMsg,A1
    JSR         PRINT_MSG
    JSR         PRINT_SPACE
    JSR         OP_SHIFTS_EA
    RTS

OP_SHIFTS_EA:
    JSR         SHIFT_SUB
    JSR         PRINT_FINAL
    RTS

PRINT_OP_SIZE:  * Check the size of the instruction
    MOVE.B      #$01, ISLONG            * Require for D6
    MOVE.W      D7,D4
    LSR.L       #6,D4
    AND.B       #%00000011,D4
    CMP.B       #$00,D4                 * If bits are 00 then it's a byte
    BEQ         OP_PRINT_BYTE
    CMP.B       #$01,D4                 * If bits are 01 then it's a word 
    BEQ         OP_PRINT_WORD
    CMP.B       #$02,D4                 * If bits are 10 then it's a long
    BEQ         OP_PRINT_LONG
    JSR         PRINT_SPACE
    RTS                                 * If cannot find the sign then just return and act as if there is no sign
    
* Reason for these is so we can still rts after printing. Also easier to add in any other code here if needed
OP_PRINT_BYTE:
    JSR         PRINT_BYTE
    RTS

OP_PRINT_WORD:
    JSR         PRINT_WORD
    RTS

OP_PRINT_LONG:
    JSR         PRINT_LONG
    MOVE.B      #$02, ISLONG            * Require for D6
    RTS

*************************
*   Effective Address   *
*************************
*D7 has opcode
*D6 has Data
DST_REGI:
    MOVE.W  D7, D3
    ANDI.W  #$0E00 ,D3
    MOVE.B  #9,D1
    LSR.W   D1,D3
    MOVE.B  D3,$7000
    RTS
DST_MODE:
    MOVE.W  D7,D3
    ANDI.W  #$01C0,D3
    LSR.W   #6,D3
    MOVE.B  D3,$7001
    RTS
SRC_MODE:
    MOVE.W  D7, D3
    ANDI.W  #$0038 ,D3
    LSR.W   #3,D3
    MOVE.B  D3,$7002
    RTS
SRC_REGI:
    MOVE.B D7, $7003
    ANDI.B #$0007 ,$7003
    RTS

MOVE_SRC:                       * Addressing Register comparision
    CMPI.B  #0, $7003
    BEQ     WORD_SRC            * Word
    CMPI.B  #1, $7003
    BEQ     LONG_SRC            * Long
    CMPI.B  #4, $7003
    BEQ     IMM_DATA            * Immediate Register
    CMPI.B  #2, $7003
    BEQ     PC_D16              * (d16,PC)
    CMPI.B  #3, $7003
    BEQ     PC_D8               * (d8,PC,Xn)
    JSR     INVALID_EA
    RTS         *Change later
WORD_SRC:
    MOVE.B  #$24, (A2)+     * $
    JSR     READ_WORD
    JSR     DATA_SUB        * Data
    MOVE.B  $7100, (A2)+    * D6
    MOVE.B  $7101, (A2)+    * D6
    MOVE.B  $7102, (A2)+    * D6
    MOVE.B  $7103, (A2)+    * D6
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    *MOVE.L  D6,$4000 
    *MOVE.L  D5,D6
    RTS
LONG_SRC:
    MOVE.B  #$24, (A2)+     * $
    JSR     READ_LONG       * Read D6 for parameter
    MOVE.L  D6,$4000        *temp
    MOVE.B  #16,D2
    LSR.L   D2,D6   
    JSR     DATA_SUB        * Data
    MOVE.B  $7100, (A2)+    * D6
    MOVE.B  $7101, (A2)+    * D6
    MOVE.B  $7102, (A2)+    * D6
    MOVE.B  $7103, (A2)+    * D6
    MOVE.L  $4000,D6           
    JSR     DATA_SUB        * Data
    MOVE.B  $7100, (A2)+    * D6
    MOVE.B  $7101, (A2)+    * D6
    MOVE.B  $7102, (A2)+    * D6
    MOVE.B  $7103, (A2)+    * D6
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    *MOVE.L  D6,$4000 
    *MOVE.L  D5,D6
    RTS
IMM_DATA:
    MOVE.B  #$23, (A2)+     * #
    MOVE.B  #$24, (A2)+     * $

    * Read D6
    CMPI.B  #02,  ISLONG
    BEQ     READ_LONG_WORD    
    JSR     READ_WORD       * Read D6 for parameter
    BRA     CONT_POST_READ
READ_LONG_WORD
    JSR     READ_LONG
CONT_POST_READ
    JSR     DATA_SUB        * Data

    MOVE.B  $7100, (A2)+    * D6
    MOVE.B  $7101, (A2)+    * D6
    MOVE.B  $7102, (A2)+    * D6
    MOVE.B  $7103, (A2)+    * D6
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    MOVE.L  D6,$4000 
    MOVE.L  D5,D6
    RTS
PC_D16:
    MOVE.B  #$28, (A2)+     * (
    MOVE.B  #$24, (A2)+     * $
    JSR     READ_WORD       * Read D6 for parameter
    JSR     DATA_SUB        * Data
    MOVE.B  $7100, (A2)+    * D6
    MOVE.B  $7101, (A2)+    * D6
    MOVE.B  $7102, (A2)+    * D6
    MOVE.B  $7103, (A2)+    * D6
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$50, (A2)+     * P
    MOVE.B  #$43, (A2)+     * C
    MOVE.B  #$29, (A2)+     * )
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    MOVE.L  D6,$4000 
    MOVE.L  D5,D6
    RTS
PC_D8:
    MOVE.B  #$28, (A2)+     * (
    MOVE.B  #$24, (A2)+     * $
    JSR     READ_WORD       * Read D6 for parameter
    JSR     DATA8_SUB       * Data
    MOVE.B  $7100, (A2)+    * D6
    MOVE.B  $7101, (A2)+    * D6
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$50, (A2)+     * P
    MOVE.B  #$43, (A2)+     * C   
    MOVE.B  #$2C, (A2)+     * ,
    JSR     DATA8_SUB2
    MOVE.B  $7100, (A2)+
    MOVE.B  $7101, (A2)+
    MOVE.B  #$29, (A2)+     * )
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    MOVE.L  D6,$4000 
    MOVE.L  D5,D6
    RTS

MOVE_SEA:
    JSR     SRC_MODE
    JSR     SRC_REGI
    MOVEA.L #$7500,A2
MOVE_SEA2:   
    CMPI.B  #0, $7002
    BEQ     D_SEA           * D[n]
    CMPI.B  #1, $7002
    BEQ     A_SEA           * A[n]
    CMPI.B  #2, $7002
    BEQ     AIN_SEA         * (A[n])
    CMPI.B  #3, $7002
    BEQ     AP_SEA          * (A[n])+
    CMPI.B  #4, $7002
    BEQ     AM_SEA          * -(A[n])
    CMPI.B  #5, $7002
    BEQ     AD16_SEA        * (d16,A[n])
    CMPI.B  #6, $7002
    BEQ     AD8_SEA         * (d8,A[n],X[n])
    
    BRA     MOVE_SRC
    RTS
D_SEA:
    MOVE.B  #$44, (A2)+
    ADDI.B  #$30, $7003
    MOVE.B  $7003, (A2)+
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    RTS
A_SEA:
    MOVE.B  #$41, (A2)+
    ADDI.B  #$30, $7003
    MOVE.B  $7003, (A2)+
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    RTS
AIN_SEA:
    MOVE.B  #$28, (A2)+
    MOVE.B  #$41, (A2)+
    ADDI.B  #$30, $7003
    MOVE.B  $7003, (A2)+
    MOVE.B  #$29, (A2)+
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    RTS
AP_SEA:
    MOVE.B  #$28, (A2)+
    MOVE.B  #$41, (A2)+
    ADDI.B  #$30, $7003
    MOVE.B  $7003, (A2)+
    MOVE.B  #$29, (A2)+
    MOVE.B  #$2B, (A2)+
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    RTS    
AM_SEA:
    MOVE.B  #$2D, (A2)+
    MOVE.B  #$28, (A2)+
    MOVE.B  #$41, (A2)+
    ADDI.B  #$30, $7003
    MOVE.B  $7003, (A2)+
    MOVE.B  #$29, (A2)+
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    RTS
AD16_SEA:
    MOVE.B  #$28, (A2)+     * (
    MOVE.B  #$24, (A2)+     * $
    JSR     READ_WORD       * Read D6 for parameter
    JSR     DATA_SUB        * Data
    MOVE.B  $7100, (A2)+    * D6
    MOVE.B  $7101, (A2)+    * D6
    MOVE.B  $7102, (A2)+    * D6
    MOVE.B  $7103, (A2)+    * D6
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$41, (A2)+     * A
    ADDI.B  #$30, $7003
    MOVE.B  $7003, (A2)+    
    MOVE.B  #$29, (A2)+     * )
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    *MOVE.L  D6,$4000 
    *MOVE.L  D5,D6
    RTS
AD8_SEA:
    MOVE.B  #$28, (A2)+     * (
    MOVE.B  #$24, (A2)+     * $
    JSR     READ_WORD       * Read D6 for parameter
    JSR     DATA8_SUB       * Data
    MOVE.B  $7100, (A2)+    * D6
    MOVE.B  $7101, (A2)+    * D6
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$41, (A2)+     * A
    ADDI.B  #$30, $7003
    MOVE.B  $7003, (A2)+    
    MOVE.B  #$2C, (A2)+     * ,
    JSR     DATA8_SUB2
    MOVE.B  $7100, (A2)+
    MOVE.B  $7101, (A2)+
    MOVE.B  #$29, (A2)+     * )
    MOVE.B  #$2C, (A2)+     * ,
    MOVE.B  #$00,(A2)+      * NULL
    *MOVE.L  D6,$4000        *$4000 just for other stuff
    *MOVE.L  D5,D6
    RTS    
MOVE_DEA:
    JSR     DST_MODE
    JSR     DST_REGI
    MOVEA.L #$8000,A3
MOVE_DEA2:
    CMPI.B  #0, $7001
    BEQ     D_EA            * D[n]
    CMPI.B  #1, $7001
    BEQ     A_EA            * A[n]
    CMPI.B  #2, $7001
    BEQ     AIN_EA          * (A[n])
    CMPI.B  #3, $7001
    BEQ     AP_EA           * (A[n])+
    CMPI.B  #4, $7001
    BEQ     AM_EA           * -(A[n])
    CMPI.B  #5, $7001
    BEQ     AD16_EA         * (d16,A[n])
    CMPI.B  #6, $7001
    BEQ     AD8_EA          * (d8,A[n],X[n])
    BRA     MOVE_DR
MOVE_DR:                        * Addressing Register comparision
    CMPI.B  #0, $7000
    BEQ     WORD_DEA            * Word
    CMPI.B  #1, $7000
    BEQ     LONG_DEA            * Long
    JSR     INVALID_EA          
    RTS         *Change later
WORD_DEA:
    MOVE.B  #$24, (A3)+     * $
    JSR     READ_WORD       * Read D6 for parameter
    JSR     DATA_SUB        * Data
    MOVE.B  $7100, (A3)+    * D6
    MOVE.B  $7101, (A3)+    * D6
    MOVE.B  $7102, (A3)+    * D6
    MOVE.B  $7103, (A3)+    * D6
    *MOVE.B  #$2C, (A3)+     * ,
    MOVE.B  #$00,(A3)+      * NULL
    MOVE.L  D6,$4000 
    MOVE.L  D5,D6
    RTS
LONG_DEA:
    MOVE.B  #$24, (A3)+     * $
    JSR     READ_LONG       * Read D6 for parameter
    MOVE.L  D6,$4000        *temp
    MOVE.B  #16,D2
    LSR.L   D2,D6   
    JSR     DATA_SUB        * Data
    MOVE.B  $7100, (A3)+    * D6
    MOVE.B  $7101, (A3)+    * D6
    MOVE.B  $7102, (A3)+    * D6
    MOVE.B  $7103, (A3)+    * D6
    MOVE.L  $4000,D6           
    JSR     DATA_SUB        * Data
    MOVE.B  $7100, (A3)+    * D6
    MOVE.B  $7101, (A3)+    * D6
    MOVE.B  $7102, (A3)+    * D6
    MOVE.B  $7103, (A3)+    * D6
    *MOVE.B  #$2C, (A3)+     * ,
    MOVE.B  #$00,(A3)+      * NULL
    *MOVE.L  D6,$4000 
    *MOVE.L  D5,D6
    RTS

D_EA:
    MOVE.B  #$44, (A3)+
    ADDI.B  #$30, $7000
    MOVE.B  $7000, (A3)+
    MOVE.B  #$00,(A3)+      * NULL
    RTS
A_EA:
    MOVE.B  #$41, (A3)+
    ADDI.B  #$30, $7000
    MOVE.B  $7000, (A3)+
    MOVE.B  #$00,(A3)+      * NULL
    RTS
AIN_EA:
    MOVE.B  #$28, (A3)+
    MOVE.B  #$41, (A3)+
    ADDI.B  #$30, $7000
    MOVE.B  $7000, (A3)+
    MOVE.B  #$29, (A3)+
    MOVE.B  #$00,(A3)+      * NULL
    RTS
AP_EA:
    MOVE.B  #$28, (A3)+
    MOVE.B  #$41, (A3)+
    ADDI.B  #$30, $7000
    MOVE.B  $7000, (A3)+
    MOVE.B  #$29, (A3)+
    MOVE.B  #$2B, (A3)+
    MOVE.B  #$00,(A3)+      * NULL
    RTS    
AM_EA:
    MOVE.B  #$2D, (A3)+     * -
    MOVE.B  #$28, (A3)+     * (
    MOVE.B  #$41, (A3)+     * A
    ADDI.B  #$30, $7000     * 0-7 in ascii
    MOVE.B  $7000, (A3)+    * 0-7
    MOVE.B  #$29, (A3)+     * )
    MOVE.B  #$00,(A3)+      * NULL
    RTS
AD16_EA:
    MOVE.B  #$28, (A3)+     * (
    MOVE.B  #$24, (A3)+     * $
    JSR     READ_WORD       * Read D6 for parameter
    JSR     DATA_SUB        * Data
    MOVE.B  $7100, (A3)+    * D6
    MOVE.B  $7101, (A3)+    * D6
    MOVE.B  $7102, (A3)+    * D6
    MOVE.B  $7103, (A3)+    * D6
    MOVE.B  #$2C, (A3)+     * ,
    MOVE.B  #$41, (A3)+     * A
    ADDI.B  #$30, $7000
    MOVE.B  $7000, (A3)+    
    MOVE.B  #$29, (A3)+     * )
    MOVE.B  #$00,(A3)+      * NULL
    RTS
AD8_EA:
    MOVE.B  #$28, (A3)+     * (
    MOVE.B  #$24, (A3)+     * $
    JSR     READ_WORD       * Read D6 for parameter
    JSR     DATA8_SUB       * Data
    MOVE.B  $7100, (A3)+    * D6
    MOVE.B  $7101, (A3)+    * D6
    MOVE.B  #$2C, (A3)+     * ,
    MOVE.B  #$41, (A3)+     * A
    ADDI.B  #$30, $7000
    MOVE.B  $7000, (A3)+    
    MOVE.B  #$2C, (A3)+     * ,
    JSR     DATA8_SUB2
    MOVE.B  $7100, (A3)+
    MOVE.B  $7101, (A3)+
    MOVE.B  #$29, (A3)+     * )
    MOVE.B  #$00,(A3)+      * NULL
    RTS 
DATA_SUB:
        MOVE.W  D6, D0
        LSR.W   #8, D0
        LSR.W   #4, D0
        ANDI.W  #$000F, D0
        CMP.B   #9,D0
        BLE     NUM1
        SUBI.B  #9,D0
        ADD.B   #$40,D0
        BRA     NEXT1
NUM1    ADD.B   #$30,D0
NEXT1   MOVE.B  D0,$7100
        MOVE.W  D6, D0
        LSR.W   #8, D0
        ANDI.W  #$000F, D0
        CMP.B   #9,D0
        BLE     NUM2
        SUBI.B  #9,D0
        ADD.B   #$40,D0
        BRA     NEXT2
NUM2    ADD.B   #$30,D0
NEXT2   MOVE.B  D0,$7101
        MOVE.W  D6, D0
        LSR.W   #4, D0
        ANDI.W  #$000F, D0
        CMP.B   #9,D0
        BLE     NUM3
        SUBI.B  #9,D0
        ADD.B   #$40,D0
        BRA     NEXT3
NUM3    ADD.B   #$30,D0
NEXT3   MOVE.B  D0,$7102
        MOVE.W  D6, D0
        ANDI.W  #$000F, D0
        CMP.B   #9,D0
        BLE     NUM4
        SUBI.B  #9,D0
        ADD.B   #$40,D0
        BRA     NEXT4
NUM4    ADD.B   #$30,D0
NEXT4   MOVE.B  D0,$7103
        RTS
        

DATA8_SUB:
        MOVE.W  D6, D0
        LSR.W   #4, D0
        ANDI.W  #$0F, D0
        CMP.B   #9,D0
        BLE     NUM5
        SUBI.B  #9,D0
        ADD.B   #$40,D0
        BRA     NEXT5
NUM5    ADD.B   #$30,D0
NEXT5   MOVE.B  D0,$7100
        MOVE.W  D6, D0
        ANDI.W  #$000F, D0
        CMP.B   #9,D0
        BLE     NUM6
        SUBI.B  #9,D0
        ADD.B   #$40,D0
        BRA     NEXT6
NUM6    ADD.B   #$30,D0
NEXT6   MOVE.B  D0,$7101
        RTS
DATA8_SUB2:
        MOVE.W  D6, D0
        LSR.W   #8, D0
        LSR.W   #4, D0
        ANDI.W  #$000F, D0
        CMP.B   #8,D0
        BLT     NUM7
        MOVE.B  #$41,$7100
        BRA     NEXT7
NUM7    MOVE.B  #$44,$7100
NEXT7   ANDI.W  #$0007,D0
        ADD.B   #$30,D0
        MOVE.B  D0,$7101
        RTS

OPMODE_SUB:
    JSR     SRC_MODE
    JSR     SRC_REGI
    JSR     DST_MODE
    JSR     DST_REGI
    MOVEA.L #$7500,A2
    MOVEA.L #$8000,A3
    CMPI.B  #0, $7001
    BEQ     DD_BYTE             * 
    CMPI.B  #1, $7001
    BEQ     DD_WORD             * 
    CMPI.B  #2, $7001
    BEQ     DD_LONG             * 
    CMPI.B  #4, $7001
    BEQ     DS_BYTE             * 
    CMPI.B  #5, $7001
    BEQ     DS_WORD             * 
    CMPI.B  #6, $7001
    BEQ     DS_LONG             * 
    JSR     INVALID_EA
    RTS 
DD_BYTE:
    MOVE.B  #$2E, (A2)+            * .
    MOVE.B  #$42, (A2)+            * B
    MOVE.B  #$20, (A2)+            *  [Space]
    JSR     MOVE_SEA2
    MOVE.B  #$44, (A3)+            * D
    ADDI.B  #$30, $7000            * 0-7 in ascii
    MOVE.B  $7000, (A3)+           * 0-7
    MOVE.B  #$00,(A3)+             * NULL
    RTS
DD_WORD:
    MOVE.B  #$2E, (A2)+            * .
    MOVE.B  #$57, (A2)+            * W
    MOVE.B  #$20, (A2)+            *  [Space]
    JSR     MOVE_SEA2
    MOVE.B  #$44, (A3)+            * D
    ADDI.B  #$30, $7000            * 0-7 in ascii
    MOVE.B  $7000, (A3)+           * 0-7
    MOVE.B  #$00,(A3)+             * NULL
    RTS
DD_LONG:
    MOVE.B  #$2E, (A2)+            * .
    MOVE.B  #$4C, (A2)+            * L
    MOVE.B  #$20, (A2)+            *  [Space]
    JSR     MOVE_SEA2
    MOVE.B  #$44, (A3)+            * D
    ADDI.B  #$30, $7000            * 0-7 in ascii
    MOVE.B  $7000, (A3)+           * 0-7
    MOVE.B  #$00,(A3)+             * NULL
    RTS
DS_BYTE:
    MOVE.B  #$2E, (A2)+            * .
    MOVE.B  #$42, (A2)+            * B
    MOVE.B  #$20, (A2)+            *  [Space]
    MOVE.B  #$44, (A2)+            * D
    ADDI.B  #$30, $7000            * 0-7 in ascii
    MOVE.B  $7000, (A2)+           * 0-7
    MOVE.B  #$2C, (A2)+            * ,
    MOVE.B  #$00,(A2)+             * NULL
    MOVE.B  $7003,$7000
    MOVE.B  $7002,$7001
    JSR     MOVE_DEA2
    RTS
DS_WORD:
    MOVE.B  #$2E, (A2)+            * .
    MOVE.B  #$57, (A2)+            * W
    MOVE.B  #$20, (A2)+            *  [Space]
    MOVE.B  #$44, (A2)+            * D
    ADDI.B  #$30, $7000            * 0-7 in ascii
    MOVE.B  $7000, (A2)+           * 0-7
    MOVE.B  #$2C, (A2)+            * ,
    MOVE.B  #$00,(A2)+             * NULL
    MOVE.B  $7003,$7000
    MOVE.B  $7002,$7001    
    JSR     MOVE_DEA2
    RTS
DS_LONG:
    MOVE.B  #$2E, (A2)+            * .
    MOVE.B  #$4C, (A2)+            * L
    MOVE.B  #$20, (A2)+            *  [Space]
    MOVE.B  #$44, (A2)+            * D
    ADDI.B  #$30, $7000            * 0-7 in ascii
    MOVE.B  $7000, (A2)+           * 0-7
    MOVE.B  #$2C, (A2)+            * ,
    MOVE.B  #$00,(A2)+             * NULL
    MOVE.B  $7003,$7000
    MOVE.B  $7002,$7001
    JSR     MOVE_DEA2
    RTS
SHIFT_SUB:
    JSR     DST_REGI
    JSR     SRC_REGI
    MOVEA.L #$7500,A2
    MOVEA.L #$8000,A3
    MOVE.L  D7, D0
    ANDI.L  #$0020, D0 
    LSR.B   #5,D0                  * Shifting 7 bits
    MOVE.B  D0,$4000
    CMPI.B  #1,$4000
    BEQ     SHFT_CNT
    MOVE.B  #$23, (A2)+            * #
    BRA     SHFT_RET
SHFT_CNT
    MOVE.B  #$44, (A2)+            * D
SHFT_RET    
    ADDI.B  #$30, $7000            * 0-7 in ascii
    MOVE.B  $7000, (A2)+           * 0-7
    MOVE.B  #$2C, (A2)+            * ,
    MOVE.B  #$00,(A2)+             * NULL
    MOVE.B  #$44, (A3)+            * D
    ADDI.B  #$30, $7003            * 0-7 in ascii
    MOVE.B  $7003, (A3)+           * 0-7
    MOVE.B  #$00,(A3)+             * NULL
    RTS
        
MOVEQ_SUB:                          *MOVEQ Q Q Q
    JSR     DST_REGI
    MOVEA.L #$7500,A2
    MOVEA.L #$8000,A3
    MOVE.L  D7,D6
    MOVE.L  D7,D0
    ANDI.L  #$0080,D0 
    LSR.B   #7,D0                  *Shifting 7 bits
    MOVE.L  D0,$4000
    JSR     DATA8_SUB
    MOVE.B  #$23, (A2)+            * #
    MOVE.B  #$24, (A2)+            * $
    CMPI.B  #1,$4000
    BEQ     ONES 
    MOVE.B  #$30, (A2)+            * 0
    MOVE.B  #$30, (A2)+            * 0
    MOVE.B  #$30, (A2)+            * 0
    MOVE.B  #$30, (A2)+            * 0
    MOVE.B  #$30, (A2)+            * 0
    MOVE.B  #$30, (A2)+            * 0
    BRA     ZEROS
ONES
    MOVE.B  #$46, (A2)+            * F
    MOVE.B  #$46, (A2)+            * F
    MOVE.B  #$46, (A2)+            * F
    MOVE.B  #$46, (A2)+            * F
    MOVE.B  #$46, (A2)+            * F
    MOVE.B  #$46, (A2)+            * F
ZEROS
    MOVE.B  $7100,(A2)+            * The hex value in DATA
    MOVE.B  $7101,(A2)+            *
    MOVE.B  #$2C, (A2)+            * ,
    MOVE.B  #$00,(A2)+             * NULL
    MOVE.B  #$44, (A3)+            * D
    ADDI.B  #$30, $7000            * 0-7 in ascii
    MOVE.B  $7000, (A3)+           * 0-7
    MOVE.B  #$00,(A3)+             * NULL
    RTS
ADDA_SUB:
    JSR     SRC_MODE
    JSR     SRC_REGI
    JSR     DST_MODE
    JSR     DST_REGI
    MOVEA.L #$7500,A2
    MOVEA.L #$8000,A3
    CMPI.B  #3, $7001
    BEQ     ADD_WORD             * 
    CMPI.B  #7, $7001
    BEQ     ADD_LONG             * 
ADD_WORD
    MOVE.B  #$2E, (A2)+            * .
    MOVE.B  #$57, (A2)+            * W
    MOVE.B  #$20, (A2)+            *  [Space]
    JSR     MOVE_SEA2
    MOVE.B  #$41, (A3)+            * A
    ADDI.B  #$30, $7000            * 0-7 in ascii
    MOVE.B  $7000, (A3)+           * 0-7
    MOVE.B  #$00,(A3)+             * NULL
    RTS
ADD_LONG
    MOVE.B  #$2E, (A2)+            * .
    MOVE.B  #$4C, (A2)+            * L
    MOVE.B  #$20, (A2)+            *  [Space]
    JSR     MOVE_SEA2
    MOVE.B  #$41, (A3)+            * A
    ADDI.B  #$30, $7000            * 0-7 in ascii
    MOVE.B  $7000, (A3)+           * 0-7
    MOVE.B  #$00,(A3)+             * NULL
    RTS
ADDQ_SUB:
    JSR     SRC_MODE
    JSR     SRC_REGI
    JSR     DST_REGI
    MOVEA.L #$7500,A2
    MOVEA.L #$8000,A3
    MOVE.B  #$23, (A2)+            * #
    MOVE.B  #$24, (A2)+            * $
    ADDI.B  #$30, $7000            * 0-7 in ascii
    MOVE.B  $7000, (A2)+           * 0-7
    MOVE.B  #$2C, (A2)+            * ,
    MOVE.B  #$00,(A2)+             * NULL
    MOVE.B  $7003,$7000
    MOVE.B  $7002,$7001
    JSR     MOVE_DEA2
    RTS
MOVEM_SUB:
    JSR     SRC_MODE
    JSR     SRC_REGI
    JSR     READ_WORD              * Read D6 for parameter
    MOVEA.L #$7500,A2
    MOVEA.L #$8000,A3
    CMPI.B  #0,$7002
    BEQ     INVALID_EA
    CMPI.B  #1,$7002
    BEQ     INVALID_EA
*    CMPI.B  #3,$7002
*    BEQ     INVALID_EA
    CMPI.B  #7,$7002
    BEQ     MOVEMIN

MOVEMBACK    
    *BTST    #10, D7
    *BEQ     CONT_REV
    CMPI.B  #4, $7002
    BEQ CONT1
CONT_REV
    
    MOVE.W #0, D0
    MOVE.W #0, CNTRI
    MOVE.W #0, CNTRJ
    MOVE.W #0, REVERSEBITS
LOOP_BIT  
    MOVE.W D6, $4004
    MOVE.W #1, D1  
    LSL.W  D0, D1
    AND.W  D1, $4004
    
    CMPI.W #0, $4004
    BEQ CONT_LOOP
    MOVE.W #$F, D1
    SUB.W  D0, D1
    MOVE.W #1, D2
    LSL.W  D1, D2
    OR.W  D2,  REVERSEBITS
   
    
CONT_LOOP 
    ADDI.W #$1, D0
    CMPI.W #$10, D0
    BNE LOOP_BIT
    MOVE.W REVERSEBITS, D6
    
CONT1    
  MOVE.W  D7, D0
    ANDI.W  #$0400, D0 
    LSR.W   #8,D0                  *Shifting 8 bits
    LSR.W   #2,D0                  *Shifting 2 bits
    MOVE.B  D0,$4000
    CMPI.B  #1,$4000                * is direction 1
    BEQ     MOVE_MEM_TO_REG
    
    BRA     MOVE_REG_TO_MEM       *BREAK


MOVE_MEM_TO_REG
    JSR     MOVE_SEA2
    MOVE.B  D6,D0
    CMPI.B  #0,D0
    BEQ     MOVEM_AN
    MOVE.B  #0,D1
MOVEM_LOOP0    
    LSR.B   D1,D0
    ANDI.B  #01,D0
    CMPI.B  #0,D0
    BEQ     MOVEM_LOOP1            
        
    MOVE.B  #$41, (A3)+            * A
    *MOVE.B  D1, (A3)              * the start
    MOVE.B  #7,   (A3)
    SUB.B   D1, (A3)
    ADDI.B  #$30, (A3)+               * start in ascii
    MOVE.B  #$2F, (A3)+            * /
MOVEM_LOOP1
    ADDI.B  #1,D1
    MOVE.B  D6,D0
    CMPI.B  #8,D1
    BNE     MOVEM_LOOP0
    
MOVEM_AN   
    MOVE.W  D6,$4500
    MOVE.B  $4500,D0
    CMPI.B  #0,D0
    BEQ     MOVEM_AN2_REMOVE
    MOVE.B  #0,D1
MOVEM_LOOP3    
    LSR.B   D1,D0
    ANDI.B  #01,D0
    CMPI.B  #0,D0
    BEQ     MOVEM_LOOP4            
        
    MOVE.B  #$44, (A3)+            * D
    *MOVE.B  D1, (A3)
    MOVE.B  #7,   (A3)
    SUB.B   D1, (A3)
    ADDI.B  #$30, (A3)+               * start in ascii
    MOVE.B  #$2F, (A3)+            * /
MOVEM_LOOP4
    ADDI.B  #1,D1
    MOVE.B  $4500,D0
    CMPI.B  #8,D1
    BNE     MOVEM_LOOP3
MOVEM_AN2_REMOVE
    SUBA.W  #1,A3
    
MOVEM_AN2
      
    BRA     MOVEM_OUT
    
MOVE_REG_TO_MEM 
    MOVE.B  D6,D0
    CMPI.B  #0,D0
    BEQ     MOVEM_AN3
    MOVE.B  #0,D1
MOVEM_LOOP5    
    LSR.B   D1,D0
    ANDI.B  #01,D0
    CMPI.B  #0,D0
    BEQ     MOVEM_LOOP6            
        
    MOVE.B  #$41, (A2)+            * A
    *MOVE.B  D1,   (A2)
    MOVE.B  #7,   (A2)
    SUB.B   D1, (A2)
    ADDI.B  #$30, (A2)+               * start in ascii
    MOVE.B  #$2F, (A2)+            * /
MOVEM_LOOP6
    ADDI.B  #1,D1
    MOVE.B  D6,D0
    CMPI.B  #8,D1
    BNE     MOVEM_LOOP5
MOVEM_AN3   
    MOVE.W  D6,$4500
    MOVE.B  $4500,D0
    CMPI.B  #0,D0
    BEQ     MOVEM_AN4_REMOVE
    MOVE.B  #0,D1
MOVEM_LOOP7    
    LSR.B   D1,D0
    ANDI.B  #01,D0
    CMPI.B  #0,D0
    BEQ     MOVEM_LOOP8            
        
    
    MOVE.B  #$44, (A2)+            * D
    MOVE.B  #7,   (A2)
    SUB.B   D1, (A2)
    ADDI.B  #$30, (A2)+               * start in ascii
    MOVE.B  #$2F, (A2)+            * /
MOVEM_LOOP8
    ADDI.B  #1,D1
    MOVE.B  $4500,D0
    CMPI.B  #8,D1
    BNE     MOVEM_LOOP7
MOVEM_AN4_REMOVE
    SUBA.W  #1,A2
MOVEM_AN4
    MOVE.B  #$2C, (A2)+            * ,  
    MOVE.B  $7003,$7000
    MOVE.B  $7002,$7001  
    JSR     MOVE_DEA2
    BRA     MOVEM_OUT

MOVEMIN
    CMPI.B  #2,7003
    BGE     INVALID_EA
    BRA     MOVEMBACK
MOVEM_OUT
    MOVE.B  #$00,(A2)+             * NULL
    MOVE.B  #$00,(A3)+             * NULL
    RTS
LEA_SUB:
    MOVEA.L #$7500,A2
    MOVEA.L #$8000,A3
    JSR     SRC_MODE
    JSR     SRC_REGI
    JSR     DST_MODE
    JSR     DST_REGI
    CMPI.B  #0,$7002
    BEQ     INVALID_EA
    CMPI.B  #1,$7002
    BEQ     INVALID_EA
    CMPI.B  #3,$7002
    BEQ     INVALID_EA
    CMPI.B  #4,$7002
    BEQ     INVALID_EA
    CMPI.B  #7,$7002
    BEQ     LEA_ERROR
LEA_BACK
    JSR MOVE_SEA2
    MOVE.B  #$41, (A3)+     * A
    ADDI.B  #$30, $7000     * 0-7 in ascii
    MOVE.B  $7000, (A3)+    * 0-7
    MOVE.B  #$00,(A3)+      * NULL
    BRA     LEA_AFTER
LEA_ERROR
    CMPI.B  #2,$7003
    BGE     INVALID_EA
    BRA     LEA_BACK
LEA_AFTER
    RTS
JSR_SUB:
    MOVEA.L #$7500,A2
    MOVEA.L #$8000,A3
    JSR     SRC_MODE
    JSR     SRC_REGI
    JSR     DST_MODE
    JSR     DST_REGI
    CMPI.B  #0,$7002
    BEQ     INVALID_EA
    CMPI.B  #1,$7002
    BEQ     INVALID_EA
    CMPI.B  #3,$7002
    BEQ     INVALID_EA
    CMPI.B  #4,$7002
    BEQ     INVALID_EA
    CMPI.B  #7,$7002
    BEQ     JSR_ERROR
JSR_BACK
    MOVE.B  $7003,$7000
    MOVE.B  $7002,$7001
    JSR     MOVE_DEA2
    BRA     JSR_AFTER
JSR_ERROR
    CMPI.B  #2,$7003
    BGE     INVALID_EA
    BRA     JSR_BACK
JSR_AFTER
    RTS
NOT_SUB:
    MOVEA.L #$7500,A2
    MOVEA.L #$8000,A3
    JSR     SRC_MODE
    JSR     SRC_REGI
    JSR     DST_MODE
    JSR     DST_REGI
    CMPI.B  #1,$7002
    BEQ     INVALID_EA
    CMPI.B  #7,$7002
    BEQ     NOT_ERROR
NOT_BACK
    MOVE.B  $7003,$7000
    MOVE.B  $7002,$7001
    JSR     MOVE_DEA2
    BRA     NOT_AFTER
NOT_ERROR
    CMPI.B  #2,$7003
    BGE     INVALID_EA
    BRA     NOT_BACK
NOT_AFTER
    RTS

PRINT_FINAL
    MOVE.B  #$00,(A2)+      *NULL
    MOVEA.L #$7500,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #$00,(A3)+      *NULL    
    MOVEA.L #$8000,A1
    MOVE.B  #14,D0
    TRAP    #15
    RTS
INVALID_EA:
    LEA     MSG_INVALID_EA,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #$00,(A2)+             * NULL
    MOVE.B  #$00,(A3)+             * NULL
    RTS
*************************
*  8-Bit Displacement+   *
*************************
DISP_8_BITS:
    MOVE.W  D7, D3          *Move the Opcode to D3
    ANDI.W  #$00FF ,D3      *Takes the last 8 bits of opcode
    MOVE.B  D3,$7000        *Storing it in 7000 for safe keeping
    MOVE.L  A5,D5           
    BTST    #7,D3
    BNE     NDISP_8_BIT     *If it is a negative number it take two's complement 
    ADD.L   D3,D5           *Add 8-bits to PC
    BRA     DISP_8_RET
NDISP_8_BIT                 *Two's complement instructions
    SUB.B   #$1,D3          *subtract 1
    NOT.B   D3              *flip the bits
    SUB.L   D3,D5           *subtract 8-bits from PC
    
DISP_8_RET
    MOVEA.L #$7500,A2       
    MOVE.L  D5,D6
    MOVE.B  #$24, (A2)+     * $
    MOVE.B  #16,D2          *
    LSR.L   D2,D6           * convert the higher word to ascii hex
    JSR     DATA_SUB        * Data
    MOVE.B  $7100, (A2)+    * D6
    MOVE.B  $7101, (A2)+    * D6
    MOVE.B  $7102, (A2)+    * D6
    MOVE.B  $7103, (A2)+    * D6
    MOVE.L  D5,D6           
    JSR     DATA_SUB        * Data
    MOVE.B  $7100, (A2)+    * D6
    MOVE.B  $7101, (A2)+    * D6
    MOVE.B  $7102, (A2)+    * D6
    MOVE.B  $7103, (A2)+    * D6
    MOVE.B  #$00,(A2)+      * NULL    
    RTS    

*************************
*        Tests          *
*************************
RUN_ALL_TESTS:
    JSR         CHECK_EACH_OP
    RTS

* Runs get op code against a known opcode value to see if it is correctly found
* Prints out what is expected followed by what is found. If these are different there is an issue

CHECK_EACH_OP:
    MOVE.L      #$00000000,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000A000,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000B000,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000F000,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00001000,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00005842,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00007211,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00008000,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00009000,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000C000,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00002A03,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00002449,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00003607,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00003449,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00004600,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00004E75,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00004E71,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00004EB8,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$000048A7,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$000043F8,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00006000,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00006E00,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00006700,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$00006F00,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000D4C9,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000D249,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000E10F,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000E00F,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000E100,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000E000,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000E75C,D7
    JSR         TEST_RUN_NIBBLE_TEST
    MOVE.L      #$0000E65C,D7
    JSR         TEST_RUN_NIBBLE_TEST
    RTS

TEST_RUN_NIBBLE_TEST:
    JSR         GET_OP_CODE
    JSR         PRINT_NEWLINE
    RTS

*************************
*         End           *
*************************
DONE:
    SIMHALT                 ; halt simulator

    END    START        ; last line of source









