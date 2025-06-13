; Calculator is working for 1-digit numbers max!

section .data
    text1             DB         0x0A, '|------Calculator-App-------|', 0x0A, 0x00 
    lent1             EQU        $ - text1

    text2             DB         'Enter your 1st number: ', 0x0A, 0x00 
    lent2             EQU        $ - text2

    text3             DB         'Enter your 2nd number: ', 0x0A, 0x00 
    lent3             EQU        $ - text3

    text4             DB         'Pick an opperation: ', '| 1. Add |', ' 2. Sub |', ' 3. Mul |', ' 4. Div |', 0x0A, 0x00 
    lent4             EQU        $ - text4

    output_msg        DB         'Output: ', 0x00
    output_msg_len    EQU        $ - output_msg

    error_text        DB         '2 digits max!', 0x00
    error_text_length EQU        $ - error_text

    end_print         DB         0xA, 0x00
    end_print_len     EQU        $ - end_print


section .bss
    num1     RESB 2
    num2     RESB 2
    opp      RESB 2
    res      RESB 2

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

    ; Listen for 1st number
    MOV eax,3 ; sys_read
    MOV ebx,0 ; file descriptor 0 => stdin
    MOV ecx,num1
    MOV edx,2
    INT 80h

    ; Print message 3
    MOV eax,4
    MOV ebx,1
    MOV ecx,text3
    MOV edx,lent3
    INT 80h

    ; Listen for 2nd number
    MOV eax,3
    MOV ebx,0
    MOV ecx,num2
    MOV edx,2
    INT 80h

    ; Print message 4
    MOV eax,4
    MOV ebx,1
    MOV ecx,text4
    MOV edx,lent4
    INT 80h
    
    ; Listen for the opperation
    MOV eax,3
    MOV ebx,0
    MOV ecx,opp
    MOV edx,2
    INT 80h

    ; Identify the operration to perform
    MOV cl,[opp]
    SUB cl,'0'
    MOV al,[num1]       ; e.g. '4' = 0x3
    SUB al,'0'          ; 0x34 - 0x30 = 0x04
    MOV bl,[num2]
    SUB bl,'0'

    CMP cl,1
    JE addition
    CMP cl,2
    JE subtract
    CMP cl,3
    JE multiply
    CMP cl,4
    JE divide
    JMP exit

addition:
    ADD al,bl
    ADD al,'0'  ; Convert to ASCII
    MOV [res],al
    JMP print_result

subtract:
    SUB al,bl
    ADD al,'0'
    MOV [res],al
    JMP print_result

multiply:
    MUL bl
    ADD al, '0'
    MOV [res],al
    JMP print_result

divide:
    MOV ah,0
    DIV bl
    ADD al, '0'
    MOV [res],al
    JMP print_result

print_result:
    ; Print output message
    MOV eax,4
    MOV ebx,1
    MOV ecx,output_msg
    MOV edx,output_msg_len
    INT 80h

    MOV eax,4
    MOV ebx,1
    MOV ecx,res
    MOV edx,1
    INT 80h

    JMP exit

error_print:
    MOV eax,4
    MOV ebx,1
    MOV ecx,error_text
    MOV edx,error_text_length
    JMP exit

exit:
    ; Print 2 extra newlines to separate the output
    MOV eax,4
    MOV ebx,1
    MOV ecx,end_print
    MOV edx,end_print_len
    INT 80h

    ; Exit the program
    MOV eax,1
    MOV ebx,0
    INT 80h


