.model small

.stack 100h

.data    
readedTotal           dw  0
writedTotal           dw  0

maxCMDSize equ 127
cmd_size              db  ?
cmd_text              db  maxCMDSize + 2 dup(0)
sourcePath            db  maxCMDSize + 2 dup(0) 
;sourcePath            db  "text.txt", 0
       
                      
sourceID              dw  0
                      
maxWordSize           equ 50
buffer                db  maxWordSize + 2 dup(0)
                            
spaceSym              db  " ","$"                            
                            
spaceSymbol           equ ' '
newLineSymbol         equ 0Dh
returnSymbol          equ 0Ah
tabulation            equ 9
endl                  equ 0
                      
startText             db  "Program is started",                                               '$'
badCMDArgsMessage     db  "Bad command-line arguments. Only 1 argument required: source path",'$'
badSourceText         db  "Cannot open source file",                                          '$'
fileNotFoundText      db  "File not found",                                                   '$'
errorClosingSource    db  "Cannot close source file",                                         '$' 
errorWritingText      db  "Error writing to file",                                            '$'
endText               db  "Program is ended",                                                 '$'
errorReadSourceText   db  "Error reading from source file",                                   '$'
EOF                   db  0

period                equ 2
currWordStartingValue equ 0
currWordIndex         db  currWordStartingValue	;

.code  

println MACRO info          ;
	push ax                 ;
	push dx                 ;
                            ;
	mov ah, 09h             ; ������� ������ 
	lea dx, info            ; �������� � dx �������� ���������� ���������
	int 21h                 ; ����� ����������� ��� ���������� ������
                            ;
	mov dl, 0Ah             ; ������ �������� �� ����� ������
	mov ah, 02h             ; ������� ������ �������
	int 21h                 ; ����� ����������
                            ;
	mov dl, 0Dh             ; ������ �������� � ������ ������   
	mov ah, 02h             ;
	int 21h                 ;            ==//==
                            ;
	pop dx                  ;
	pop ax                  ;
ENDM

main:
	mov ax, @data           ; ��������� ������
	mov es, ax              ;
                            ;
	xor ch, ch              ; �������� ch
	mov cl, ds:[80h]		; ������� ��� ���������� ������ � �������� �������
	mov cmd_size, cl 		; � cmd_size ��������� ����� ��������� ������
	mov si, 81h             ;
	lea di, cmd_text        ; ��������� � di �������� ������ ����������� ����� ��������� ������
	rep movsb               ; �������� � ������ ������� ES:DI ���� �� ������ DS:SI
                            ;
	mov ds, ax              ; ��������� � ds ������
                            ;
	println startText       ; ����� ������ � ������ ������ ���������
                            ;
	call parseCMD           ; ����� ��������� �������� ��������� ������
	cmp ax, 0               ;
	jne endMain				; ���� ax != 0, �.�. ��� ��������� ��������� ��������� ������ - ��������� � ����� ���������, �.�. ������� � endMain
                            ;
	call openFiles          ; �������� ���������, ������� ��������� ��� ����� ��� ������/������
	cmp ax, 0               ;
	jne endMain				;  ==//==
                            ;
	call processingFile     ; ������� ���������, � ������� ���������� ���� �������� ��������� �����
	cmp ax, 0               ; 
	jne endMain				;  ==//==
                            ;
	call closeFiles         ; �������� ��������� ����������, �������� ��������� �������� ������
	cmp ax, 0               ;
	jne endMain				;  ==//==
                            ;
endMain:                    ;
	println endText         ; ������� ��������� � ���������� ������ ���������
                            ;
	mov ah, 4Ch             ; ��������� � ah ��� ������� ���������� ������
	int 21h                 ; ����� ���������� DOS ��� �� ����������


cmpWordLenWith0 MACRO textline, is0Marker       ; ��������� ������ � �����, 1 �������� - ������, 2 ������� �������� ��� 0
	push si                                     ; ���������� �������� �������� si
	                                            ;
	lea si, textline                            ; ��������� � si �������� ������, � ������� �������� ������
	call    strlen                              ; �������� �-��� ���������� ����� ������ textline, ��������� -> ax
	                                            ;
	pop si                                      ; ��������������� �������� si
	cmp ax, 0                                   ; ���������� ��������� ������ � �����
	je is0Marker                                ; ���� ����� ����� ���� -> ��������� �� ���������� ����� is0Marker
