; Calculator is working for 2-digit numbers max!

section .data
    text1 DB  0x0A, '|------Calculator-App-------|', 0x0A, 0x00 
    lent1 EQU $ - text1

    text2 DB  'Enter your 1st number: ', 0x0A, 0x00 
    lent2 EQU $ - text2

    text3 DB  'Enter your 2nd number: ', 0x0A, 0x00 
    lent3 EQU $ - text3

    text4 DB  '1. Add',                  0x0A, 0x00 
    lent4 EQU $ - text4

    error_text DB '2 digits max!', 0x00
    error_text_length EQU $ - error_text


section .bss
    num1 RESB 10
    num2 RESB 10
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

    CALL user_input_1
    CALL ascii_to_int

    ; Print message 3
    MOV eax,4
    MOV ebx,1
    MOV ecx,text3
    MOV edx,lent3
    INT 80h

    CALL user_input_2
    CALL ascii_to_int

    ; Print message 4
    MOV eax,4
    MOV ebx,1
    MOV ecx,text4
    MOV edx,lent4
    INT 80h

    CALL user_input_3
    CALL ascii_to_int

    JMP exit


error_print:
    MOV eax,4
    MOV ebx,1
    MOV ecx,error_text
    MOV edx,error_text_length
    JMP exit

; ; My try 1
; ascii_to_int:
;     MOV al,[num1]
;     SUB al, '0'
;     MOV cl, al
;     MOV bl,[num1 + 1]
;     SUB bl, '0'
;     MOV al, 0xA
;     MUL cl,
;     ADD bl,cl
;     RET

; GPT suggested
ascii_to_int:
    XOR eax,eax        ; clear result
    XOR ecx,ecx
    XOR edx,edx

    ; get first digit
    MOV al,[num1]       ; e.g. '4' = 0x3
    SUB al,'0'          ; 0x34 - 0x30 = 0x04
    MOVZX eax,al        ; clear upper bits
    MOV ebx,10
    MUL ebx              ; EAX = EAX * 10

    ; get second digit
    MOV cl,[num1 + 0x01] ; '2'
    CMP cl, 0x0A
    JE .newline_character
    SUB cl,'0'           ; CL = 2
    ADD eax,ecx          ; EAX = 4*10 + 2 = 42
    RET

.newline_character:
    NOP ; user typed a single character



user_input_1:
    ; TODO: add a check to make it no more than 2 bytes (i.e., 2 characters)
    MOV eax,3 ; sys_read
    MOV ebx,0 ; file descriptor 0 => stdin
    MOV ecx,num1
    MOV edx,3
    INT 80h

    CMP eax,3
    JG error_print
    RET

user_input_2:
    MOV eax,3
    MOV ebx,0
    MOV ecx,num2
    MOV edx,3
    INT 80h
    RET

user_input_3:
    MOV eax,3
    MOV ebx,0
    MOV ecx,opp
    MOV edx,2
    INT 80h
    RET

exit:
    ; Exit the program
    MOV eax,1
    MOV ebx,0
    INT 80h


