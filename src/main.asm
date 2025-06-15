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

    error_text        DB         'ERROR: one digit max O_o', 0x00
    error_text_length EQU        $ - error_text

    error_no_number   DB         'ERROR: no number given -_-'
    error_no_num_len  EQU        $ - error_no_number

    end_print         DB         0xA, 0x00
    end_print_len     EQU        $ - end_print

    red_start         DB         0x1B, '[31m', 0 
    red_start_len     EQU        $ - red_start     

    reset_colour      DB         0x1B, '[0m', 0
    reset_colour_len  EQU        $ - reset_colour


section .bss
    memory_buffer RESB 100

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
    MOV ecx,memory_buffer
    MOV edx,10
    INT 80h

    ; Make sure user didn't press enter by mistake when the program started to run
    CMP eax, 0x1 ; Was only one character entered 
    JE error_print_enter_pressed
    
    ; Check to make sure that only one digit was typed 
    CMP BYTE [memory_buffer + 0x01], 0x0A ; Is a newline a 2nd character? 
    JNE error_print

    ; Print message 3
    MOV eax,4
    MOV ebx,1
    MOV ecx,text3
    MOV edx,lent3
    INT 80h

    ; Listen for 2nd number
    MOV eax,3
    MOV ebx,0
    MOV ecx,memory_buffer + 0x02
    MOV edx,10
    INT 80h

    ; Make sure user didn't press enter by mistake when the program started to run
    CMP eax, 0x1 ; Is a newline a 1st character? 
    JE error_print_enter_pressed
    
    ; Check to make sure that only one digit was typed 
    CMP BYTE [memory_buffer + 0x03], 0x0A ; Is a newline a 2nd character? 
    JNE error_print

    ; Print message 4
    MOV eax,4
    MOV ebx,1
    MOV ecx,text4
    MOV edx,lent4
    INT 80h
    
    ; Listen for the opperation
    MOV eax,3
    MOV ebx,0
    MOV ecx,memory_buffer + 0x04
    MOV edx,2
    INT 80h

    ; Make sure user didn't press enter by mistake when the program started to run
    CMP eax, 0x1 ; Is a newline a 1st character? 
    JE error_print_enter_pressed
    
    ; Check to make sure that only one digit was typed 
    CMP BYTE [memory_buffer + 0x05], 0x0A ; Is a newline a 2nd character? 
    JNE error_print

    ; Identify the operration to perform
    MOV cl,[memory_buffer + 0x04]
    SUB cl,'0'
    MOV al,[memory_buffer]         ; e.g. '4' = 0x3
    SUB al,'0'                     ; 0x34 - 0x30 = 0x04
    MOV bl,[memory_buffer + 0x02]
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
    MOV [memory_buffer + 0x06],al
    JMP print_result

subtract:
    SUB al,bl
    ADD al,'0'
    MOV [memory_buffer + 0x06],al
    JMP print_result

multiply:
    MUL bl
    ADD al, '0'
    MOV [memory_buffer + 0x06],al
    JMP print_result

divide:
    MOV ah,0
    DIV bl
    ADD al, '0'
    MOV [memory_buffer + 0x06],al
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
    LEA ecx,[memory_buffer + 0x06]
    MOV edx,1
    INT 80h

    JMP exit

red_error_message_colour_on:
; Set red colour to the message
    MOV eax,4
    MOV ebx,1
    MOV ecx,red_start
    MOV edx,red_start_len
    INT 80h
    RET

red_error_message_colour_off:
; Set red colour to the message
    MOV eax,4
    MOV ebx,1
    MOV ecx,reset_colour
    MOV edx,reset_colour_len
    INT 80h
    RET

error_print_enter_pressed:
    ; Text for when user presses enter instead of a number
    CALL red_error_message_colour_on

    MOV eax,4
    MOV ebx,1
    MOV ecx,error_no_number
    MOV edx,error_no_num_len
    INT 80h

    CALL red_error_message_colour_off

    JMP exit

error_print:
    ; ; Flush stdin
    ; MOV eax, 3         ; sys_read
    ; MOV ebx, 0         ; stdin
    ; MOV ecx, memory_buffer
    ; MOV edx, 100       ; read up to 100 bytes
    ; INT 80h
    ; ; We don’t care about result
    CALL flush_stdin

    CALL red_error_message_colour_on

    ; Print the error message
    MOV eax,4
    MOV ebx,1
    MOV ecx,error_text
    MOV edx,error_text_length
    INT 80h

    CALL red_error_message_colour_off

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


flush_stdin:
flush_loop:
    MOV eax,3
    MOV ebx,0
    MOV ecx,memory_buffer
    MOV edx,1
    INT 80h
    CMP eax,0
    JE flush_end
    CMP BYTE [memory_buffer], 0x0A
    JNE flush_loop
flush_end:
    RET