ENDM                                            ;                               ;
                                                ; 
                                                                                        ;                               ;
                                                        
                                                ;
;**************************************************************************************************************************
parseCMD PROC                                   ;
	push bx                                     ;
	push cx                                     ;
	push dx                                     ; ���������
                                                ;
	mov cl, cmd_size                            ; ��������� � cl ������ �������� ������
	xor ch, ch                                  ; �������� ch
                                                ;
	lea si, cmd_text                            ; � si ��������� �������� ������ �� �������� ������
	                                            ;                                                          
	lea di, buffer                              ; � di ��������� �������� ������� ��� ��������� ������      
	call rewriteAsWord                          ;                                                           
                                                ;                                                           
	lea di, sourcePath                          ; ��������� � di �������� sourcePath �.�. ��������� ������ ��� ���������
	call rewriteAsWord                          ;
                                                ;
	cmpWordLenWith0 sourcePath, badCMDArgs      ; ���� ������, ���������� �������� �������� ����� �����, ������� � badCMDArgs  
	;checkTxt        sourcePath, badCMDArgs
                                                ; 
	lea di, buffer                              ; 
	call rewriteAsWord                          ;
                                                ;
	cmpWordLenWith0 buffer, argsIsGood          ; ���� ������ ������ ���, �.�. ����� �������� ��������� � ��������� ������ ��������� ������ ������ �� ��������
                                                ; �� ����� ��������� ���������� - ������� � argsIsGood
badCMDArgs:                                     ;
	println badCMDArgsMessage                   ; ������� ��������� � �������� ���������� ��������� ������
	mov ax, 1                                   ; ���������� � ax ��� ������
                                                ;
	jmp endproc                                 ; ������� � endproc � ��������� ���������
                                                ;
argsIsGood:                                     ;
	mov ax, 0                                   ; ���������� � ax ��� ��������� ���������� ���������
endproc:                                        ;
	pop dx                                      ;
	pop cx                                      ;
	pop bx                                      ; ��������������� �������� ��������� � ������� �� ���������
	ret	                                        ;
ENDP
;*************************************************************************************************************************  
  
;*************************************************************************************************************************
;cx - ����� ��������� ������
;��������� - ������������ �������� �� ���������� ������ 
rewriteAsWord PROC              ;
	push ax                     ;
	push cx                     ;
	push di                     ; ��������� ��������
	                            ;
loopParseWord:                  ;
	mov al, ds:[si]             ; ��������� � al ������� ������
	
	cmp al, spaceSymbol         ; -------------------
    je isStoppedSymbol          ;                                 ;
	cmp al, newLineSymbol       ;
	je isStoppedSymbol          ;         ���� ���� ������ �����            ;
	cmp al, tabulation          ;   �������, ���������, 0Ah, 0Dh ��� \0
	je isStoppedSymbol          ;     ������ �� ����� ��  ����� �����
	cmp al, returnSymbol        ;
	je isStoppedSymbol          ;                                        ;
	cmp al, endl                ;
	je isStoppedSymbol          ;
                                ;
	mov es:[di], al             ; ���� ������ ������ ������ � �����, ��������� ��� � �������������� ������
                                ;
	inc di                      ; ����������� di,si �.�. ��������� �� ��������� ������
	inc si                      ;
                                ;
	loop loopParseWord          ; ���� �� ��������� ������������ ����� �����, ������
isStoppedSymbol:                ;
	mov al, endl          ;
	mov es:[di], al             ; ��������� ������ ����� ������ � �������������� ������
	inc si                      ; ����������� si ��� �������� �� ��������� ������ ��������� ������
                                ;
	pop di                      ; ��������������� ��������
	pop cx                      ;
	pop ax                      ;
	ret                         ;
ENDP   
;**************************************************************************************************************************  
  
