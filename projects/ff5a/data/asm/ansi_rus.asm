.gba
.code 16
.thumb
.align 4
org 083EDAB0h
; jump from 0801CF70
	cmp		r2, 0C0h
	bge     @@found
	cmp		r2, '¨'
	bne     @@char_e
	mov		r0, 0D0h
	b		@@exit
@@char_e:
	cmp		r2, '¸'
	bne		@@standard
	mov		r0, 0D1h
	b		@@exit
@@found:
	cmp		r2, 'ç'
	beq		@@char_z
	mov     r0, r2
	sub		r0, 30h
	b		@@exit
@@char_z:
	mov		r0, 0D2h	
@@exit:
	pop		r1
	bx		r1
@@standard:
	ldr		r0, [r0]
	lsl		r1, r2, 1h
	bx		lr
end