; Calculator - v1.4 (2025-06-16)
; Supports 1-digit numbers only
; Improvements:
; - 2 digit result is avaliable (e.g. 8*8 does not return giberish)
; - Full equation is printed in the output
; - Code made more modular by creating data.asm and functions.asm


%define SYS_READ     3
%define SYS_WRITE    4
%define SYS_EXIT     1

%define FD_STDIN     0
%define FD_STDOUT    1

%define num1         memory_buffer
%define num2         memory_buffer + 2
%define op           memory_buffer + 4
%define result       memory_buffer + 6
%define equation     memory_buffer + 10

; Not sure why this should be above the data section though
section .bss
    memory_buffer RESB 100
    
%include "./src/data.asm"
%include "./src/functions.asm"

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
    
    ; ASCII -> INT for input number
    MOV al, [num1]
    MOV [equation], al           ; for printing final equation
    SUB al, '0'
    MOV bl, [num2]
    MOV [equation + 2], bl       ; for printing final equation
    SUB bl, '0'
    MOV BYTE [equation + 3], '=' ; for printing final equation

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
    MOV BYTE [equation + 1], '+'
    ADD al, bl
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
    MOV [equation + 4], ax
    print equation, 6
    JMP exit
.print_one_digit:
    MOV al, [result + 1]
    MOV [equation + 4], al
    print equation, 5
    JMP exit

flush_stdin:
.flush_loop:
    read memory_buffer, 1
    CMP eax, 0
    JE .flush_end
    CMP BYTE [memory_buffer], 0x0A
    JNE .flush_loop
.flush_end:
    RET