;*************************************************************************************************************************
;ds:si - ��������, � ������� ��������� ������ ������
;��������� - � ax ���������� ����� ������ 
strlen PROC                     ;
	push bx                     ;
	push si                     ;  ��������� ������������ ����� ��������
	                            ;
	xor ax, ax                  ;  �������� ax
                                ;
    startCalc:                  ;
	    mov bl, ds:[si]         ;  ��������� ��������� ������ ������ �� ds �� ��������� si
	    cmp bl, endl            ;  ���������� ���� ������ � �������� ����� ������
	    je endCalc              ;  ���� ��� ������ ����� ������ - ������� � endCalc � ����������� ����������
                                ;
	    inc si                  ;  ����������� si, �.�. ��������� � ���������� �������
	    inc ax                  ;  ����������� ax, �.�. ����� ������                                                     
	    jmp startCalc           ;  ����������
	                            ;
    endCalc:                    ;
	pop si                      ;
	pop bx                      ;  ��������������� ��������
	ret                         ;
ENDP                            ;
;*************************************************************************************************************************

;**************************************************************************************************************************
;��������� � ax - 0 ���� ��� ������
openFiles PROC                  ;
	push bx                     ;
	push dx                     ; ��������� �������� ���������          
	
	
	;;;;;;;;;
	push si                                     
	                                            
	lea si, sourcePath                          
	call    strlen                              
	    
	xor si, si         
	mov si, ax 
	sub si, 1                   
	        
	cmp sourcePath[si], 't' 
	jne checkTxt_Error     
	
	sub si, 1
	
	cmp sourcePath[si], 'x' 
	jne checkTxt_Error    
	
	sub si, 1
	
	cmp sourcePath[si], 't' 
	jne checkTxt_Error   
	
	sub si, 1
	
	cmp sourcePath[si], '.' 
	jne checkTxt_Error
	                    
	jmp checkTxt_OK                    
	checkTxt_Error: 
	pop si
	jmp badOpenSource       
	       
	checkTxt_OK:                                            ;
	pop si  
	
	;;;;;;;
                                ;
	mov ah, 3Dh			        ; ������� 3Dh - ������� ������������ ����
	mov al, 02h			        ; ����� �������� �����
	lea dx, sourcePath          ; ��������� � dx �������� ��������� �����
	mov cx, 00h			        ; 
	int 21h                     ;
                                ;
	jb badOpenSource	        ; ���� ���� �� ��������, �� ������� � badOpenSource
                                ;
	mov sourceID, ax	        ; ��������� � sourceId �������� �� ax, ���������� ��� �������� �����
                                ;
	mov ax, 0			        ; ��������� � ax 0, �.�. ������ �� ����� ���������� ��������� �� �������� 
	jmp endOpenProc		        ; ������� � endOpenProc � ��������� ������� �� ���������
                                ;
badOpenSource:                  ;
	println badSourceText       ; ������� �������������� ���������
	cmp ax, 02h                 ; ���������� ax � 02h
	jne errorFound              ; ���� ax != 02h - ���� ������, ������� � errorFound
                                ;
	println fileNotFoundText    ; ������� ��������� � ���, ��� ���� �� ������ 
                                ;
	jmp errorFound              ; ������� � errorFound
                                ;       ;       ==//==                               ;
errorFound:                     ;
	mov ax, 1                   ; ��������� � ax 1, �.�. ��������� ������
endOpenProc:                    ;
	pop dx                      ;
	pop bx                      ; ��������������� �������� ��������� � ������� �� ���������
	ret                         ;
ENDP                            ;
;******************************************************************************************************************************        
 
;**************************************************************************************************************************
closeFiles PROC                 ;
	push bx                     ;
	push cx                     ; ��������� �������� ��������� 
                                ;
	xor cx, cx                  ; �������� cx
                                ;
	mov ah, 3Eh                 ; ��������� � ah ��� 3Eh - ��� �������� �����
	mov bx, sourceID            ; � bx ��������� ID �����, ����������� ��������
	int 21h                     ; �������� ���������� ��� ���������� 
                                ;
	jnb goodCloseOfSource		; ���� ������ ��� �������� �� ���������, ������� � goodCloseOfSource
                                ;
	println errorClosingSource  ; ����� ������� �������������� ��������� �� ������       
	                            ;
	inc cx 			            ; now it is a counter of errors
                                ;
