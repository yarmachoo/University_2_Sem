.model small
.stack 100h
.data
        
        errMsq1 db "Error", '$'
        ;errMsq2 db \
        EntryMsqStr db 13,10,"$" 
        
        err_msq1 db "blocks are vanished", '$' 
        err_msq2 db "not enoght memory", '$'
        err_msq3 db "problems with ES", '$'
        
        errMessage1 db "Error", '$'
        errMessage2 db "Command line is empty :(", '$' 
        errMessage3 db "Please, enter a NUMBER in RANGE [0, 255]", '$'
        errMessage4 db "Error in memory allocation", '$' 
        
        runError0 db "File is not found :( $" 
        runError1 db "Access denied :( $"  
        runError2 db "Not enough memory :( $"   
        runError3 db "Wrong format :( $" 
        runError4 db "Path is not found :( $"
    
        cmdline_input_max_length equ 127
        cmdline_input_length db ?   
        cmdline_text db cmdline_input_max_length dup ('$') ;variable for text from command line
        cmd_file_path db cmdline_input_max_length dup('$') ;variable for path
        path_to_file  db cmdline_input_max_length dup ('$')
        path_to_file_length db ?       
        
        msg_invite_to_input_word db 'Enter the word that must be searched',0Dh,0Ah,'$'  
        msg_amount_of_strings db 'The amount of strings containing this word:',0Dh,0Ah,'$'
        msg_bad_args db 'Command line parse error', 0Dh, 0Ah, '$'
        msg_error db 0Dh, 0Ah, 'Error', 0Dh, 0Ah, '$'       
        msg_error_of_cmd db 0Dh, 0Ah, 'Error with input cmd parametrs', 0Dh, 0Ah, '$'
        msg_warning_wordlength db 'Word is longer than 50 symbols',0Dh, 0Ah, '$'
        msg_no_word_error db 'Word has not been found', 0Dh, 0Ah, '$'
        
        buf db 2, 0, 2 dup('$'), '$'
        
        N db 4 dup ('$')
        
        flag dw 0 ;flag to check if it's the beginning of the file
        fend dw 0 ;flag to check if it's the end of the file
        
        str_with_text db 200 dup(?)
        str_with_text_len db ?
        srt_with_text2 db ? 
        
        program1 db 20 dup('$')
        program2 db 20 dup('$')
        program3 db 20 dup('$')
        program3_data db ? 
        length db ?   
        
        num db 5 dup('$')
                
        EPB dw 0000
        cmd_off    dw ? 
        cmd_seg    dw ?
        fcb_1    dw 005Ch,0
        fcb_2 dw 006Ch,0  
        
        com_line db 0, 'e', 127 dup (0Dh)
       
dataLength = $ - errMsq1
        
.code        
;macro to open a file
fopen macro
    mov dx, offset path_to_file
    mov ah, 3Dh ;open existing file with the path in dx
    mov al, 00h ;access mode is set to 0 because we need only reading
    int 21h ;open the file  7    
    mov bx, ax ;store file identificator from ax in bx, it will be used later
endm

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

;macro to close a file 
fclose macro
    mov ah, 3Eh; close file
    int 21h
endm

atoi proc
    pusha
    push si
    
xor cx, cx
mov cl, 4
   
CHECK_DIGIT: 
    cmp [si], '$'
    je EXIT_FROM_CYCLE   
    cmp [si], '0'
    jb ERROR_GET 
    cmp [si], '9'
    ja ERROR_GET
    inc si
    loop CHECK_DIGIT 
    print errMessage3
    call exit
    
EXIT_FROM_CYCLE:
    cmp cl, 4
    je ERROR_GET
    pop si 
    xor ax, ax 
    xor bx, bx
    mov bl, 10
CONVERT:
    mov cl, [si]
    sub cl, '0'
    mul bx
    jc ERROR_GET
    add al, cl
    jz ERROR_GET
    inc si
    cmp [si], '$'
    jne CONVERT
    mov [N], al
    
    popa
    ret
 
    ERROR_GET: 
    print errMessage3 
    call exit
    
atoi endp

 proc         
     WRITE_CYCLE:
        mov al, es:[di]    
        cmp al, 0
        je END_OF_WRITE
        cmp al, ' '
        je END_OF_WRITE  
        cmp al, 9
        je END_OF_WRITE     
        cmp al, 0dh
        je END_OF_WRITE 
        mov [si], al               
        inc di
        inc si
        jmp WRITE_CYCLE    
                       
    END_OF_WRITE:          
    ret 
get_parametr endp

skip_spaces proc     
    dec di
    CYCLE:  
        inc di
        cmp es:[di], 0dh
        je END_OF_SKIPPING
        cmp es:[di], 0
        je CYCLE
        cmp es:[di], ' '
        je CYCLE
        cmp es:[di], 9     
        je CYCLE
    END_OF_SKIPPING:
    ret
skip_spaces endp

