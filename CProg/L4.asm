    ; add your data here!
    .model small
    .stack 100h

start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov dx, offset message 
    mov ah, 9

    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ax, 4C00h
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
    .data 
message db "Hello World", 0Dh, 0Ah, '$'

end start
