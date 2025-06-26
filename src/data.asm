; For some reason need to have .bss before .data otherwise get:
;   warning: attempt to initialize memory in BSS section `.bss': ignored
section .bss
    memory_buffer RESB 100

section .data
; ========== SECTION 1: Main program messages ==========
    welcome_msg            DB 0x0A, "|------Calculator-App-------|", 0x0A, 0x00 
    welcome_msg_len        EQU $ - welcome_msg

    ask_input_1            DB "Enter your 1st number: ", 0x00 
    ask_input_1_len        EQU $ - ask_input_1

    ask_input_2            DB "Enter your 2nd number: ", 0x00 
    ask_input_2_len        EQU $ - ask_input_2

    show_oprtns            DB "Avaliable Operations: (1) Add (2) Sub (3) Mul (4) Div", 0x0A, 0x00 
    show_oprtns_len        EQU $ - show_oprtns

    ask_oprtn              DB "Pick an operation: ", 0x00
    ask_oprtn_len          EQU $ - ask_oprtn

    output_msg             DB "Output: ", 0x00
    output_msg_len         EQU $ - output_msg

; ========== SECTION 2: Error messages ========== 
    error_too_many         DB "ERROR: one digit max O_o", 0xA, 0x00
    error_too_many_len     EQU $ - error_too_many

    error_no_number        DB "ERROR: no number given -_-", 0xA, 0x00
    error_no_num_len       EQU $ - error_no_number

    error_div_zero         DB "ERROR: cannot divide by zero", 0xA, 0x00
    error_div_zero_len     EQU $ - error_div_zero

    error_invalid_char     DB "ERROR: invalid character", 0xA, 0x00
    error_invalid_char_len EQU $ - error_invalid_char

    error_invalid_op       DB "ERROR: invalid opperation, use 1,2,3 or 4 :/", 0xA, 0x00
    error_invalid_op_len   EQU $ - error_invalid_op

    red_start              DB 0x1B, "[31m", 0 
    red_start_len          EQU $ - red_start

    reset_colour           DB 0x1B, "[0m", 0
    reset_colour_len       EQU $ - reset_colour
