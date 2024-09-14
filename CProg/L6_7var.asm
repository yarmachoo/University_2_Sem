.MODEL small

;parameteres for this program must be entered in command line
;FILE_PATH space WORD

.DATA
    word db 50, 0, 50 dup('$'), '$' ;variable for a word
    buf db 2, 0, 2 dup('$'), '$' ;for a symbol from file
    
    msg_invite_to_input_word db 'Enter the word that must be searched',0Dh,0Ah,'$'  
    msg_amount_of_strings db 'The amount of strings containing this word:',0Dh,0Ah,'$'
    msg_bad_args db 'Command line parse error', 0Dh, 0Ah, '$'
    msg_error db 0Dh, 0Ah, 'Error', 0Dh, 0Ah, '$'
    msg_warning_wordlength db 'Word is longer than 50 symbols',0Dh, 0Ah, '$'
    msg_no_word_error db 'Word has not been found', 0Dh, 0Ah, '$'

    cmdline_input_max_length equ 127 ;max length in command line
    cmdline_input_length db ? ;actual length from command line
    cmdline_text db cmdline_input_max_length dup ('$') ;variable for text from command line
    cmd_file_path db cmdline_input_max_length dup('$') ;variable for path
    path_to_file db cmdline_input_max_length dup ('$') ;ready path
   
    flag dw 0 ;flag to check if it's the beginning of the file
    fend dw 0 ;flag to check if it's the end of the file

.STACK 100h
    
.CODE

;macros

;to avoid empty input in command line
check_if_empty macro str,is_zero
    push si
    mov si, offset str
    call strlen ;use the procedure to count the length 
    pop si
    cmp ax, 0
    je is_zero  ;if the length is 0, it's an error
endm

;macro to print messages
print macro out_str
    push ax
    push dx
    mov dx,offset out_str
    mov ah,9
    int 21h
    pop dx
    pop ax
endm


;macro to input string
input_string macro str
    push bx
    push cx
    push dx

again:     ; check empty word input
    mov ah, 0Ah ;function to input a string (not a symbol)
    mov dx,offset str
    int 21h
    
    mov ax,0
    mov cx,0
    mov cl, [word + 1] ;in [word+1] position the length is stored, we need to check if it's not 0
    cmp cl, 0 ; if str is empty restart input
    je again
    
    pop dx
    pop cx
    pop bx
endm

;macro to output a number (we need to transform the number into a string)
output_number macro
    local division
    local transfrom_and_output
    local exit
    ;the number of lines is stored in ax
    push ax
    push cx
    push -1; break condition
    mov cx, 10
division:
    mov dx,0
    mov ah,0
    div cl; al - entire part, ah - remainder
    mov dl, ah ;save remainder to stack
    push dx ;save rests in stack
    cmp al, 0 ;continue until the entire part is 0
    jne division
    
    mov ah, 2 ;interrupt func to output a symbol
    
transfrom_and_output: ;transformation to ascii
    pop dx ;remove one rest
    cmp dx, -1; if -1 break (it was our break condition)
    je exit ;if so, finish the process
    add dl, '0'; ascii code transformation
    int 21h ;output that symbol
    jmp transfrom_and_output
exit:
    mov dl, ' '
    int 21h
    pop cx
    pop ax
endm


;macros to work with a file

;macro to open a file
fopen macro
    mov dx, offset path_to_file
    mov ah, 3Dh ;open existing file with the path in dx
    mov al, 00h ;access mode is set to 0 because we need only reading
    int 21h ;open the file
    jc exit ;if c flag is set, there's a problem
    mov bx, ax ;store file identificator from ax in bx, it will be used later
endm
 
 
;macro to close a file 
fclose macro
    mov ah, 3Eh; close file
    int 21h
endm


;macro to read a symbol from file
fread macro
    local continue
    push ax
    push cx
    push dx
    
    mov cx, 1 ;set the number of bytes we want to read (one because one symbol)
    mov dx, offset buf ;buffer to store readen data
    
    mov ah, 3Fh; read one byte from file 
    int 21h
    jc exit ;if c flag is set -> there's a problem
    ;the number of readen bytes is now in ax             
    mov cx, ax ;save the amount of readen bytes to cx
    test cx, cx ; check if it's end of file (logical and)
                ;if cx is 0, we have reached the end of file
    jnz continue;if not, it's not the end and we don't set the flag
    mov fend,1 ;we set the flag in case of the file's end
    ;fclose
    ;jmp good_exit ;go to the finish   
    
continue:
    pop dx
    pop cx
    pop ax
endm

