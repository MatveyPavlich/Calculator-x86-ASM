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