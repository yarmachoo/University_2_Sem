.model small
.code
org 100h
jmp start  
    strToFind db 20
    strToFindLen db 0
    strfind2 db 20 dup (0)    
    
    strToReplace db 20
    strToReplaceLen db 0
    strrepl2 db 20 dup (0)     
    
    strWithText db 200
    strTextLen db 0
    strtext2 db 200 dup (0)     
    
    outtext db 200 dup (0) 
    
    sfindL dw 0
    sreplL dw 0
    
    findTextMsqStr db "Input word to find: ",0Dh, 0Ah, 24h
    replace_text db "Input word to replace: ",0Dh, 0Ah, 24h
    text db "Input text: ",0Dh, 0Ah, 24h 
    
    EntryMsqStr db 13,10,"$" 
       
print macro txt
    mov dx,offset txt
    mov ah,9
    int 21h
endm   

input macro buf
    mov dx,offset buf
    mov ah,10
    int 21h
endm

start:    
    mov ax,cs
    mov ds,ax
    mov es,ax 
    
    print text
    input strWithText     
    mov al,strTextLen
    mov ah,0  
    
    mov al, strWithText
    mov al, strTextLen  
    mov al, [strtext2]
    mov al, strtext2 
    
    mov al, 1[strtext2]
    
    print EntryMsqStr
    
    print findTextMsqStr
    input strToFind
    
    mov al,strToFindLen
    mov ah,0
    mov sfindL,ax  
    
    print EntryMsqStr
    
    print replace_text
    input strToReplace  
    
    mov al,strToReplaceLen
    mov ah,0
    mov sreplL,ax         
    
    mov si,offset strtext2    ;with zeroes   
    mov di,offset outtext 
        
Do: lodsb     ;load si to al/ax
    stosb     ; save di in al 
    mov al, [di]
    mov al, [si]
    cmp al,0Dh   ; is it end of str??
    jz outprint   ; if yes go to outprint
    call find     ; if no lets find
    jnz Do        
    call replace 
    jmp Do
       
outprint: print EntryMsqStr
    mov si,offset outtext
    
PrintResult: lodsb      
    cmp al,0Dh   
    jz exit
    mov dl,al  
    mov ah,2
    int 21h
    jmp PrintResult 
       
exit:   
    mov ax,4C00h
    int 21h
 
find:   
    push si                  ;save si
    push di                  ; save di
    mov cx,sfindL            ;amount of finding str letters
    sub si,cx                ; si-cx -> 
    cmp si,offset strtext2   ; cmp if start from si-cx with str to find
    jc  return_no            ; if cf=1/ if below
    mov di,offset strfind2   ; if not below -> di=strfind2
    repe cmpsb               ; repeat while is equal si and di
    pop di                   
    pop si
    ret 
          
return_no:    
    mov dl,1
    or dl,dl
    pop di
    pop si
    ret
 
replace:
    push si 
    sub di,sfindL 
    mov cx,sreplL 
    mov si,offset strrepl2
    rep movsb
    pop si
    ret
    
    end start