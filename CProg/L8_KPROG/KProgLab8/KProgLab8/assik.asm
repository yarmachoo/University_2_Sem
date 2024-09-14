.model small, C
.stack 100h
.code
option casemap:none
draw_pixel proc
    ; Сохраняем регистры
    pusha
    push ebp ; Store the current stack frame
     mov ebp, esp ; Preserve ESP into EBP for argument references
    ; Устанавливаем видеорежим 0x13 (320x200)
    mov ax, 0013h
    int 10h

    ; Рисуем пиксель
    mov ah, 0Ch
    mov al,byte ptr[ebp + 8] ; Цвет
    mov cx,word ptr[ebp + 12] ; X
    mov dx,word ptr[ebp + 16] ; Y
    int 10h

    ; Восстанавливаем регистры
    popa
    ret
draw_pixel endp
END
