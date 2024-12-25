.MODEL SMALL
.STACK 100h

.DATA
    filename DB 'exp.txt', 0 
    error_msg DB 'error $',
    buffer DB 1000 dup('$')
    number_buffer DB 6 DUP('$')
    word_name  db 10 dup('$')   
    file_handle DW ?
    state DB 0
    row DW 0
    col DW 0
    length DW 0
    index DW ?

    keyword_msg DB 'Keyword $'
    identifiers DB 'Identifiers $'
    integer_number DB 'Integer Number $'
    long_number DB 'Long Number $'
    long_long_number DB 'Long Long Number $'
    unsigned_integer_number DB 'Unsigned Integer Number $'
    unsigned_long_number DB 'Unsigned Long Number $'
    unsigned_long_long_number DB 'Unsigned Long Long Number $'
    float_number DB 'Float Number $'
    double_number DB 'double Number $'
    delimiters_msg DB 'Delimiters $'
    operator_message DB 'Operator $'
    line_msg DB '-------------------------------------------------- $'
    seperator DB ' , $'
    col_msg DB 'col= $'
    row_msg DB 'row= $'
    len_msg DB 'len= $'
    ;block_number_msg DB 'block= $'

    ptr DW 0
    ; Array of pointers to the C keywords
    keyword1 DB "auto", 0
    keyword2 DB "break", 0
    keyword3 DB "case", 0
    keyword4 DB "char", 0
    keyword5 DB "const", 0
    keyword6 DB "continue", 0
    keyword7 DB "default", 0
    keyword8 DB "do", 0
    keyword9 DB "double", 0
    keyword10 DB "else", 0
    keyword11 DB "enum", 0
    keyword12 DB "extern", 0
    keyword13 DB "float", 0
    keyword14 DB "for", 0
    keyword15 DB "goto", 0
    keyword16 DB "if", 0
    keyword17 DB "int", 0
    keyword18 DB "long", 0
    keyword19 DB "register", 0
    keyword20 DB "return", 0
    keyword21 DB "short", 0
    keyword22 DB "signed", 0
    keyword23 DB "sizeof", 0
    keyword24 DB "static", 0
    keyword25 DB "struct", 0
    keyword26 DB "switch", 0
    keyword27 DB "typedef", 0
    keyword28 DB "union", 0
    keyword29 DB "unsigned", 0
    keyword30 DB "void", 0
    keyword31 DB "volatile", 0
    keyword32 DB "while", 0

    ; Array of pointers to the keyword strings
    keywordPtrs DW OFFSET keyword1, OFFSET keyword2, OFFSET keyword3, OFFSET keyword4, OFFSET keyword5
               DW OFFSET keyword6, OFFSET keyword7, OFFSET keyword8, OFFSET keyword9, OFFSET keyword10
               DW OFFSET keyword11, OFFSET keyword12, OFFSET keyword13, OFFSET keyword14, OFFSET keyword15
               DW OFFSET keyword16, OFFSET keyword17, OFFSET keyword18, OFFSET keyword19, OFFSET keyword20
               DW OFFSET keyword21, OFFSET keyword22, OFFSET keyword23, OFFSET keyword24, OFFSET keyword25
               DW OFFSET keyword26, OFFSET keyword27, OFFSET keyword28, OFFSET keyword29, OFFSET keyword30
               DW OFFSET keyword31, OFFSET keyword32

    jumpTable DW OFFSET state_0, state_1, OFFSET state_2, OFFSET state_3, OFFSET state_4, OFFSET state_5
               DW OFFSET state_6, OFFSET state_7, OFFSET state_8, OFFSET state_9, OFFSET state_10
               DW OFFSET state_11, OFFSET state_12, OFFSET state_13, OFFSET state_14, OFFSET state_15
               DW OFFSET state_16, OFFSET state_17, OFFSET state_18, OFFSET state_19, OFFSET state_20
               DW OFFSET state_21, OFFSET state_22, OFFSET state_23, OFFSET state_24, OFFSET state_25
               DW OFFSET state_26, OFFSET state_27, OFFSET state_28, OFFSET state_29, OFFSET state_30
               DW OFFSET state_31, OFFSET state_32, OFFSET state_33



