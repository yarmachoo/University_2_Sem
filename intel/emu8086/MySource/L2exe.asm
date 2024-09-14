    .model small
    .code
    .stack 100h
start: 
    mov ax, @data
    mov ds, ax
    mov dx, offset message
    mov ah,9
    int 21h      
    ret
    mov ax,4c00h
    int 21h    
    message db "Hello World!", 0Dh, 0Ah, '$'
end start  
    