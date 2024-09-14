;parameteres for this program must be entered in command line
;FILE_PATH space WORLD$WORLD
  
; D:\Uni\CProg\emu8086\vdrive\C\file.txt hello$daddy
 
.MODEL small
.DATA    
    
    strToFind db 20         
        
    strToReplace db 20
    
    strWithText db 200   
    strLen2 db 0
    strtext2 db 200 dup(0)
    
    outtext db 200 dup (0) 
    
    strTextLen db 0
    strToFindLen db 0 
    strToReplaceLen db 0
    
    sfindL dw 0
    sreplL dw 0
    
    findTextMsqStr db "Input word to find: ",0Dh, 0Ah, 24h
    replace_text db "Input word to replace: ",0Dh, 0Ah, 24h
    text db "Input text: ",0Dh, 0Ah, 24h 
    
    EntryMsqStr db 13,10,"$"
    
    path	DB    "c:\file.txt", 0
    ;buf	DB    29 dup(0) 
     
    word db 50, 0, 50 dup('$'), '$' ;variable for a word
    buf db 2, 0, 2 dup('$'), '$' ;for a symbol from file
    
    msg_invite_to_input_word db 'Enter the word that must be searched',0Dh,0Ah,'$'  
    msg_amount_of_strings db 'The amount of strings containing this word:',0Dh,0Ah,'$'
    msg_bad_args db 'Command line parse error', 0Dh, 0Ah, '$'
    msg_error db 0Dh, 0Ah, 'Error', 0Dh, 0Ah, '$'       
    msg_error_of_cmd db 0Dh, 0Ah, 'Error with input cmd parametrs', 0Dh, 0Ah, '$'
    msg_warning_wordlength db 'Word is longer than 50 symbols',0Dh, 0Ah, '$'
    msg_no_word_error db 'Word has not been found', 0Dh, 0Ah, '$'

    cmdline_input_max_length equ 127 ;max length in command line
    cmdline_input_length db ? ;actual length from command line
    cmdline_text db cmdline_input_max_length dup ('$') ;variable for text from command line
    cmd_file_path db cmdline_input_max_length dup('$') ;variable for path
    path_to_file db cmdline_input_max_length dup ('$') ;ready path
    path_to_file_length db ?
   
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
    
;Here we start looking for lines containing the word
count_rows:
    mov dx,0 ;start value is set to 0
    mov ah, 0
    mov al, [path_to_file_length] ;get length of path  
    
find_first_str:
    mov si, offset cmdline_text
    mov di, offset strToFind  
    add si, ax 
    inc si; start of firtst substr 
    mov bx, 0000
    
loop_to_find_end_of_first_str:
    inc bl  
    mov al, [si]
    cmp al, '$' ; if true it is the end of 1st word
    je end_of_1st_str  ;\\\\\\\\\\\\\\\\\\\\ 
    cmp al, 0Dh ; if true it is the end of 1st word
    je exit_with_error_cmd  ;\\\\\\\\\\\\\\\\\\\\
    mov es:[di], al
    
    inc di
    inc si
loop loop_to_find_end_of_first_str 

end_of_1st_str:
    dec bl
    mov ds:[strToFindLen], bl 
    inc di
    mov es:[di], 0Dh
    inc di 
    mov es:[di], '$'
    inc si
    mov di, offset strToReplace
    mov bx, 0000   
    
find_word_to_replace:
    inc bl
    mov al, [si]
    cmp al, 0Dh ; if true it is the end of 1st word
    je end_of_2st_str  ;\\\\\\\\\\\\\\\\\\\\
    mov es:[di], al
    
    inc di
    inc si
loop find_word_to_replace 

end_of_2st_str:  
    dec bl
    mov strToReplaceLen, bl
    inc di
    mov es:[di], 0Dh
    inc di 
    mov es:[di], '$'
    inc si
    
printer:
    print strToFind
    print EntryMsqStr
    print strToReplace

