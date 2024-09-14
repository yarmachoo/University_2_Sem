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
    
    find_text db "Input word to find: ",0Dh, 0Ah, 24h
    replace_text db "Input word to replace: ",0Dh, 0Ah, 24h
    text db "Input text: ",0Dh, 0Ah, 24h 
    
    empty_msg db 13,10,"$" 
       
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
    ;mov ax,cs
    ;mov ds,ax
    ;mov es,ax 
    
    print text
    input strWithText   
    
    print empty_msg
    
    print find_text
    input strToFind
    
    mov al,strToFindLen
    mov ah,0
    mov sfindL,ax  
    
    print empty_msg
    
    print replace_text
    input strToReplace  
    
    mov al,strToReplaceLen
    mov ah,0
    mov sreplL,ax 
    
    print empty_msg
    
    ;cld
    mov si,offset strtext2 
    mov di,offset outtext
      
m0: lodsb
    stosb
    cmp al,0Dh 
    jz outprint
    call find    
    jnz m0    
    call replace 
    jmp m0
       
outprint: print empty_msg
    mov si,offset outtext
    
m1: lodsb      
    cmp al,0Dh   
    jz exit
    mov dl,al  
    mov ah,2
    int 21h
    jmp m1 
       
exit:   
    mov ax,4C00h
    int 21h
 
find:   
    push si  
    push di
    mov cx,sfindL
    sub si,cx
    cmp si,offset strtext2 
    jc  return_no 
    mov di,offset strfind2 
    repe cmpsb
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