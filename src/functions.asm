; ========== SECTION 1: System Call Wrappers ==========

;------------------------------------------
; void print(String message, int length)
; Print a string to STDOUT using syscall
%macro print 2
    MOV eax, 4      ; SYS_WRITE
    MOV ebx, 1      ; FD_STDOUT
    MOV ecx, %1     ; string label
    MOV edx, %2     ; string length
    INT 0x80
%endmacro

;------------------------------------------
; void read(Buffer destination, int max_length)
; Read input from STDIN into a memory buffer using syscall
%macro read 2
    MOV eax, 3     ; SYS_READ
    MOV ebx, 0     ; FD_STDIN
    MOV ecx, %1    ; label to store the read
    MOV edx, %2    ; max number of bytes to read
    INT 0x80
%endmacro

;------------------------------------------
; void exit()
; Exit the program
exit:
    MOV eax, 1     ; SYS_EXIT
    MOV ebx, 0     ; FD_STDIN
    INT 0x80




; ========== SECTION 2: Input Handling Utilities ==========

;------------------------------------------
; void flush_check(Buffer input)
; Flush remaining characters from STDIN if input buffer wasn't fully consumed
; (%1) - address of the input buffer (e.g., num1)
%macro flush_check 1
    CMP BYTE [(%1) + eax - 1], 0x0A ; Check the last value from the original read
    JE %%skip_flush                 ; Don't need a kernel buffer flush if last character is a newline
    CALL flush_stdin                ; Need to flush if the last character is not a newline
%%skip_flush:
%endmacro

;------------------------------------------
; void input_check (Buffer input)
; (%1) - address of the input buffer (e.g., num1)
%macro input_check 1
    CMP eax, 1                       ; Check the input length. eax stores it
    JE %%enter_pressed               ; print "No numbers given" error if eax = 1

    ; See if it is a signed number          
    MOV dl, [%1]                     ; Move operand into dl
    CMP dl, '+'                      ; Check if it is +
    JE %%has_sign                    ; Do a signed check
    CMP dl, '-'                      ; Check if it is -
    JE %%has_sign                    ; Do a signed check
              
    ; No sign, fall back to regular check
    CMP dl, '0'                      ; Check if an ASCII character < 0
    JB %%invalid_char                ; Print error message
    CMP dl, '9'                      ; Check if an ASCII character > 9
    JA %%invalid_char                ; Print error message
    CMP BYTE [(%1) + 1], 0x0A        ; Make sure 2nd ASCII character is a newline
    JNE %%too_long                   ; Print error message if not
    JMP %%ok                         ; Finish check if no errors detected

%%has_sign:
    CMP eax, 3                       ; Check for 3 chars (sign, number, newline)
    JB %%enter_pressed               ; Smaller if just ENTER pressed
    JA %%too_long                    ; More numbers if >3
    CMP BYTE [%1 + 1], '0'           ; Check if an ASCII character < 0
    JB %%invalid_char                ; Print error message
    CMP BYTE [%1 + 1], '9'           ; Check if an ASCII character > 9
    JA %%invalid_char                ; Print error message
    CMP BYTE [%1 + 2], 0x0A          ; Make sure 3rd ASCII character is a newline
    JNE %%too_long                   ; Print error message if not
    MOV dl, [%1 + 1]                 ; Get the actual number character
    MOV [%1], dl                     ; Save it to be at the first byte
    MOV BYTE [%1 + 1], 0x0A          ; Move a newline to the 2nd position
    JMP %%ok

%%enter_pressed:
    JMP error_print_enter_pressed

%%invalid_char:
    flush_check %1                ; Flush kernel buffer for input to not overflow into shell
    JMP error_ivalid_character    ; Print "Single digit only" error

%%too_long:
    flush_check %1
    JMP error_print

%%ok:
%endmacro

; ========== SECTION 5: Math Operations ==========

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


; ========== SECTION 3: Output Utilities ==========
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
    print error_too_many, error_too_many_len
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

; ========== SECTION 4: Conversion Helpers ==========
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
    MOV BYTE [equation + 6], 0xA
    print equation, 7
    JMP exit

.print_one_digit:
    MOV al, [result + 1]
    MOV [equation + 4], al
    MOV BYTE [equation + 5], 0xA
    print equation, 6
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