change_size proc
    mov ah,4Ah                  
    mov bx, ((codeLength / 16) + 1) + ((dataLength / 16) + 1) + 16 + 16 ;psp+stack+code+data
    int 21h 
    jc MEMORY_ISSUES
    ret  
    MEMORY_ISSUES: 
    cmp ax, 07
    je err1
    cmp ax, 08
    je err2
    cmp ax, 09
    je err2

err1: 
    print err_msq1
    call exit 
err2: 
    print err_msq2
    call exit
err3: 
    print err_msq3
    call exit
change_size endp

run_exe proc 
    mov ax, @data
    mov es, ax 
    
    mov al, num
    cmp al,'1'
    je run_1
    cmp al,'2'
    je run_2
    cmp al,'3'
    je run_3 
    call exit 
    
    run_1:
    lea dx, program1
    jmp run_program 
    
    run_2:
    lea dx, program2
    jmp run_program
    
    run_3:
    lea dx, program3  
    
run_program:

    mov ax, 4b00h
      
        mov bx, offset epb
        int 21h
        jc ERROR
    ret 
    ERROR:
    cmp ax, 02h
    jne error_1
    print runError0
    call exit
    
    error_1:
    cmp ax, 05h
    jne error_2
    print runError1
    call exit
    
    error_2:
    cmp ax, 08h
    jne error_3
    print runError2
    call exit
    
    error_3:
    cmp ax, 0Bh
    jne error_n
    print runError3
    call exit
    
    error_n:
    print errMessage1
    call exit 
run_exe endp

;procedure that checks that the path is correct
parse_cmdline_text proc
    push bx
    push cx
    push dx
    
    mov cl, cmdline_input_length ;the length of cmdline text is in cl now, it will be used for a loop                         
    mov ch,0
    
    mov si, offset cmd_file_path; cmdline text offset to source
    mov di, offset path_to_file ; parsing path offset to data  
    mov bx, 0000;
    call to_asciiz ;transmit it to path
    
good_cmd_args:
    mov ax, 0 ;save 0 to ax if everything is okay 
    dec bl 
    mov path_to_file_length, bl ; save length of path    
    
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
        inc bl
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

progrmMain:  

    mov dx,0 ;start value is set to 0
    mov ah, 0
    mov al, [path_to_file_length] ;get length of path
    
find_num_of_str: 

    mov di, offset cmdline_text
    ;mov di, offset str_to_find  
    add di, ax 
    inc di; start of firtst substr 
    mov bx, 0000 
    
    inc bl  
    mov al, [di] 
    mov num, al 
    inc di
    call skip_spaces
    lea si, N
    call get_parametr
    lea si, N  
    call atoi 
    
    mov al, N
    mov al, num
 
    cmp al, '1'
    je read_text_from_file
    cmp al, '2'
    je read_text_from_file
    cmp al, '3'
    je read_text_from_file
    call exit_with_error_cmd 
    
read_text_from_file:

    fopen  
    push ax
    
    ;read str from file:
    mov ah, 3Fh
    pop bx
    mov dx, offset str_with_text 
    mov cx, 40
    int 21h
    mov cx, ax
    mov str_with_text_len, cl
    
    ;add $ to text from file
    mov di, offset str_with_text
    mov bh, 0
    mov bl, str_with_text_len
    mov byte ptr [di + bx - 1], 0Dh
    mov byte ptr [di + bx], '$'
    
    fclose
    
    mov si, offset str_with_text 
        
    mov al, num
    cmp al, '1'
    je first_str
    cmp al, '2'
    je second_str
    cmp al, '3'
    je third_str
    call exit_with_error_cmd

first_str:   

    mov length, 0 
    mov cl, length
    
    read_by_bytes1:
        
        mov ax, [si]
        cmp [si], 0Dh
        je repeat_program1
        cmp [si], ' '
        je repeat_program1
        cmp [si],'$'
        je exit 
        
        inc si
        inc cl
        mov length, cl
        jmp read_by_bytes1
        
    repeat_program1:
           
    sub si, cx
    mov ax, [si]     
     
    lea di, [program1]
    rep movsb
             
    mov si, offset program1 
    add si, cx
    mov si, 0 ;add $ to end of file
    
    print program1 
    
    call change_size   

    mov cl, byte ptr[N] 

    RUN_EXE_CYCLE:   
    call run_exe
    loop RUN_EXE_CYCLE

    call exit
    
;/////////////////////////////////////////////////////////////////////////
    
second_str:
    
    mov length, 0 
    mov cl, length
     
    read_by_bytes2:

        cmp [si],0Dh
        je right_str 
        cmp [si],' '
        je right_str
        cmp [si],'$'
        je exit 
        inc si
        
        inc cl
        mov length, cl
        jmp read_by_bytes2   
         
