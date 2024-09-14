 ORG $8000
 
 LDAB $FF
 LDY #$0
 STY $2000
 LDAA #$55
 STAB $2000
 LDY $2000
 LDX #$7
 
LOOP:
	BRCLR 1,y,#$1,bit_set
	LDAB $FF
	STAB 0,x
	BRA next_bit

bit_set:
	LDAB #$00
	STAB 0,x
next_bit:
	DEX
	LSRA
	STAA $2000
	LDY $2000
	
	bne loop