goodCloseOfSource:              ;               ;
	mov ax, cx 		            ; ���������� � ax �������� �� cx, ���� ������ �� ���������, �� ��� ����� 0, ����� 1 ��� 2, � ����������� ��
                                ; ���������� ������������� ������
	pop cx                      ;
	pop bx                      ; ��������������� �������� ��������� � ������� �� ���������
	ret                         ;
ENDP                            ;
;******************************************************************************************************************************
         
;******************************************************************************************************************************       
setPosInFileTo MACRO symbolsInt, symbols;
	push ax                     ;
	push bx                     ;
	push cx                     ;
	push dx                     ; ��������� �������� ���������
                                ;
	mov ah, 42h                 ; ���������� � ah ��� 42h - �-��� DOS ��������� ��������� �����
	xor al ,al 			        ; �������� al, �.�. al=0 - ��� ����������� ��������� � ������ �����
	mov cx, symbolsInt          ; �������� cx, 
	mov dx, symbols			    ; �������� dx, �.� ��������� ��������� �� 0 �������� �� ������ ����� (cx*2^16)+dx 
	int 21h                     ; �������� ���������� DOS ��� ���������� ��������   
                                ;
	pop dx                      ; ��������������� �������� ��������� � ������� �� ���������
	pop cx                      ;
	pop bx                      ;
	pop ax                      ;
ENDM 
;******************************************************************************************************************************

;******************************************************************************************************************************                                ;
divCurrWordIndex MACRO          ;
	mov al, currWordIndex       ; ��������� � al ������ �������� �����
	xor ah, ah                  ;
                                ;
	push bx                     ; ��������� bx
	mov bl, period              ; � bl ���������� ������, � ������� �� ������� �����, �.� 2
	div bl                      ; ���������� ������� �������� al �� bl
	pop bx                      ; ��������������� �������� bx; ������� �� ������� -> ah, ����� ����� -> al
	mov currWordIndex, ah       ; ����������� currWordIndex �������� ������� �� �������, �.�. ������ ����� ��� ��� 
                                ;
	cmp ah, 0                   ; ���������� ah � �����
	je movToSkip                ; ���� ah, �.� ������� �� ������� �� ������ ����� ����, �� ����������, �.�. ����� ������
	jmp movToWrite              ; ����� ������� � movToWrite, ��� ���������� ��� ����� � ����
                                ;
ENDM                            ;
;******************************************************************************************************************************
      
;******************************************************************************************************************************    
processingFile PROC                     ;
	push ax                             ;
	push bx                             ;
	push cx                             ;
	push dx                             ;
	push si                             ;
	push di                             ; ��������� �������� ���������
                                        ;
	mov bx, sourceID                    ; ��������� � bx ID �����-���������
	setPosInFileTo 0,0                  ; �������� �������� �������� ������� � ������ �����
                                        ;
    call readFromFile                   ; ����� ��������� ������ �� �����
	                                    ;
	cmp ax, 0                           ; ����������� ah � 0 ��� �������� �� ����� �����
	je finishProcessing                 ; ���� ah == 0, �� ������ ���� � �� ����� �� ����� �����
                                        ;
	lea si, buffer                      ; ����� ��������� � si � di �������� �������
	lea di, buffer                      ;
	mov cx, ax					        ; � cx ��������� ax, �.� ���-�� ��������� � ������� (���-�� ��������� ��������� � �����)
	xor dx, dx                          ; �������� dx
                                        ; � dx ����� ��������� ���-�� ��������� �������, ���������� ������
loopProcessing:                         ;
	                                    ;  
                   ;                    ;
writeDelimsAgain:                       ;
	call writeDelims                    ; ����� ������ ���� �-��� � bx - ���-�� ���������� ��������, ax - ���-�� �����  
	add dx, bx                          ; ��������� bx � dx, �.�. ������� �������� �� ��������
	cmp ax, 0                           ; ���������� ax � 0, � ax ������ ��������� ���-�� ����� ������� �� ��������
	je notNewLine                       ; ���� ax == 0 ������� � notNewLine
                                        ; 
                                        ; ���� ��������� �� ����� ������, �� ���������� �������� ������ �������� �����                   
	mov bl,currWordStartingValue        ; ��������� � bl ������ �����, � �������� �������� ��������
	mov currWordIndex, bl               ; ��������� � currWordIndex bl
                                        ;
