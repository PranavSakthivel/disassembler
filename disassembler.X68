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



    ORG    $1000
START:                  ; first instruction of program
    JSR         GET_USER_STR
    JSR         PRINT_STR

SIMHALT                 ; halt simulator


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
OP_MOVE:
    * Code *

*************************
*        Other          *
*************************



    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
