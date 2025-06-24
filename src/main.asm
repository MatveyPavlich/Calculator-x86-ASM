; Calculator - v1.4 (2025-06-16)
; Supports 1-digit numbers only
; Improvements:
; - 2 digit result is avaliable (e.g. 8*8 does not return giberish)
; - Full equation is printed in the output
; - Code made more modular by creating data.asm and functions.asm

%define num1         memory_buffer
%define num2         memory_buffer + 3
%define op           memory_buffer + 6
%define result       memory_buffer + 9
%define equation     memory_buffer + 12
    
%include "./src/data.asm"
%include "./src/functions.asm"

section .text
global _start

_start:
    ; Get all values
    print welcome_msg, welcome_msg_len   ; Print welcome message
    print ask_input_1, ask_input_1_len   ; Ask user for the first operand
    read num1, 10                        ; Read user input using a syscall
    input_check num1                     ; Check the input is valid
    print show_oprtns, show_oprtns_len   ; Display available operations
    print ask_oprtn, ask_oprtn_len       ; Ask user for the operation
    read op, 2                           ; Read user input using a syscall
    input_check op                       ; Check the input is valid
    print ask_input_2, ask_input_2_len   ; Ask user for the second operand
    read num2, 10                        ; Read user input using a syscall
    input_check num2                     ; Check the input is valid

    ; ASCII -> INT conversion
    MOV cl, [op]                         ; Move the opperation code into cl
    SUB cl, '0'                          ; Covert ascii to int
    MOV al, [num1]                       ; Move num1 into al
    MOV [equation], al                   ; Write al into memory to print enquation later
    SUB al, '0'                          ; Covert ascii to int
    MOV bl, [num2]                       ; Move num2 into bl
    MOV [equation + 2], bl               ; Write bl into memory to print enquation later
    SUB bl, '0'                          ; Covert ascii to int
    MOV BYTE [equation + 3], '='         ; Write = into memory to print equation later

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