notNewLine:                             ;
	call checkEndBuff                   ; �������� ��������� �������� ����� �������, ���� ������ ���� - ���������� ������ �� �����
	cmp ax, 2                           ; ���� ����� ������ ��������� checkEndBuff � ax ����� 2, �� ����������� ��������� - ������� � ax
	je finishProcessing                 ; ������� � finishProcessing
	cmp ax, 1                           ; ==//== � ax ����� 1, �� ������ ��� ���� � ���� ���������� ����� ������ �� �����
	je writeDelimsAgain                 ; ������� � writeDelimsAgain, �.�. 
                                        ;
	divCurrWordIndex                    ; ��������� ������, ������� ���������� ������ �� ����� ������ ��� ���
                                        ; � ������������ �� ����� ������ �������� ����� ������ � moToWrite, ��� ���������� ����� ������ � movToSkip
movToWrite:                             ;
	call writeWord                      ; ����� ��������� ������ �����
	add dx, bx                          ; ��������� � dx bx
	call checkEndBuff                   ; �������� ��������� �������� �������
	cmp ax, 2                           ; ���� 2, �� ����������� ���������, �.� ������� � finishProcessing
	je finishProcessing                 ;
	cmp ax, 1                           ; ���� 1, �� ������ ��� ������ � ���� ����� ���������� ������
	je movToWrite                       ; ������� ������� � moToWrite. �� ����� ����� ������ ����� ax = 0, �.� ����� � ������� ���-�� ����
                                        ;
	jmp endWriteSkip                    ; ������� � endWriteSkip
                                        ;
movToSkip:                              ;
	call skipWord                       ; bx � dx �� ���������, �.�. ��� ������ �� ����������
	call checkEndBuff                   ;
	cmp ax, 2                           ; ��� �� ��������, ������ � ��������� ����� ������ ������
	je finishProcessing                 ;
	cmp ax, 1                           ;
	je movToSkip                        ;
                                        ;
	jmp endWriteSkip                    ; 
                                        ;
endWriteSkip:                           ;
	push dx                             ; ��������� dx
	mov dl, currWordIndex               ; ��������� � dl ����� �������� �����
	inc dl                              ; ����������� dl, �.� ����� �����
	mov currWordIndex, dl 	            ; ������������ currWordIndex
	pop dx                              ;
                                        ;
	jmp loopProcessing                  ;
                                        ;
finishProcessing:                       ;
    mov bx, sourceID                    ;                     ;
                                        ;
    setPosInFileTo 0,writedTotal        ; �������� ���������� DOS ��� ���������� ��������    
                                        ;
    xor ax,ax                           ;
    mov ah, 40h                         ;
    mov bx, sourceID                    ;
    mov cx, 0h                          ;
    int 21h                             ;
                                        ;
	pop di                              ; ��������������� �������� 
	pop si                              ;
	pop dx                              ;
	pop cx                              ;
	pop bx                              ;
	pop ax                              ;
	ret                                 ;
ENDP                                    ;
;************************************************************************************************************************** 
  
;**************************************************************************************************************************                
ParseWordAndJumpIfDelimTo MACRO marker  ;  
    cmp al, spaceSymbol                 ;           --------------------
    je marker                           ;                                 
	cmp al, newLineSymbol               ;
	je marker                           ;         ���� ���� ������ �����            
	cmp al, tabulation                  ;    �������, ���������, 0Ah, 0Dh ��� \0
	je marker                           ;     ������ �� ����� ��  ����� �����
	cmp al, returnSymbol                ;
	je marker                           ;                                        
	cmp al, endl                        ;
	je marker                           ;           ---------------------
                                        ;
ENDM                                    ;
;**************************************************************************************************************************
                    
