.model small 
.stack 100h
.data 
    errMessage1 db "Error", '$'
    errMessage2 db "Command line is empty :(", '$' 
    errMessage3 db "Please, enter a NUMBER in RANGE [0, 255]", '$'
    errMessage4 db "Error in memory allocation", '$' 
    
    msg_error_of_cmd db 0Dh, 0Ah, 'Error with input cmd parametrs', 0Dh, 0Ah, '$'
       
    runError0 db "File is not found :( $" 
    runError1 db "Access denied :( $"  
    runError2 db "Not enough memory :( $"   
    runError3 db "Wrong format :( $"
    
    endl db 0Dh, 0Ah, '$'
    
    N db 4 dup ('$')
    K db 4 dup ('$')  
    
    program1 db 20 dup('$')
    program2 db 20 dup('$')
    program3 db 20 dup('$')
    program3_data db ? 
    
    str_with_text db 200 dup(?)
    str_with_text_len db ?
    srt_with_text2 db ? 
    
    length db ?
                       
    path_to_file  db 64 dup (0)
    path_to_file_length db ?
                       
    name_exe db 64 dup ('$') 
    
    EPB dw 0000
    cmd_off    dw ? 
    cmd_seg    dw ?
    fcb_1    dw 005Ch,0
    fcb_2 dw 006Ch,0
        
    com_line db 127 dup (0Dh)

dataLength = $ - errMessage1          
.code
begin: 
ASSUME cs:code, ds:data  

display macro string
    push ax
    displaySingle string
    displaySingle endl
    pop ax
endm 
 
displaySingle macro string
    mov dx,offset string
    mov ah, 09h
    int 21h
endm  

exit proc 
   mov ah,4ch               
   int 21h
   ret   
exit endp

fopen macro
    mov dx, offset path_to_file
    mov ah, 3Dh ;open existing file with the path in dx
    mov al, 00h ;access mode is set to 0 because we need only reading
    int 21h ;open the file  7    
    mov bx, ax ;store file identificator from ax in bx, it will be used later
endm

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
    display errMessage3
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
    display errMessage3 
    call exit
    
atoi endp

get_name_exe proc  
    
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
        
    mov al, byte ptr[K]
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
        
        push si
        
        lea si, program1 
        add si, cx              
        mov [si], ax
        mov ax, [si]
        
        pop si 
        
        inc si
        inc cl
        inc di
        mov length, cl
        jmp read_by_bytes1
        
    repeat_program1:
           
    mov si, offset program1
    mov ax, [si]    
    add si, cx  
    ;dec si
    mov [si], 0
    inc si
    mov [si], '$'  

ret     
second_str:
third_str:
get_name_exe endp

scan_cmd proc  
    ; command_line parametrs: N filename K file_attributes
   mov si,80h
   cmp byte ptr es:[si],0
   je EMPTY_LINE
    
   mov di, 82h
   call skip_spaces
   lea si, N
   call get_parametr
   lea si, N  
   call atoi
   
   call skip_spaces
   lea si, path_to_file
   call get_parametr
   
   call skip_spaces
   lea si, K
   call get_parametr
   
   call skip_spaces
   lea si, com_line+1
   mov [com_line], 0
   dec di
   GET_PARAMETRS:
        cmp es:[di], 0dh
        je END_SCANNING
        
        mov al, es:[di]
        mov [si], al      
        
        inc si
        inc di
        inc [com_line]
        jmp GET_PARAMETRS
        
   END_SCANNING:
        ret
         
    EMPTY_LINE:
    display errMessage2
    call exit     
scan_cmd endp

exit_with_error_cmd:
    display msg_error_of_cmd ;print error message
    pop dx
    pop cx
    pop ax
    mov ax, 4c00h ;finish the program
    int 21h
    
get_parametr proc         
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
    mov bx, ((codeLength / 16) + 1) + ((dataLength / 16) + 1) + 16 + 16;psp+stack+code+data
    int 21h 
    jc MEMORY_ISSUES
    ret  
    MEMORY_ISSUES:
    display errMessage4
    call exit
change_size endp

run_exe proc 
    mov ax, @data
    mov es, ax
    
    mov al, byte ptr[K]
    cmp al,'1'
    je run_1
    cmp al,'2'
    je run_2
    cmp al,'3'
    je run_3 
    call exit 
    
    
    run_1: 
    mov si, offset program1 
    display program1
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
    display runError0
    call exit
    
    error_1:
    cmp ax, 05h
    jne error_2
    display runError1
    call exit
    
    error_2:
    cmp ax, 08h
    jne error_3
    display runError2
    call exit
    
    error_3:
    cmp ax, 0Bh
    jne error_n
    display runError3
    call exit
    
    error_n:
    display errMessage1
    call exit 
run_exe endp 

start:
mov ax, data
mov ds, ax
call scan_cmd 

call get_name_exe 

call change_size 

mov bx, offset com_line
mov cmd_off, bx
mov ax, ds
mov cmd_seg, ax  

mov cl, byte ptr[N] 

RUN_EXE_CYCLE:   
call run_exe
loop RUN_EXE_CYCLE

call exit 
codeLength = $ - begin
    
end start