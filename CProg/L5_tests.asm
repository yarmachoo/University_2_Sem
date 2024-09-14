.model tiny
.code 
EOT=13   
org 100h
mes1 db 'Input string: ',0Dh,0Ah,'$'
empty_line db 0Dh,0Ah,'$'  
mes2 db "you input string: ",0Dh,0Ah,'$'
buff1 db 200,?,200 dup(?)
buff2 db 512 dup (0) 
word1 db 200,?,200 dup(?) 
word2 db 100,?,200 dup(?)
sfindL dw 0
sreplL dw 0
jmp start

start:
    ;Iput data
    mov ah, 9
    mov dx, offset mes1
    int 21h

    mov ah, 0Ah
    mov dx, offset buff1
    int 21h
    
    mov ah, 9
    mov dx, offset empty_line
    int 21h  
    
    mov ah, 9
    mov dx, offset mes2
    int 21h
    
    mov bh, 0
    mov bl, buff1 + 1

    mov buff1[bx + 2], '$'

    mov ah, 9
    lea dx, [buff1 + 2]
    int 21h 
    
    mov ah, 9
    mov dx, offset empty_line
    int 21h
    ;/////////////////////////////////////////////
    mov ah, 9
    mov dx, offset mes1
    int 21h

    mov ah, 0Ah
    mov dx, offset word1
    int 21h
    
    mov ah, 9
    mov dx, offset empty_line
    int 21h  
    
    mov ah, 9
    mov dx, offset mes2
    int 21h
    
    mov bh, 0
    mov bl, word1 + 1

    mov word1[bx + 2], '$'

    mov ah, 9
    lea dx, [word1 + 2]
    int 21h 
    
    mov ah, 9
    mov dx, offset empty_line
    int 21h
    ;////////////////////////////////////////////////  
    mov ah, 9
    mov dx, offset mes1
    int 21h

    mov ah, 0Ah
    mov dx, offset word2
    int 21h
    
    mov ah, 9
    mov dx, offset empty_line
    int 21h  
    
    mov ah, 9
    mov dx, offset mes2
    int 21h
    
    mov bh, 0
    mov bl, word2 + 1

    mov word2[bx + 2], '$'

    mov ah, 9
    lea dx, [word2 + 2]
    int 21h
    ;//////////////////////////////////////////
    cld
    mov si,offset buff1 ; si=исходный текст
    mov di,offset buff2  ; di=текст результата
m0: lodsb
    stosb
    cmp al,EOT  ; это конец текста ?
    jz outprint ; да, переход к печати результата
    call find   ; найти слово 
    jnz m0      ; слово не найдено - конец цикла
    call replace ; слово найдено - сделать замену
    jmp m0      
outprint: 
    mov ah, 9
    mov dx, offset empty_line
    int 21h
    
    mov si,offset buff2   ; si=текст результата
m1: lodsb        ; считать символ
    cmp al,EOT   ; если конец текста, то выход
    jz exit
    mov dl,al    ; печатать символ
    mov ah,2
    int 21h
    jmp m1       ; конец цикла
exit:   mov ax,4C00h ; выход в Дос
    int 21h
 
find:   push si  ; поиск слова
    push di
    mov cx,sfindL ; сдвинуть указатель текста на длину искомого слова
    sub si,cx
    cmp si,offset word1 ; указатель меньше адреса начала текста ?
    jc  return_no ; да, возвратить "не найдено"
    mov di,offset word1 ; нет, сравнить со словом поиска
    repe cmpsb
    pop di
    pop si
    ret         ; возвращается флаг Z, если слово найдено
return_no:          ; возвращается флаг NZ - "слово не найдено"
    mov dl,1
    or dl,dl
    pop di
    pop si
    ret
 
replace:push si ; замена слова
    sub di,sfindL ; стираем исходное слово в выходном тексте
    mov cx,sreplL ; заменяем на новое слово (при этом DI продвигается по тексту)
    mov si,offset word2
    rep movsb
    pop si
    ret
end start