;**************************************************************************************************************************       
;ds:si - offset to byte source (will change)
;es:di - offset to byte destination (will change)
;cx - max length (will change)
;RES
;	bx - ���-�� ������������ ��������, �.�. ������������
;	ax - ���-�� ��������� �� ����� ������
writeDelims PROC                        ;
	push dx                             ; ��������� �������� �������� dx
	xor bx, bx                          ; �������� dx � bx
	xor dx, dx                          ; bx - ���������� ���������� ��������, dx- ���������� �������� �� ����� ������
                                        ;
startWriteDelimsLoop:                   ;
	mov al, ds:[si]                     ; ���������� � al ������, ���������� ������
	                                    ;
	cmp al, spaceSymbol                 ;            -------------------
    je isDelim                          ;
                                        ;
	cmp al, newLineSymbol               ;
	je isNewLineSymbol                  ;         ���� ���� ������ �����
                                        ;
	cmp al, tabulation                  ;   �������, ���������, 0Ah, 0Dh ��� \0
	je isDelim                          ;
                                        ;     ������ �� ����� ��  ����� �����
	cmp al, returnSymbol                ;
	je isNewLineSymbol                  ;
                                        ;
	cmp al, endl                        ;
	je isDelim                          ;           ---------------------
                                        ;                                       ;
	jmp isNotDelim                      ; ����� ������� � isNotDelim
                                        ;
isNewLineSymbol:                        ;
	inc dx                              ; ����������� dx, �.�. � dx ��������� ���-�� ��������� �� ����� ������
isDelim:                                ;
	movsb                               ; ���������� � ������ ES:DI ���� �� ������ DS:SI
	inc bx                              ; ����������� bx, �.�. ���-�� ���������� ��������
	loop startWriteDelimsLoop           ;
                                        ;
isNotDelim:                             ;
	mov ax, dx                          ; ��������� dx � ax
                                        ;
	pop dx                              ; ��������������� �������� �������� dx � ������� �� ���������
	ret                                 ;
ENDP                                    ;
;****************************************************************************************************************************
                
;****************************************************************************************************************************
;ds:si - offset, where we will find (will change)
;es:di - offset, where word will be (will change)
;cx - ���-�� �������������� �������� �������
;bx - ���-�� ������������ ��������
writeWord PROC                      ;
	push ax                         ; ��������� 
	xor bx, bx                      ; �������� bx
                                    ;
loopParseWordWW:                    ;
	mov al, ds:[si]                 ; ��������� � al ������� ������
	
	ParseWordAndJumpIfDelimTo isStoppedSymbolWW
                                    ;
	movsb                           ;
	inc bx                          ;
	loop loopParseWordWW            ;
                                    ;
isStoppedSymbolWW:                  ;
	pop ax                          ;
	ret                             ;
ENDP
;*****************************************************************************************************************************          
    
;*****************************************************************************************************************************          
;ds:si - offset, where we will find (will change)
;�� �� �����, ��� � � writeWord
skipWord PROC
	push ax
	xor bx, bx
	
loopParseWordSW:
	mov al, ds:[si]
	
	ParseWordAndJumpIfDelimTo isStoppedSymbolSW

	inc si
	inc bx
	loop loopParseWordSW

isStoppedSymbolSW:
	pop ax
	ret
ENDP  
;*****************************************************************************************************************************
   
;*****************************************************************************************************************************   
;reads to buffer maxWordSize symbols
;���������: � ax ���������� ����-�� ��������� �� ����� ��������
readFromFile PROC                   ;
	push bx                         ;
	push cx                         ;
	push dx                         ; ��������� �������� ���������
                                    ;
	mov ah, 3Fh                     ; ��������� � ah ��� 3Fh - ��� �-��� ������ �� �����
	mov bx, sourceID                ; � bx ��������� ID �����, �� �������� ���������� ���������
	mov cx, maxWordSize             ; � cx ��������� ������������ ������ �����, �.�. ��������� ������������ ���-�� �������� (maxWordSize ��������)
	lea dx, buffer                  ; � dx ��������� �������� �������, � ������� ����� ��������� ������ �� �����
	int 21h                         ; �������� ���������� ��� ���������� �-���
                                    ;
	jnb goodRead					; ���� ������ �� ����� ������� �� ��������� - ������� � goodRead
                                    ;
	println errorReadSourceText     ; ����� ������� ��������� �� ������ ������ �� �����
	mov ax, 0                       ; ���������� � ax 0
                                    ;
