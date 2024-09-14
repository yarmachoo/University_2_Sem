.model tiny   ; Memory model for COM
.code          ; Code segment   
org 100h
start:
    mov ax, @data    ; Load the data segment address
    mov ds, ax       ; Set DS to the data segment

    mov dx, offset message  ; Load offset of message into DX
    mov ah, 09h             ; Print function is 9
    int 21h                 ; DOS function for printing a string

    mov ax, 0   ; DOS function to terminate the program
    int 16h 
.data              ; Data segment
message db "Hello World!", 0Dh, 0Ah, '$'

end start