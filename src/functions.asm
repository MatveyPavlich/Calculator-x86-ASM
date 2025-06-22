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
    ; (%1) - input buffer address (e.g., num1)

    ; Check if only ENTER was pressed
    CMP eax, 1
    JE %%enter_pressed

    ; Check for invalid ASCII digit (!= 0–9)
    CMP BYTE [%1], '0'
    JB %%invalid_char
    CMP BYTE [%1], '9'
    JA %%invalid_char

    ; Check if second char is newline
    CMP BYTE [(%1) + 1], 0x0A
    JNE %%too_long

    JMP %%ok

%%enter_pressed:
    JMP error_print_enter_pressed

%%invalid_char:
    flush_check %1
    JMP error_ivalid_character

%%too_long:
    flush_check %1
    JMP error_print

%%ok:
%endmacro


exit:
    print end_print, end_print_len
    MOV eax, SYS_EXIT
    MOV ebx, 0
    INT 0x80