goodRead:                           ;   
    add readedTotal, ax                                ;
	pop dx                          ; ��������������� �������� ���������
	pop cx                          ;
	pop bx                          ;
	ret                             ;
ENDP                                ;
;*****************************************************************************************************************************
             
;*****************************************************************************************************************************             
;cx - ���-�� ������������ �������� �� ������ �������
;RES: ax - number of writed bytes
writeToFile PROC                      ;
	push bx                           ;
	push cx                           ;
	push dx                           ; ��������� �������� ���������  
	                                  ;
	mov bx, sourceID                  ;
	setPosInFileTo 0, writedTotal     ;
	                                  ;
	add writedTotal, cx               ;                        
	                ;                 ;
	mov ah, 40h                       ; ��������� � ah ��� 40h - ��� �-��� ������ � ����
	mov bx, sourceID                  ; � bx ��������� ID �����, � ������� ����� ���������� ������
	lea dx, buffer                    ; � dx ��������� ������, ������� ����� ����������
	int 21h                           ; �������� ���������� ��� ��������� �������
                                      ;
	jnb goodWrite					  ; ���� �� ����� ������ ������ �� ���������, ������� � goodWrite
                                      ;
	println errorWritingText          ; ����� ������� ��������� � ������������� ������ ��� ������
	mov ax, 0                         ; �������� ax
                                      ;
goodWrite:                            ;
    mov bx, sourceID                  ;                 
    setPosInFileTo 0, readedTotal     ;
                                      ;
	pop dx                            ; ��������������� �������� � ������� �� ���������
	pop cx                            ;
	pop bx                            ;
	ret                               ;
ENDP                                  ;
;******************************************************************************************************************************
               
;******************************************************************************************************************************               
;���������: �������� � ax -
;	ax = 0 - ������ ��� �� ����, �.�. ��� ���� ������ ��� ���������
;	ax = 1 - ������ ��� ���������, ������ ��������, � ����� "�����" ����� ��� ��������� � ������ 
;	ax = 2 - ������ ��� ���������, ������ ��������, ���� ��������� ������� �������� ������, �� ��������� ��� ����� �� ����� �����
checkEndBuff PROC               ;
	cmp cx, 0                   ; ���������� cx � �����
	jne notEndOfBuffer          ; ���� cx != 0, �� ������ ��� �� ��������� �������, ������� � notEndOfBuffer
                                ;
	cmp dx, 0                   ; ���������� dx � 0
	je skipWrite                ; ���� dx == 0, �� ��� ������ ����������, ������� ������� � skipWrite
	                            ; ���� ������ �� ������ � ���� ��� ����������
	mov cx, dx                  ; ���������� � cx dx, �.�. ���-�� ��������, ������� ���� ��������, ������� ��������� � dx � ���������� ������� writeWord
	call writeToFile            ; �������� �-��� ������ � ����
                                ;
skipWrite:                      ;
	call readFromFile           ; ��������� ����� �����
	cmp ax, 0                   ; ���������� ax � �����, ���� ax == 0, �� ��������� ������, ������������� ��������� � endOfProcessing
	je endOfProcessing          ;
                                ;
	lea si, buffer              ; ��������� � si � di �������� �������, � ������� ��������� ������ �� �����
	lea di, buffer              ;
	mov cx, ax					; ���������� � cx ���-�� �������� � ������� �� ax
	xor dx, dx                  ; �������� dx
                                ;
	mov ax, 1                   ; ���������� � ax - ����� �������
	ret                         ;
                                ;
endOfProcessing:                ;
	mov ax, 2                   ; ����� ��������� - �������� � ax �������� ��� 2
	ret                         ;
                                ;
notEndOfBuffer:                 ;
	mov ax, 0                   ; ���� ������ ��� �� �������� - ���������� �������� ��� 0
	ret                         ;
ENDP                            ;
;*******************************************************************************************************************************

end main