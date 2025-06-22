section .data
    text1                  DB 0x0A, "|------Calculator-App-------|", 0x0A, 0x00 
    lent1                  EQU $ - text1

    text2                  DB "Enter your 1st number: ", 0x00 
    lent2                  EQU $ - text2

    text3                  DB "Enter your 2nd number: ", 0x00 
    lent3                  EQU $ - text3

    text4                  DB "Avaliable Operations: (1) Add (2) Sub (3) Mul (4) Div", 0x0A, 0x00 
    lent4                  EQU $ - text4

    text5                  DB "Pick an operation: ", 0x00
    len5                   EQU $ - text5

    output_msg             DB "Output: ", 0x00
    output_msg_len         EQU $ - output_msg

    ; Error messages     
    error_text             DB "ERROR: one digit max O_o", 0x00
    error_text_length      EQU $ - error_text

    error_no_number        DB "ERROR: no number given -_-"
    error_no_num_len       EQU $ - error_no_number

    error_div_zero         DB "ERROR: cannot divide by zero", 0x00
    error_div_zero_len     EQU $ - error_div_zero

    error_invalid_char     DB "ERROR: invalid character", 0x00
    error_invalid_char_len EQU $ - error_invalid_char

    end_print              DB 0xA, 0x00
    end_print_len          EQU $ - end_print

    red_start              DB 0x1B, "[31m", 0 
    red_start_len          EQU $ - red_start

    reset_colour           DB 0x1B, "[0m", 0
    reset_colour_len       EQU $ - reset_colour


