.model	small 
ORG   100h	 	     		        
.data    
    strWithText db 200   
    strLen db 0
    strtext2 db 200 dup(0)    
    
    strToFind db 20
    strToFindLen db 0
    strfind2 db 20 dup (0)   
        
    strToReplace db 20
    strToReplaceLen db 0
    strrepl2 db 20 dup (0)
    
    outtext db 200 dup (0) 
    
    strTextLen db 0
    
    sfindL dw 0
    sreplL dw 0
    
    findTextMsqStr db "Input word to find: ",0Dh, 0Ah, 24h
    replace_text db "Input word to replace: ",0Dh, 0Ah, 24h
    text db "Input text: ",0Dh, 0Ah, 24h 
    
    EntryMsqStr db 13,10,"$"
    
    path	DB    "c:\file.txt", 0
    buf	DB    29 dup(0)
    

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
.code
start: 
    mov ax,cs
    mov ds,ax
    mov es,ax
    
    ;print text
    ;input strWithText     
    ;mov al,strTextLen
    ;mov ah,0
    
    ;print EntryMsqStr       
         
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
	;MOV   BYTE PTR [DI+BX], '$'
	;MOV   BYTE PTR [DI+BX-1], '$'   
	MOV   BYTE PTR [DI+BX], 0Dh 
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
   	
   	mov al, [strWithText]  
   	mov al, strWithText
    mov al, strTextLen
    mov al, strTextLen  
    mov al, [strtext2]
    mov al, strtext2
    mov al, 1[strtext2] 
     
   	;close file
   	MOV   AH,  3Eh	
   	INT   21h 
   	    
   	;add $ to file
   	MOV DI,  offset strtext2	
	mov bh,0
    mov bl,strtextlen		
	MOV   BYTE PTR [DI+BX], '$'   
	MOV   BYTE PTR [DI+BX-1], 0Dh
	;write on console  
	print EntryMsqStr
	;print strWithText
	  
	mov al, strTextLen 
	mov ah, 0 
	 
	print EntryMsqStr   
	
	print EntryMsqStr
	
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
    mov al, [strtext2]               ; si-cx -> 
    cmp si,offset strtext2; cmp if start from si-cx with str to find
    jc  return_no            ; if cf=1/ if below
    mov di,offset strfind2   ; if not below -> di=strfind2
    mov al, [di]
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
    sub di,sfindL 
    mov cx,sreplL 
    mov si,offset strrepl2
    rep movsb
    pop si
    
	RET

END   start
        
        