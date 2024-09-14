
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt
        .model tiny
        .code 
        org 100h             
start:  mov ah,9
        mov dx,offset message
        int 21h
        ret
message db "Hello World", 0Dh, 0Ah, "Be healthy!", '$'
        end start




