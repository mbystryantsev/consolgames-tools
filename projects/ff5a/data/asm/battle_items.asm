.gba
.code 16
.thumb
org 080969BAh

	cmp		r4, 0h
	beq		@@left
@@right:
	mov		r3, 7Ch
	b 		080969C8h
@@left:
	mov		r3, 8h
	b 		080969C8h


;080969BA 0123     lsl     r3,r4,4h
;080969BC 1B1B     sub     r3,r3,r4
;080969BE 04DB     lsl     r3,r3,13h
;080969C0 2040     mov     r0,40h
;080969C2 0340     lsl     r0,r0,0Dh
;080969C4 181B     add     r3,r3,r0
;080969C6 0C1B     lsr     r3,r3,10h
end