.CODE
MAIN PROC
    MOV AX, @data
    MOV DS, AX

    ; Open the file
    MOV AH, 3Dh ; Open file function
    MOV AL, 0   ; Open for reading

    LEA DX, filename 
    INT 21h

    JC error
    MOV file_handle, AX

    ; Read the string from the file
    MOV AH, 3Fh ; Read from file function
    MOV BX, file_handle
    LEA DX, buffer
    MOV CX, 1000 ; Number of bytes to read
    INT 21h 

    ; Close the file
    MOV AH, 3Eh ; Close file function
    MOV BX, file_handle ; File handle
    INT 21h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    MOV SI, OFFSET buffer
    MOV index, SI
    MOV state, 0

    checking:
        MOV BL, state
        MOV SI, index
        MOV BH, [SI]
        CMP BH, '$'
        JE end_switch

        
        PUSH BX     
        CMP BL, 33
        JA error 

        ; Use jump table
        MOV BH, 0
        
        SHL BX, 1    ; Multiply index by 2 (word size)
        MOV DX, [jumpTable + BX]
        POP BX
        JMP DX       ; Jump to the case handler


        cases:
            state_0:
                CMP BH, '$'
                JE end_switch
                CMP BH, 32  ; space
                JE blank            
                CMP BH, 9   ; tab
                JE tab
                CMP BH, 10  ; newline
                JE newline
                CMP BH, 0Dh  ; carriage return
                JE carriage_return
                CMP BH, '/'
                JE slash
                CMP BH, ','
                JE delimiters
                CMP BH, ':'
                JE delimiters
                CMP BH, ';'
                JE delimiters
                CMP BH, '('
                JE delimiters
                CMP BH, ')'
                JE delimiters
                CMP BH, '{'
                JE delimiters
                CMP BH, '}'
                JE delimiters
                CMP BH, '['
                JE delimiters
                CMP BH, ']'
                JE delimiters
                CMP BH, '*'
                JE mid_op
                CMP BH, '%'
                JE mid_op
                CMP BH, '^'
                JE mid_op
                CMP BH, '!'
                JE mid_op
                CMP BH, '='
                JE mid_op
                CMP BH, '&'
                JE st_0_and
                CMP BH, '|'
                JE st_0_or
                CMP BH, '>'
                JE st_0_bigger
                CMP BH, '<'
                JE st_0_less
                CMP BH, '+'
                JE st_0_plus
                CMP BH, '-'
                JE st_0_minus
                CMP BH, '~'
                JE st_0_ternary_bitwisnot_dot
                CMP BH, '?'
                JE st_0_ternary_bitwisnot_dot
                CMP BH, '.'
                JE st_0_ternary_bitwisnot_dot

                CALL isDigit
                JC digit
                CALL isLetter
                JC letter_or_underscore
                CMP BH, '_'
                JE letter_or_underscore

                JMP error


                blank:
                    INC col
                    JMP end_st_0
                tab:
                    ADD col, 2
                    JMP end_st_0
                newline:
                    INC row
                    MOV col, 0
                    JMP end_st_0
                carriage_return:
                    MOV col, 0
                    JMP end_st_0
                slash:
                    INC col
                    CALL setCharAtName
                    MOV state, 21
                    JMP end_st_0

                delimiters:
                    INC col
                    MOV state, 25
                    JMP checking
                mid_op:
                    INC col
                    CALL setCharAtName
                    CALL getNextChar
                    MOV state, 26
                    JMP end_st_0
                
                st_0_and:
                    INC col
                    CALL setCharAtName
                    CALL getNextChar
                    MOV state, 32
                    JMP end_st_0 
                
                st_0_or:
                    INC col
                    CALL setCharAtName
                    CALL getNextChar
                    MOV state, 31
                    JMP end_st_0                
                st_0_less:
                    INC col
                    CALL setCharAtName
                    CALL getNextChar
                    MOV state, 29
                    JMP end_st_0 
                st_0_bigger:
                    INC col
                    CALL setCharAtName
                    CALL getNextChar
                    MOV state, 30
                    JMP end_st_0 
                st_0_plus:
                    INC col
                    CALL setCharAtName
                    CALL getNextChar
                    MOV state, 27
                    JMP end_st_0 
                st_0_minus:
                    INC col
                    CALL setCharAtName
                    CALL getNextChar
                    MOV state, 28
                    JMP end_st_0 
                st_0_ternary_bitwisnot_dot:
                    INC col
                    CALL setCharAtName
                    CALL getNextChar
                    MOV state, 33
                    JMP end_st_0
        
                digit:
                    INC col
                    CALL setCharAtName
                    MOV state, 3
                    JMP end_st_0
                letter_or_underscore:
                    INC col
                    CALL setCharAtName
                    MOV state, 1
                    JMP end_st_0

                
                end_st_0:
                    CALL getNextChar
                JMP checking
                

            state_1:
                CALL isDigit
                JC end_st_1
                CALL isLetter
                JC end_st_1
                CMP BH, '_'
                JE end_st_1

                MOV state, 2
                JMP checking

                end_st_1:
                    INC col
                    CALL setCharAtName
                    CALL getNextChar
                JMP checking

            state_2:
                MOV state, 0
                CALL checkKeyword
                JC keyword_section

                ; return Identifiers
                MOV AH, 9
                LEA DX, Identifiers
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h
                
                CALL printDetails
                
                MOV length, 0
                JMP checking

                keyword_section:
                    ; return keyword
                    MOV AH, 9
                    LEA DX, Identifiers
                    INT 21h
                    MOV BH, '$'
                    CALL setCharAtName
                    DEC length
                    LEA DX, word_name
                    INT 21h

                    CALL printDetails
                    MOV length, 0
                    JMP checking
            state_3:
                CALL isDigit
                JC still_number
                CMP BH, '.'
                JE point_section

                CMP BH, 'U'
                JE st_3_u
                CMP BH, 'u'
                JE st_3_u
                CMP BH, 'L'
                JE st_3_L
                CMP BH, 'l'
                JE st_3_l_lower

                CALL isLetter
                JC error

                MOV state, 7
                JMP checking

                st_3_u:
                    MOV state, 8
                    INC col
                    CALL getNextChar
                    JMP checking
                st_3_L:
                    MOV state, 9
                    INC col
                    CALL getNextChar
                    JMP checking
                st_3_l_lower:
                    MOV state, 10
                    INC col
                    CALL getNextChar
                    JMP checking

                point_section:
                    MOV state, 4
                still_number:
                    CALL setCharAtName
                    CALL getNextChar
                    INC col
                JMP checking
            
            state_4:
                CALL isDigit
                JC end_st_4

                    JMP error
                end_st_4:
                    INC col
                    MOV state, 5
                    CALL setCharAtName
                    CALL getNextChar
                JMP checking

            state_5:
                CALL isDigit
                JC end_st_5_dig
                CALL isLetter
                JC end_st_5_let

                MOV state, 6
                JMP checking

                end_st_5_dig:
                    CALL setCharAtName
                    CALL getNextChar
                    INC col
                    JMP checking
                
                end_st_5_let:
                    CMP BH, 'f'
                    JE st_5_f
                    CMP BH, 'F'
                    JE st_5_f

                    JMP error
                
                    st_5_f:
                        MOV state, 18
                        INC col
                        CALL getNextChar
                    JMP checking

            state_6:
                ; Return RealNumber
                MOV AH, 9
                LEA DX, double_number
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h
                
                CALL printDetails
                MOV length, 0
                MOV state, 0
                JMP checking
            state_7:
                ; Return Integer
                MOV AH, 9
                LEA DX, integer_number
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h
                
                CALL printDetails
                MOV length, 0
                MOV state, 0
                JMP checking
            state_8:
                CMP BH, 'l'
                JE st_8_l_lower
                CMP BH, 'L'
                JE st_8_L
                CALL isDigit
                JC error
                CALL isLetter
                JC error

                MOV state, 15
                JMP checking

                st_8_l_lower:
                    MOV state, 12
                    CALL getNextChar
                    INC col
                    JMP checking
                st_8_L:
                    MOV state, 11
                    CALL getNextChar
                    INC col
                JMP checking
            state_9:
                CMP BH, 'L'
                JE st_9_L
                CALL isLetter
                JC error
                CALL isDigit
                JC error

                MOV state, 17
                JMP checking

                st_9_L:
                    MOV state, 13
                    CALL getNextChar
                    INC col
                JMP checking
            state_10:
                CMP BH, 'l'
                JE st_10_l
                CALL isLetter
                JC error
                CALL isDigit
                JC error

                MOV state, 17
                JMP checking

                st_10_l:
                    MOV state, 13
                    CALL getNextChar
                    INC col
                JMP checking
            state_11:
                CMP BH, 'L'
                JE st_11_L

                CALL isLetter
                JC error
                CALL isDigit
                JC error

                MOV state, 16
                JMP checking

                st_11_L:
                    MOV state, 14
                    CALL getNextChar
                    INC col
                    JMP checking
            state_12:
                CMP BH, 'l'
                JE st_12_l

                CALL isLetter
                JC error
                CALL isDigit
                JC error

                MOV state, 16
                JMP checking

                st_12_l:
                    MOV state, 14
                    CALL getNextChar
                    INC col
                JMP checking
            state_13:
                CALL isDigit
                JC error
                CALL isLetter
                JC error

                ;Return long long
                MOV AH, 9
                LEA DX, long_long_number
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h

                CALL printDetails
                MOV length, 0
                MOV state, 0
                JMP checking
            state_14:
                CALL isDigit
                JC error
                CALL isLetter
                JC error

                ;Return unsigned long long
                MOV AH, 9
                LEA DX, unsigned_long_long_number
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h

                CALL printDetails
                MOV length, 0
                MOV state, 0
                JMP checking 
            state_15:
                CALL isDigit
                JC error
                CALL isLetter
                JC error
                ; Return unsigned integer
                MOV AH, 9
                LEA DX, unsigned_integer_number
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h

                CALL printDetails
                MOV length, 0
                MOV state, 0
                JMP checking 
            state_16:
                CALL isDigit
                JC error
                CALL isLetter
                JC error
                ; Return unsigned long integer
                MOV AH, 9
                LEA DX, unsigned_long_number
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h

                CALL printDetails
                MOV length, 0
                MOV state, 0
                JMP checking 
            state_17:
                CALL isDigit
                JC error
                CALL isLetter
                JC error
                ; Return long integer
                MOV AH, 9
                LEA DX, long_number
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h

                CALL printDetails
                MOV length, 0
                MOV state, 0
                JMP checking
            state_18:
                CMP BH, 'l'
                JE st_18_l
                CMP BH, 'L'
                JE st_18_l

                CALL isDigit
                JC error
                CALL isLetter
                JC error

                MOV state, 19
                JMP checking 

                st_18_l:
                    MOV state, 20
                    CALL getNextChar
                    INC col
                JMP checking
            state_19:
                CALL isDigit
                JC error
                CALL isLetter
                JC error
                ; Return float
                MOV AH, 9
                LEA DX, float_number
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h

                CALL printDetails
                MOV length, 0
                MOV state, 0
                JMP checking
            state_20:
                CALL isDigit
                JC error
                CALL isLetter
                JC error
                ; Return double
                MOV AH, 9
                LEA DX, double_number
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h

                CALL printDetails
                MOV length, 0
                MOV state, 0
                JMP checking
            state_21:
                CMP BH, '/'
                JE one_line_comment
                CMP BH, '*'
                JE multy_line_comment

                CMP BH, '='
                JE div_equal

                JMP div_only
                    
                div_equal:
                    INC col
                    CALL setCharAtName
                    CALL getNextChar
                    MOV state, 39
                    JMP checking
                div_only:
                    INC col
                    CALL setCharAtName
                    MOV state, 39
                    JMP checking
                
                one_line_comment:
                    INC col
                    MOV state, 22
                    CALL getNextChar
                    JMP checking
                multy_line_comment:
                    INC col
                    MOV state, 23
                    CALL getNextChar
                    JMP checking
            state_22:
                CMP BH, 10 ; \n
                JE end_of_one_line_comment

                INC col
                CALL getNextChar
                JMP checking

                end_of_one_line_comment:
                    MOV state, 0
                    MOV length, 0
                JMP checking
            state_23:
                CMP BH, '*'
                JNE commented

                MOV state, 24

                commented:
                    INC col
                    CALL getNextChar
                JMP checking

            state_24:
                CMP BH, '/'
                JE end_multy_line_comment

                MOV state, 23
                INC col
                JMP checking

                end_multy_line_comment:
                    MOV state, 0
                    MOV length, 0
                    INC col
                    CALL getNextChar
                JMP checking
            state_25:
                ; Return Delimiter
                CALL setCharAtName
                MOV state, 0
                MOV AH, 9
                LEA DX, delimiters_msg
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h
                
                CALL printDetails
                MOV length, 0
                CALL getNextChar
                JMP checking
            state_26:
                CMP BH, '='
                JNE st_26_neq

                INC col
                CALL setCharAtName
                CALL getNextChar

                st_26_neq:
                    MOV state, 33
                JMP checking
            state_27:
                CMP BH, '+'
                JNE not_plus_plus
                
                INC col
                CALL setCharAtName
                CALL getNextChar

                not_plus_plus:
                    MOV state, 33
                JMP checking
            state_28:
                CMP BH, '-'
                JE minus_minus_arrow
                CMP BH, '>'
                JE minus_minus_arrow

                MOV state, 26
                JMP checking

                minus_minus_arrow:
                    INC col
                    CALL setCharAtName
                    CALL getNextChar
                    MOV state, 33
                JMP checking
            state_29:
                CMP BH, '<'
                JNE not_shift_left
                
                INC col
                CALL setCharAtName
                CALL getNextChar

                not_shift_left:
                    MOV state, 26
                JMP checking
            state_30:
                CMP BH, '>'
                JNE not_shift_right
                
                INC col
                CALL setCharAtName
                CALL getNextChar

                not_shift_right:
                    MOV state, 26
                JMP checking
            state_31:
                CMP BH, '|'
                JNE not_logical_or
                
                INC col
                CALL setCharAtName
                CALL getNextChar

                not_logical_or:
                    MOV state, 26
                JMP checking
            state_32:
                CMP BH, '&'
                JNE not_logical_and
                
                INC col
                CALL setCharAtName
                CALL getNextChar

                not_logical_and:
                    MOV state, 26
                JMP checking
            state_33:
                ; Return Operator
                MOV state, 0
                MOV AH, 9
                LEA DX, operator_message
                INT 21h
                MOV BH, '$'
                CALL setCharAtName
                DEC length
                LEA DX, word_name
                INT 21h

                CALL printDetails
                MOV length, 0
                JMP checking




            

                
            
        
    end_switch:
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Terminate program
    MOV AX, 4C00h
    INT 21h

    JMP end_program

    error:
    MOV ah, 09h
    LEA dx, error_msg
    INT 21h

    end_program:

    MOV ax, 4C00h
    INT 21h