right_str:  
    inc si;
    
    mov length, 0 
    mov cl, length
    
    read_by_bytes22:

        cmp [si],0Dh
        je repeat_program2 
        cmp [si],'$'
        je exit
        inc cl
        inc si
        mov length, cl
        
        jmp read_by_bytes22
        
    repeat_program2: 
        
    sub si, cx
    mov ax, [si]     
     
    lea di, [program2]
    rep movsb
             
    mov si, offset program2 
    add si, cx
    mov si, 0 ;add $ to end of file 
    
    print program2
    
;////////////////////////////////////////////////////////////

    third_str: 
    
    mov length,0; num of str
    xor cx, cx
    
    second_round:
    
    inc length
    inc si
          
    read_by_bytes3:

        cmp [si],0Dh
        je right_str2
        cmp [si],'$'
        je exit
        
        inc cl 
        inc si
        jmp read_by_bytes3   
         
right_str2:
 
    cmp length, 1
    je second_round
    
    inc length
    inc si
    xor cx,cx
    
    read_by_bytes32:

        cmp [si],' '
        je repeat_program3
        cmp [si],'$'
        je exit   
        cmp [si],0Dh
        je exit
        inc cl 
        inc si
        mov length, cl
        jmp read_by_bytes32
        
    repeat_program3:   
    
    ;get data: 
    push cx
    push si     
    mov ax, [si]
    inc si
    mov ax, [si]      
    
    lea di, [program3_data]
    mov cx,1
    movsb 
    
    inc si 
    mov ax, [si]
    mov si, '$' 
    inc di
    movsb  
            
save_name_of_program3:
    
    dec si
    dec si
    dec si
    pop si
    
    pop cx
    
    sub si, cx
    mov ax, [si] 
     
    lea di, [program3]
    rep movsb
             
    mov si, offset program3  
    add si, cx
    mov si, 0 ;add $ to end of file 
    
    print program3
    
    print program3_data
    
    get_data:
       
    ;do:
    ;if num == 1: get name.exe => repeat k times
    ;if num == 2: get name.exe => repeat k times and do input
    ;if num == 3: get name.exe SPACE number 
    
    ;else bye bitch
    

exit:  
  
    mov ax,4C00h
    int 21h 
    
start:
    mov ax, @data   ;the beginning of data in our program
    mov es, ax      ;mov it to additional data segment
    mov ch,0
    mov cl, ds:[80h];command line and DTA area are situated at 80h offset
                    ;in cl the cmdline text length is stored now
    mov cmdline_input_length, cl ;move it to the variable 
    mov si, 82h         ;82 because first symbol is situated at this adress
                        ;81h - space or tabulation
    mov di, offset cmdline_text
    rep movsb  ;text from command line to variable cmd_text
    mov ds, ax
    
    mov bx, offset com_line
    mov cmd_off, bx
    mov ax, ds             
    mov cmd_seg, ax
    
    xor bx, bx
    
    mov si, offset cmdline_text ;all text from command line
    mov di, offset cmd_file_path ;path to file 
    mov cx,0  
    
copy_loop: ;copy text from command line to path  
    mov al, [si]           
    cmp al, 0Dh ;if we meet space, we reached the path's end          
    je finish
    cmp al,'$' ;if this symbol has been met, user didn't input any word, it's an error
    je no_word            
    mov [di], al           
    inc si                 
    inc di
    inc bl
    inc cx               
    jmp copy_loop
     
finish:
    cmp bl,50 ;check if length is less than 50
    jg long_word
    
    call parse_cmdline_text ;transform text from cmdline to ascii code
    test ax, ax ;check if ax is 0, if not, there were problems
    jne exit2
    print path_to_file  
    
    fopen
    
    print EntryMsqStr
    jc checking:
    jmp OKey
checking:    
    cmp ax, 02h
    je exit1_Bitch
    cmp ax, 03h
    je exit2_Bitch
    cmp ax, 04h
    je exit3_Bitch
    cmp ax, 05h
    je exit4_Bitch
    cmp ax, 0Ch
    je exit5_Bitch 
    jmp OKey 

exit1_Bitch:
    print errMsq1
    print runError0
    call exit  
    
exit2_Bitch: 
    print errMsq1
    print runError4
    call exit
    
exit3_Bitch:   
    print errMsq1
    print runError2
    call exit 
    
exit4_Bitch: 
    print errMsq1
    print runError1
    call exit 
    
exit5_Bitch: 
    print errMsq1
    print runError3
    call exit  
    
OKey:     
    
    print EntryMsqStr
    ;print msg_amount_of_strings ;print prompt              
    jmp progrmMain ;count rows containing this word
    
count_rows_end: ;we can be here if we had problems

exit2:
    print msg_error ;print error message
    pop dx
    pop cx
    pop ax
    mov ax, 4c00h ;finish the program
    int 21h 
    
exit_with_error_cmd:
    print msg_error_of_cmd ;print error message
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
    mov ax, dx      ;move the amount of rows in ax
    output_number   ;output transforming to ascii
    mov ax, 4c00h ;finish the program
    int 21h
    
codeLength = $ - begin
end start