;macro to move the file pointer on one position to left
fptr_back macro
    push dx
    mov ah,42h ;corresponding interrupt
    mov bx,5 ;file's identificator
    mov al,1 ;move ptr relatively to current position
    mov cx,-1 ;the distance in CX:DX
    mov dx,-2
    int 21h
    pop dx 
endm

;macro to move the file pointer on one position to right
fptr_forward macro
    push dx
    mov ah,42h
    mov al,1
    mov dx,0
    mov cx,0
    int 21h ;file pointer
    pop dx 
endm 

;procedures

;procedure that checks that the path is correct
parse_cmdline_text proc
    push bx
    push cx
    push dx
    
    mov cl, cmdline_input_length ;the length of cmdline text is in cl now, it will be used for a loop                         
    mov ch,0
    
    mov si, offset cmd_file_path; cmdline text offset to source
    mov di, offset path_to_file ; parsing path offset to data
    call to_asciiz ;transmit it to path
    
    ;check_if_empty path_to_file, bad_cmd_args ;if the path is empty, there's an error          
    ;jmp good_cmd_args ;else everything is okay 

;bad_cmd_args:
    ;print msg_bad_args ;print error message 
    ;mov ax, 1
    ;jmp end_parse_cmd_text
    
good_cmd_args:
    mov ax, 0 ;save 0 to ax if everything is okay
    
end_parse_cmd_text:
    pop bx
    pop cx
    pop bx
    ret    
parse_cmdline_text endp


;procedure to transmit text from cmdline to variable path
to_asciiz proc
    push ax
    push cx
    push di

parse_to_asciiz:
        mov al, ds:[si] ;save to al a symbol from data segment starting with cmdline_text position
        ;check if it's a delimiter
        cmp al, ' ' ;space 
        je is_delimiter
        cmp al, 0Dh ;cret
        je is_delimiter
        cmp al, 09h ;tabulation
        je is_delimiter
        cmp al, 0Ah ;new line
        je is_delimiter
        cmp al, 00h ;nothing
        je is_delimiter
        cmp al, '$' ;end
        je is_delimiter
        
        mov es:[di], al; write symbol to additional data segment, where path variable is situated 
        inc di ;increment indexes and restart the process                
        inc si                 
loop parse_to_asciiz
    
is_delimiter: ;it's the end of the parse
    mov al, 00h
    mov es:[di], al
    mov al, '$'
    inc di
    mov es:[di], al
    inc si
    
    pop di
    pop cx
    pop ax 
    ret
to_asciiz endp 


;procedure to determine the length of the line
strlen proc
    push bx
    push si
    mov ax,0 ;length will be stored in ax
count_strlen:
    mov bl, ds:[si] ;pull symbols from the cmdline text until it's null
    cmp bl, 00h
    je end_strlen
    inc si
    inc ax ;increment counter
    jmp count_strlen
end_strlen:
    pop si
    pop bx
    ret
strlen endp
    
;Here we start looking for lines containing the word
count_rows:
    mov dx,0 ;start value is set to 0
    
search:
    fread ;read one symbol
    cmp fend,1 ;check if it's file's end
    je good_exit
    mov al, [word+2];mov word's first symbol to al (first 2 doesn't contain word's symbols)
    mov cl, [buf];mov readen symbol to cl
    cmp cl, al;compare these symbols
    je check_possible_word;if they are equal, it's a possible word
    mov flag,1 ;if no, we set flag to 1 because the beginning of the file is already checked
    jmp search ;continue searching
    
check_possible_word:
    cmp flag,0 ;if flag is set to 0, it means that we are just at the beginning
               ;so we don't need to check if there is space or new line symbol before
    je check_word ;and we go straight to word checking
    fptr_back ;if it's not the beginning, we should check the previous symbol 
              ;by moving file pointer one position back
    fread ;read previous byte
    mov cl,[buf];mov readen byte to cl
    cmp cl,' ' ;if it's space it is a word
    je help2 ;we can check it further
    cmp cl, 0Ah;if it's new line it is a word
    je help2 ;we can check it 
    ;IT'S ALSO POSSIBLE TO ADD OTHER SYMBOLS
    jmp help1; if nothing has been met, return to search 
    
help1:
    fptr_forward ;move file pointer back to its position
    fread ;read again
    jmp search;continue searching

help2:
    fptr_forward ;;move file pointer back to its position
    fread ;read again   
    
check_word:
    mov flag,1 ;flag is set to 1 because we have already checked the beginning
    lea si, word+2 ;load the adress of word variable into si
    mov al, [si] ;move symbol to al
    mov ah, 1 ;ah is set to 1 because one symbol is already checked
    
