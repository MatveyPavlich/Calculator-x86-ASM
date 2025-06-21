; Calculator - v1.3 (2025-06-16)
; Supports 1-digit numbers only
; Improvements:
; - Code comments added
; - Macro for input check
; - Add flush check logic to remove bug that previously required to press ENTER two times before seeing an ERROR message about input being too long

%define SYS_READ     3
%define SYS_WRITE    4
%define SYS_EXIT     1

%define FD_STDIN     0
%define FD_STDOUT    1

%define num1         memory_buffer
%define num1_len     memory_buffer + 4
%define num2         memory_buffer + 8
%define num2_len     memory_buffer + 12
%define op           memory_buffer + 16
%define result       memory_buffer + 20
%define equation     memory_buffer + 24

%macro print 2
    ; (%1) - label able for the string
    ; (%2) - length of the string

    MOV eax, SYS_WRITE
    MOV ebx, FD_STDOUT
    MOV ecx, %1
    MOV edx, %2
    INT 0x80
%endmacro

%macro read 2
    ; (%1) - memory address to store the read
    ; (%2) - max number of bytes to read

    MOV eax, SYS_READ
    MOV ebx, FD_STDIN
    MOV ecx, %1
    MOV edx, %2
    INT 0x80
%endmacro

%macro flush_check 1
    ; Check if the last value from the original read is a newline
    ; - If yes, skip the memory buffer cleaning
    ; - If no, clean the input so that it would not overflow into a next terminal prompt
    ; - NOT ENTIRELY SURE WHAT IS HAPPENING HERE YET. I.e., why am I getting an overflow that triggers next command in a terminal; how come after flush I need to do 22 ENTER ENTER to get a mistake and how this solves it

    CMP BYTE [(%1) + eax - 1], 0x0A
    JE %%skip_flush
    CALL flush_stdin
%%skip_flush:
%endmacro

%macro input_check 1
    ; (%1) - input buffer address

    ; Check if only ENTER was pressed
    CMP eax, 1
    JE error_print_enter_pressed

    ; See if signed value
    MOV dl, 0               ; offset for the digit byte = 0 by default
    CMP BYTE [%1], '-'
    JE %%signed_val
    CMP BYTE [%1], '+'
    JE %%signed_val
    JMP %%check_digit

%%signed_val:
    MOV dl, 1               ; skip the '+' or '-'

%%check_digit:
    ; Check if digit is valid
    MOV al, BYTE [%1 + edx] ; Add an offset to get the actual number
    CMP al, '0'
    JB %%invalid_char
    CMP al, '9'
    JA %%invalid_char

    ; Check if the next char is newline
    MOV al, BYTE [%1 + edx + 1]
    CMP al, 0x0A
    JNE %%too_long

    JMP %%ok

%%invalid_char:
    flush_check %1
    JMP error_ivalid_character

%%too_long:
    flush_check %1
    JMP error_print

%%ok:
%endmacro


section .data
    text1                  DB 0x0A, "|------Calculator-App-------|", 0x0A, 0x00 
    lent1                  EQU $ - text1

    text2                  DB "Enter your 1st number: ", 0x00 
    lent2                  EQU $ - text2

    text3                  DB "Enter your 2nd number: ", 0x00 
    lent3                  EQU $ - text3

    text4                  DB "Avaliable Operations: (1) Add (2) Sub (3) Mul (4) Div", 0x0A, 0x00 
    lent4                  EQU $ - text4

    text5                  DB "Pick an operation: ", 0x00
    len5                   EQU $ - text5

    output_msg             DB "Output: ", 0x00
    output_msg_len         EQU $ - output_msg

    ; Error messages     
    error_text             DB "ERROR: one digit max O_o", 0x00
    error_text_length      EQU $ - error_text

    error_no_number        DB "ERROR: no number given -_-"
    error_no_num_len       EQU $ - error_no_number

    error_div_zero         DB "ERROR: cannot divide by zero", 0x00
    error_div_zero_len     EQU $ - error_div_zero

    error_invalid_char     DB "ERROR: invalid character", 0x00
    error_invalid_char_len EQU $ - error_invalid_char

    end_print              DB 0xA, 0x00
    end_print_len          EQU $ - end_print

    red_start              DB 0x1B, "[31m", 0 
    red_start_len          EQU $ - red_start

    reset_colour           DB 0x1B, "[0m", 0
    reset_colour_len       EQU $ - reset_colour

