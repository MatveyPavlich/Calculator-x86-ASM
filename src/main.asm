; Calculator - v1.1 (2025-06-15, Sun)
; Works with 1-digit numbers only.
; Adds memory buffer to handle unexpected multi-digit inputs.
; Known bug: flush_stdin needs a 2nd <Enter> if more than 1 char is typed.

section .data
    text1             DB 0x0A, "|------Calculator-App-------|", 0x0A, 0x00 
    lent1             EQU $ - text1

    text2             DB "Enter your 1st number: ", 0x0A, 0x00 
    lent2             EQU $ - text2

    text3             DB "Enter your 2nd number: ", 0x0A, 0x00 
    lent3             EQU $ - text3

    text4             DB "Pick an operation: | 1. Add | 2. Sub | 3. Mul | 4. Div |", 0x0A, 0x00 
    lent4             EQU $ - text4

    output_msg        DB "Output: ", 0x00
    output_msg_len    EQU $ - output_msg

    error_text        DB "ERROR: one digit max O_o", 0x00
    error_text_length EQU $ - error_text

    error_no_number   DB "ERROR: no number given -_-"
    error_no_num_len  EQU $ - error_no_number

    end_print         DB 0xA, 0x00
    end_print_len     EQU $ - end_print

    red_start         DB 0x1B, "[31m", 0 
    red_start_len     EQU $ - red_start     

    reset_colour      DB 0x1B, "[0m", 0
    reset_colour_len  EQU $ - reset_colour


section .bss
    memory_buffer RESB 100


section .text
global _start

_start:
    ; Print welcome
    MOV eax,4
    MOV ebx,1
    MOV ecx,text1
    MOV edx,lent1
    INT 0x80

    ; Prompt for 1st number
    MOV eax,4
    MOV ebx,1
    MOV ecx,text2
    MOV edx,lent2
    INT 0x80

    ; Read 1st number
    MOV eax,3
    MOV ebx,0
    MOV ecx,memory_buffer
    MOV edx,10
    INT 0x80

    CMP eax,1
    JE error_print_enter_pressed
    CMP BYTE [memory_buffer + 1], 0x0A
    JNE error_print

    ; Prompt for 2nd number
    MOV eax,4
    MOV ebx,1
    MOV ecx,text3
    MOV edx,lent3
    INT 0x80

    ; Read 2nd number
    MOV eax,3
    MOV ebx,0
    MOV ecx,memory_buffer + 2
    MOV edx,10
    INT 0x80

    CMP eax,1
    JE error_print_enter_pressed
    CMP BYTE [memory_buffer + 3], 0x0A
    JNE error_print

    ; Prompt for operation
    MOV eax,4
    MOV ebx,1
    MOV ecx,text4
    MOV edx,lent4
    INT 0x80

    ; Read operation
    MOV eax,3
    MOV ebx,0
    MOV ecx,memory_buffer + 4
    MOV edx,2
    INT 0x80

    CMP eax,1
    JE error_print_enter_pressed
    CMP BYTE [memory_buffer + 5], 0x0A
    JNE error_print

    ; Parse operation and numbers
    MOV cl,[memory_buffer + 4]
    SUB cl,'0'
    MOV al,[memory_buffer]
    SUB al,'0'
    MOV bl,[memory_buffer + 2]
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
    ADD al,'0'
    MOV [memory_buffer + 6],al
    JMP print_result

subtract:
    SUB al,bl
    ADD al,'0'
    MOV [memory_buffer + 6],al
    JMP print_result

multiply:
    MUL bl
    ADD al,'0'
    MOV [memory_buffer + 6],al
    JMP print_result

divide:
    MOV ah,0
    DIV bl
    ADD al,'0'
    MOV [memory_buffer + 6],al
    JMP print_result


print_result:
    MOV eax,4
    MOV ebx,1
    MOV ecx,output_msg
    MOV edx,output_msg_len
    INT 0x80

    MOV eax,4
    MOV ebx,1
    LEA ecx,[memory_buffer + 6]
    MOV edx,1
    INT 0x80

    JMP exit


red_error_message_colour_on:
    MOV eax,4
    MOV ebx,1
    MOV ecx,red_start
    MOV edx,red_start_len
    INT 0x80
    RET

red_error_message_colour_off:
    MOV eax,4
    MOV ebx,1
    MOV ecx,reset_colour
    MOV edx,reset_colour_len
    INT 0x80
    RET


error_print_enter_pressed:
    CALL red_error_message_colour_on
    MOV eax,4
    MOV ebx,1
    MOV ecx,error_no_number
    MOV edx,error_no_num_len
    INT 0x80
    CALL red_error_message_colour_off
    JMP exit


error_print:
    CALL flush_stdin
    CALL red_error_message_colour_on
    MOV eax,4
    MOV ebx,1
    MOV ecx,error_text
    MOV edx,error_text_length
    INT 0x80
    CALL red_error_message_colour_off
    JMP exit


exit:
    MOV eax,4
    MOV ebx,1
    MOV ecx,end_print
    MOV edx,end_print_len
    INT 0x80

    MOV eax,1
    MOV ebx,0
    INT 0x80


flush_stdin:
.flush_loop:
    MOV eax,3
    MOV ebx,0
    MOV ecx,memory_buffer
    MOV edx,1
    INT 0x80
    CMP eax,0
    JE .flush_end
    CMP BYTE [memory_buffer], 0x0A
    JNE .flush_loop
.flush_end:
    RET