MAIN ENDP


checkKeyword PROC

    LEA SI, keywordPtrs
    MOV ptr, SI
    
    MOV CX, 32  ; Number of keywords

    compare_keywords_loop:
        
        MOV AX, [SI]
        MOV SI, AX 

        PUSH CX  ; Save the count of keywords for the loop
        CALL compareStrings
        POP CX  ; Restore the count of keywords

        ; If strings match, set AX to 0 and return
        JC found_match

        MOV SI, ptr
        ADD SI, 2  ;  to the next word in the keywordPtrs array
        MOV ptr, SI

        loop compare_keywords_loop

    ; If no match is found, set AX to 1
    mov ax, 1
    RET

    found_match:
    ; If a match is found, set AX to 0
    xor ax, ax
    RET

checkKeyword ENDP

compareStrings PROC
    CLC

    compare_strings_loop:
        MOV AL, [BX]        ; Load byte from the input string
        MOV DL, [SI]        ; Load byte from the keyword

        CMP AL, DL          ; Compare bytes
        JNE strings_not_equal
        CMP AL, 0           ; Check if end of the string is reached
        JZ strings_equal

        INC BX              ;  to the next byte in the input string
        INC SI              ; Move to the next byte in the keyword
        JMP compare_strings_loop

    strings_not_equal:
        CLC           ; carry flag false, strings are not equal
        RET

    strings_equal:
        STC          ; carry flag true, strings are equal
        RET
