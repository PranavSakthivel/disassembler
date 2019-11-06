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
    MOVE.L      #$FFFFFFFF,D2
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
* Assumes binary is in D2 
* Uses D3

GET_OP_CODE:
    MOVE.L      D2,D3
    AND.L       #$0000000F,D3           * We only want to test the right most nibble, get rid of all other bits
    
    CMP.B       #00,D3                  * Check if nibble = 0
    BEQ         INVALID_NIBBLE
    CMP.B       #01,D3                  * Check if nibble = 1
    BEQ         OP_NIBBLE_1
    CMP.B       #02,D3                  * Check if nibble = 2
    BEQ         OP_NIBBLE_2
    CMP.B       #03,D3                  * Check if nibble = 3
    BEQ         OP_NIBBLE_3
    CMP.B       #04,D3                  * Check if nibble = 4
    BEQ         OP_NIBBLE_4
    CMP.B       #05,D3                  * Check if nibble = 5
    BEQ         OP_NIBBLE_5
    CMP.B       #06,D3                  * Check if nibble = 6
    BEQ         OP_NIBBLE_6
    CMP.B       #07,D3                  * Check if nibble = 7
    BEQ         OP_NIBBLE_7
    CMP.B       #08,D3                  * Check if nibble = 8
    BEQ         OP_NIBBLE_8
    CMP.B       #09,D3                  * Check if nibble = 9
    BEQ         OP_NIBBLE_9
    CMP.B       #0A,D3                  * Check if nibble = A
    BEQ         OP_NIBBLE_A
    CMP.B       #0B,D3                  * Check if nibble = B
    BEQ         OP_NIBBLE_B
    CMP.B       #0C,D3                  * Check if nibble = C
    BEQ         OP_NIBBLE_C
    CMP.B       #0D,D3                  * Check if nibble = D
    BEQ         OP_NIBBLE_D
    CMP.B       #0E,D3                  * Check if nibble = E
    BEQ         OP_NIBBLE_E
    CMP.B       #0F,D3                  * Check if nibble = F
    BEQ         INVALID_NIBBLE
    BRA         INVALID_NIBBLE          * Assume if we haven't branched yet something is wrong
    

INVALID_NIBBLE:


OP_NIBBLE_1:

OP_NIBBLE_2:

OP_NIBBLE_3:

OP_NIBBLE_4:

OP_NIBBLE_5:

OP_NIBBLE_6:

OP_NIBBLE_7:

OP_NIBBLE_8:

OP_NIBBLE_9:

OP_NIBBLE_A:

OP_NIBBLE_B:

OP_NIBBLE_C:

OP_NIBBLE_D:

OP_NIBBLE_E:

OP_NIBBLE_F:



OP_MOVE:
    * Code *

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
