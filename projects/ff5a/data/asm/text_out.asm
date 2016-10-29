.gba
.code 16
.thumb
.align 4
org 083ED9B0h
; jump from 080D24D8
	add		r0, r0, r1
	ldrb	r1, [r2]
	cmp		r1, 84h
	ble		@@symbol
	ldrb	r0, [r0]
	b		@@exit
@@symbol:
	ldrb	r0, [r0,1]
@@exit:
	bx lr
	
end