while:
    inc ah
    inc si
    mov al, [si];mov a symbol from the word to al
    mov cl, [word+1];mov length of the word to cl
    cmp ah, cl ;compare counter and word's length
    jg possible_word ;if counter is already greater, than it can be a possible word
    fread ;read a symbol from file 
    cmp fend,1;check if it's the file's end
    je good_exit ;if so go to exit
    mov cl, [buf];mov readen symbol to cl
    cmp al, cl;compare a symbol from the word and from the files
    jne search;if not equal, it's not the word we're looking for, so start searching again
    je while ;if equal continue checking
    
    
possible_word:
    fread ;read the next symbol from the file
    cmp fend,1;check if it's the end of the file 
    je last_inc ;if so, increment row counter and exit
    mov cl, [buf];if not, load this symbol to cl
    cmp cl,' ';check if it's space
    je success;if so, it's a word and we increment row counter
    cmp cl,0Dh;check if it's a caret symbol
    je success;if so, it's a word and we increment row counter
    cmp cl,00h;compare it with null
    je success;if so, it's a word and we increment row counter
    jmp helper;if nothing of listed above was met, go to helper
    
last_inc:
    inc dx ;increment when it's the file's end
    jmp good_exit
    
helper:
    fptr_back ;return file pointer back (after check)
    jmp search;continue looking for a word
    
success:
    fptr_back ;return file pointer back (after check)
    inc dx ;increment row counter
    ;skip the line where we have already found the word
skip:    
    fread ;read next symbol
    cmp fend,1;check if it's file's end
    je good_exit;if so, finish
    mov al, 13;mov caret symbol ascii code to al
    mov cl, [buf];mov readen symbol to cl
    cmp al, cl;check if readen symbol is equal to cret
    jne skip ;if it's not a new line, check next symbol
    fread ;here we start checking new line
    cmp fend,1 
    je good_exit ;if it was file's end, finish program 
    jmp search;else start searching in new line
    
    jmp count_rows_end ;if we didn't reach good exit, there was a problem   
    
start:
    mov ax, @data ;the beginning of data in our program
    mov es, ax ;mov it to additional data segment
    mov ch,0
    mov cl, ds:[80h];command line and DTA area are situated at 80h offset
                    ;in cl the cmdline text length is stored now
    mov cmdline_input_length, cl ;move it to the variable 
    mov si, 82h  ;82 because first symbol is situated at this adress
    ;81h - space or tabulation
    mov di, offset cmdline_text
    rep movsb  ;text from command line to variable cmd_text
    mov ds, ax
    
    mov si, offset cmdline_text ;all text from command line
    mov di, offset cmd_file_path ;path to file 
    mov cx,0  
    
copy_loop: ;copy text from command line to path
    mov al, [si]           
    cmp al, ' ' ;if we meet space, we reached the path's end          
    je word_copy
    cmp al,'$' ;if this symbol has been met, user didn't input any word, it's an error
    je no_word            
    mov [di], al           
    inc si                 
    inc di
    inc bl
    inc cx               
    jmp copy_loop

word_copy:
    mov bl,0 ; length of the word
    mov di, offset word
    mov [di], al           
    inc si                 
    inc di
    inc di
copy_word:
    mov al, [si]           
    cmp al, 0Dh ;if caret symbol has been met, finish checking           
    je finish            
    mov [di], al           
    inc si                 
    inc di
    inc bl               
    jmp copy_word
     
finish:
    cmp bl,50 ;check if length is less than 50
    jg long_word
    mov [di],'$'
    mov di, offset word
    inc di
    mov [di],bl ;mov length to the second position
    
    call parse_cmdline_text ;transform text from cmdline to ascii code
    test ax, ax ;check if ax is 0, if not, there were problems
    jne exit
    
    fopen ;open file
    print msg_amount_of_strings ;print prompt              
    jmp count_rows ;count rows containing this word
    
count_rows_end: ;we can be here if we had problems

exit:
    print msg_error ;print error message
    pop dx
    pop cx
    pop ax
    mov ax, 4c00h ;finish the program
    int 21h
long_word:
    print msg_warning_wordlength
    pop dx
    pop cx
    pop ax
    mov ax, 4c00h ;finish the program
    int 21h
no_word:
    print msg_no_word_error
    pop dx
    pop cx
    pop ax
    mov ax, 4c00h ;finish the program
    int 21h
good_exit:
    fclose
    pop cx
    pop ax
    mov ax, dx ;move the amount of rows in ax
    output_number ;output transforming to ascii
    mov ax, 4c00h ;finish the program
    int 21h
    

end start 
