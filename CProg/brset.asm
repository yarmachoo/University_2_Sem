	org $8000
	ldaa #$55
	staa $00ff
	ldx #$00ff
	ldy #$7
	
loop:
	staa $00ff
	BRCLR 0,x,%10000000,bit_set
	ldab #$FF
	stab 0,y
	dey
	lsla
	bne loop

bit_set:
	
	ldab #0
	stab 0,y
	dey
	lsla 
	
	bne loop