read_text_from_file:
    mov al,strToFindLen
    mov ah,0
    mov sfindL,ax
    mov al,strToReplaceLen
    mov ah,0
    mov sreplL,ax
        
    ;open exist file
   	MOV   AX,  3D00h	
   	MOV   DX,  offset path	
   	INT   21h	
   	PUSH  AX	  
   	;read from file
   	MOV   AH,  3Fh	
   	POP   BX	
   	MOV   DX,  offset strWithText	
   	INT   21h   
   	MOV   CX, AX
   	MOV   strTextLen, CL 
   	;add $ to file
   	MOV DI,  offset strWithText	
	mov bh,0
    mov bl,strtextlen		
	MOV   BYTE PTR [DI+BX], '$'     
	MOV   BYTE PTR [DI+BX-1], 0Dh 
   	;close file
   	MOV   AH,  3Eh	
   	INT   21h   
   	;open exist file
   	MOV   AX,  3D00h	
   	MOV   DX,  offset path	
   	INT   21h	
   	PUSH  AX
   	;read from file 
   	MOV   AH,  3Fh	
   	POP   BX	
    MOV   DX,  offset strtext2	
   	INT   21h           
     
   	;close file
   	MOV   AH,  3Eh	
   	INT   21h 
   	    
   	;add $ to file
   	MOV DI,  offset strtext2	
	mov bh,0
    mov bl,strtextlen		
	MOV   BYTE PTR [DI+BX], '$'   
	MOV   BYTE PTR [DI+BX-1], 0Dh
	  
	mov al, strTextLen 
	mov ah, 0     
	
	mov al, strTextLen
	mov bl, [strToFindLen]
	sub al, bl
	add al, [strToReplaceLen] 
	mov strLen, al  
	mov al, strLen 
	mov si, offset strWithText
	inc si
	inc si
    mov di,offset outtext
      
Do: lodsb     ;load si to al/ax
    stosb     ; save di in al
    mov al, [di] 
    mov al, [si]
    stosb
    dec di
    cmp al,0Dh   ; is it end of str?? 
    jz outprint   ; if yes go to outprint
    call find     ; if no lets find
    jnz Do        
    call replace 
    jmp Do
       
outprint: 
    
    print EntryMsqStr
    mov si,offset outtext
    mov bh, 0
   	mov bl, 0
   	;print outtext 
    
    
PrintResult: 
    lodsb
    inc bx         
    cmp al,0Dh   
    jz exit
    mov dl,al  
    mov ah,2
    int 21h
    jmp PrintResult 
       
exit:  
    mov strLen, bl
    mov bl, 1
    mov bl, strLen 
    
    ;open file
    MOV   AX,  3D02h	;????????? ???? ??? ??????
   	MOV   DX,  offset path	;???? ? ?????
   	INT   21h		;????? ??????? 3Dh 
   	push  AX 
   	;correct caretka
   	push ax
   	mov AX, 42h 
   	POP BX
   	mov dx, 0
   	mov al, 0
   	;write in file
   	MOV   AH,  40h		;?????????? ? ????
   	POP   BX		;????????????? ?????
   	MOV   DX,  offset outtext	;????? ?????? ? ???????
   	mov ch, 0
   	MOV   CL,  strLen		;????? ?????????? 29 ??????
   	INT   21h		;????? ??????? 40h   
   	;open exist file
   	MOV   AX,  3D00h	;????????? ???? ??? ??????
   	MOV   DX,  offset path	;???? ? ?????
   	INT   21h		;????? ??????? 3Dh
   	PUSH  AX		;???????? ? ???? ????????????? ?????
   	;read from file
   	MOV   AH,  3Fh		;?????? ?? ?????
   	POP   BX		;????????????? ?????
   	MOV   DX,  offset outtext	;????? ?????? ??? ??????
   	INT   21h
   	;close file
   	MOV   AH,  3Eh		;????????? ????
   	INT   21h
   	;
   	mov si, offset outtext 
   	mov bh, 0
   	mov bl, strLen
   	mov BYTE PTR [DI + BX], '$'   
    mov ax,4C00h
    int 21h
 
find:   
    push si                  ;save si
    push di                  ; save di
    mov cx,sfindL            ;amount of finding str letters  
    mov al, [di]
    mov al, [si]
    sub si,cx   
    ;mov al, [strtext2]             ; si-cx -> 
    cmp si,offset strtext2; cmp if start from si-cx with str to find
    jc  return_no            ; if cf=1/ if below
    mov di,offset strToFind   ; if not below -> di=strfind2
    ;mov al, [di]
    repe cmpsb               ; repeat while is equal si and di
    pop di                   
    pop si
    ret 
          
return_no:    
    mov dl,1
    or dl,dl 
    inc di
    mov di, 0Dh
    pop di
    pop si
    ret
 
replace:
    push si 
    ;dec si
    ;dec di 
    sub di,sfindL 
    mov cx,sreplL 
    mov si,offset strToReplace
    rep movsb
    pop si
    
	RET
    
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
    jne exit2
    print path_to_file
    fopen ;open file
    print EntryMsqStr
    ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    print msg_amount_of_strings ;print prompt              
    jmp count_rows ;count rows containing this word
    
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
    mov ax, dx ;move the amount of rows in ax
    output_number ;output transforming to ascii
    mov ax, 4c00h ;finish the program
    int 21h
    

end start