compareStrings ENDP

getNextChar PROC
    MOV SI, index
    INC SI
    MOV index, SI
    MOV BH, [SI]
    RET
getNextChar ENDP

; Input: BH
setCharAtName PROC
    MOV SI, OFFSET word_name
    ADD SI, length
    MOV [SI], BH
    INC length
    RET
setCharAtName ENDP

; Input:  BH
; Output: carry flag = 1 if the character is a letter else 0
isLetter PROC
    CLC        
    CMP BH, 'A'       
    JL notLetter      
    CMP BH, 'Z'       
    JLE isALetter   

    CMP BH, 'a'       
    JL notLetter      
    CMP BH, 'z'       
    JLE isALetter     

    notLetter:
        CLC        
        RET

    isALetter:
        STC        
        RET
isLetter endp

; Input:  BH
 ; Output: carry flag = 1 if the character is a digit else 0

isDigit PROC
    CMP BH, '0'       
    JL notDigit       
    CMP BH, '9'       
    JLE isADigit      

    notDigit:
        CLC
        RET

    isADigit:
        STC
        RET
isDigit ENDP

printDetails PROC
    MOV AH, 9
    LEA DX, seperator
    INT 21h

    LEA DX, row_msg
    INT 21h

    MOV AX, row
    CALL ConvertToASCII
    LEA DX, number_buffer
    MOV AH, 9
    INT 21h 

    LEA DX, seperator
    INT 21h

    MOV AH, 9
    LEA DX, col_msg
    INT 21h

    MOV AX, col
    SUB AX, length
    CALL ConvertToASCII
    LEA DX, number_buffer
    MOV AH, 9
    INT 21h 

    MOV AH, 02h
    MOV DX, 0Ah ; \n
    INT 21h
    MOV DX, 0Dh ; \r
    INT 21h

    MOV AH, 9
    LEA DX, line_msg
    INT 21h

    MOV AH, 02h
    MOV DX, 0Ah ; \n
    INT 21h
    MOV DX, 0Dh ; \r
    INT 21h

    RET
printDetails ENDP

; Input: AX
; Output: ASCII in the number_buffer
ConvertToASCII PROC
    PUSH AX        
    XOR CX, CX     

    convert_loop:
        XOR DX, DX         
        MOV BX, 10      
        DIV BX           
        ADD DL, '0'         
        PUSH DX          
        INC CX            
        CMP AX, 0     
        JNE convert_loop  

    LEA DI, number_buffer
    store_loop:
        POP AX
        MOV [DI], AL
        INC DI
        LOOP store_loop 

    MOV [DI], '$'
    POP AX
    RET
ConvertToASCII ENDP

END MAIN