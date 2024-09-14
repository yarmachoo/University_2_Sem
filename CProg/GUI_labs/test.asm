        .model tiny
        .code
        .186
        org 100h
start:
        mov sp,program_length + 100h + 200h
        mov ah,4Ah
stack_shift = program_length + 100h + 200h
        mov bx,stack_shift shr 4 + 1
        int 21h
        
        mov ax,cs
        mov word ptr EPB+4,ax
        mov word ptr EPB+8, ax
        mov word ptr EPB + 0Ch, ax
      
        mov ax, 4B00h
        mov dx, offset program_path
        mov bx, offset EPB
        int 21h
       
        int 20h
        
        program_path    db "D:\Uni\Cprog\GUI_labs\test.asm",0
EPB             dw 0000
                dw offset commandline, 0
                dw 005Ch,0,006Ch,0
commandline     db 125
                db "/?"
command_text    db 122 dup (?)
program_length  equ $-start
                end start