section .bss
    memory_buffer RESB 100

section .text
global _start

_start:
    ; Print intro
    print text1, lent1
    
    ; Get the first value
    print text2, lent2
    read num1, 10
    input_check num1

    ; Get the second value
    print text3, lent3
    read num2, 10
    input_check num2

    ; Get the third value
    print text4, lent4
    print text5, len5
    read op, 2
    input_check op

    ; ASCII -> INT for opperation
    MOV cl, [op]
    SUB cl, '0'
    JMP identify_first_num

identify_first_num:
    ; ASCII -> INT for input number
    MOV ah, [num1]
    MOV al, [num1 + 1]
    CMP ah, '-'
    JE negative_logic
    
    ; Non negative
    MOV [equation], al
    MOV al, 0
    MOV al, ah
    SUB al, '0'
    JMP identify_second_num

negative_logic:
    ; TODO: fix printing of the equation since now will have 2 bytes
    MOV [equation], ah           ; for printing final equation
    MOV [equation + 1], al
    SUB al, '0' 
    NEG al
    JMP identify_second_num

identify_second_num:
    MOV bl, [num2]
    MOV [equation + 3], bl       ; for printing final equation
    SUB bl, '0'
    MOV BYTE [equation + 4], '=' ; for printing final equation
    JMP identify_operation


identify_operation:
    ; Identify opereration
    CMP cl, 1
    JE addition
    CMP cl, 2
    JE subtract
    CMP cl, 3
    JE multiply
    CMP cl, 4
    JE divide
    JMP exit


; --------------- Math opperation functions ---------------
addition:
    MOV BYTE [equation + 2], '+'
    ADD al, bl

    JS .negative
    CALL int_to_ascii
    JMP print_result
.negative:
    NEG al
    MOV BYTE [equation + 5], '-'
    CALL int_to_ascii
    JMP print_result


subtract:
    MOV BYTE [equation + 1], '-'
    SUB al, bl
    CALL int_to_ascii
    JMP print_result

multiply:
    MOV BYTE [equation + 1], '*'
    MUL bl
    CALL int_to_ascii
    JMP print_result

divide:
    MOV BYTE [equation + 1], '/'
    CMP bl, 0
    JE error_divide_by_zero
    MOV ah, 0
    DIV bl
    CALL int_to_ascii
    JMP print_result


; --------------- Printing errors ---------------
red_error_message_colour_on:
    print red_start, red_start_len
    RET

red_error_message_colour_off:
    print reset_colour, reset_colour_len
    RET

error_print_enter_pressed:
    CALL red_error_message_colour_on
    print error_no_number, error_no_num_len
    CALL red_error_message_colour_off
    JMP exit

error_print:
    CALL red_error_message_colour_on
    print error_text, error_text_length
    CALL red_error_message_colour_off
    JMP exit

error_ivalid_character:
    CALL red_error_message_colour_on
    print error_invalid_char, error_invalid_char_len
    CALL red_error_message_colour_off
    JMP exit

error_divide_by_zero:
    CALL red_error_message_colour_on
    print error_div_zero, error_div_zero_len
    CALL red_error_message_colour_off
    JMP exit


; -------------- Conversion between formats -------------------------
int_to_ascii:
    ; Convert int to ascii by separating 10^1 and 10^0
    MOV ah, 0            ; Clean ah since will store the remainder after division
    MOV bl, 10           ; divisor
    DIV bl               ; do al / 10
    ADD al, '0'
    MOV [result], al
    MOV al, ah
    ADD al, '0'
    MOV [result + 1], al
    RET

; --------------- Printing statements ---------------
print_result:
    print output_msg, output_msg_len
    MOV ax, 0
    
    ; If the first byte is 0 => skip (i.e., avoid printing 2 as 02)
    CMP BYTE [result], '0'
    JE .print_one_digit
    
    ; Otherwise print 2 numbers
    MOV ax, [result]
    MOV [equation + 5], ax
    print equation, 7
    JMP exit
.print_one_digit:
    MOV al, [result + 1]
    MOV [equation + 5], al
    print equation, 6
    JMP exit

exit:
    print end_print, end_print_len
    MOV eax, SYS_EXIT
    MOV ebx, 0
    INT 0x80

flush_stdin:
.flush_loop:
    read memory_buffer, 1
    CMP eax, 0
    JE .flush_end
    CMP BYTE [memory_buffer], 0x0A
    JNE .flush_loop
.flush_end:
    RET
