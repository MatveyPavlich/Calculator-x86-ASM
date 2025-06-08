section .data
    text1 DB  0x0A, '|------Calculator-App-------', 0x0A, 0x00 
    lent1 EQU $ - text1

    text2 DB  0x0A, 'Enter your 1st number: ', 0x0A, 0x00 
    lent2 EQU $ - text2

    text3 DB  0x0A, 'Enter your 2nd number: ', 0x0A, 0x00 
    lent3 EQU $ - text3

    text4 DB  0x0A, '1. Add',                  0x0A, 0x00 
    lent4 EQU $ - text4


section .bss
    num1 RESB 2
    num2 RESB 2
    opp  RESB 2
    res  RESB 2

section .text
    
global _start

_start:
    ; Print message 1
    MOV eax,4
    MOV ebx,1
    MOV ecx,text1
    MOV edx,lent1
    INT 80h

    ; Print message 2
    MOV eax,4
    MOV ebx,1
    MOV ecx,text2
    MOV edx,lent2
    INT 80h

    ; Print message 3
    MOV eax,4
    MOV ebx,1
    MOV ecx,text3
    MOV edx,lent3
    INT 80h

    ; Print message 4
    MOV eax,4
    MOV ebx,1
    MOV ecx,text4
    MOV edx,lent4
    INT 80h

    ; Exit the program
    MOV eax,1
    MOV ebx,0
    INT 80h


