.gba	
.code 16
.thumb
org 083EDB00h
;  b 083EA700h
;SetMode
@@Logo:			dd 083EB000h 
@@Palette:		dd 083EAC00h
@@Entry:		dd 08001024h
@@ToThumbAdr:	dd @@ToThumb+1
.arm

ldr r3,[@@Entry]
ldr r4,[@@ToThumbAdr]
ldr r0,[@@Logo]
ldr r1,[@@Palette]
bx r4

@@ToThumb:
.thumb
push r3
push r2-r7
;mov r3,r8
mov r3,04h
lsl r3,r3,18h
mov r4,04h
lsl r4,r4,08h
add r4,r4,04h
strh r4,[r3]
mov r7,r0
mov r8,r1

;HuffUnComp
mov r4,02h
lsl r4,r4,18h
mov r1,r4
swi 13h

;LZ77UnCompVram
mov r0,r4
mov r1,06h
lsl r1,r1,18h
swi 12h

;LoadPalette
mov r0,r4
mov r3,r8
mov r1,00h
@@LoadPalLoop:
ldrh r5,[r3]
add r3,r3,02h
;SetRed
mov r4,1Fh
mov r6,r5
and r6,r4
lsl r6,r6,03h
strb r6,[r0]
add r0,r0,01h
;SetGreen
mov r4,0FFh
mov r6,03h
lsl r6,r6,08h
orr r4,r6
mov r6,r5
and r6,r4
lsr r6,r6,05h
lsl r6,r6,03h
strb r6,[r0]
add r0,r0,01h
;SetBlue
mov r4,0FFh
mov r6,07Fh
lsl r6,r6,08h
orr r4,r6
mov r6,r5
and r6,r4
lsr r6,r6,0Ah
lsl r6,r6,03h
strb r6,[r0]
add r0,r0,01h
mov r6,00h
strb r6,[r0]
add r0,r0,01h
add r1,r1,01h
cmp r1,0FFh
ble @@LoadPalLoop

;SetTimer
mov r0,04h
lsl r0,r0,18h
mov r1,0FFh
add r1,r1,07h
add r0,r0,r1
mov r1,83h
strh r1,[r0]

;FadeIn
mov r2,0h
@@LoopR2:
mov r0,02h
lsl r0,r0,18h
mov r1,05h
lsl r1,r1,18h
mov r3,0h
@@LoopR3:
ldrb r4,[r0]
ldrb r5,[r0,01h]
ldrb r6,[r0,02h]
add r0,r0,04h
mul r4,r2
mul r5,r2
mul r6,r2
lsr r4,r4,08h
lsr r5,r5,08h
lsr r6,r6,08h
lsr r4,r4,03h
lsr r5,r5,03h
lsr r6,r6,03h
lsl r5,r5,05h
lsl r6,r6,0Ah
orr r4,r5
orr r4,r6
strh r4,[r1]
add r1,r1,02h
add r3,r3,01h
cmp r3,0FFh
ble @@LoopR3
mov r3,04h
lsl r3,r3,18h
mov r4,0FFh
add r4,r4,05h
orr r3,r4
ldrh r4,[r3]
lsr r4,r4,6h
@@TimerLoop:
ldrh r5,[r3]
lsr r5,r5,6h
cmp r5,r4
ble @@TimerLoop
add r2,r2,01h
cmp r2,0FFh
ble @@LoopR2
mov r0,r8
mov r1,5h
lsl r1,r1,18h
mov r2,080h
swi 0Ch

;Delay
mov r3,04h
lsl r3,r3,18h
mov r0,0h
@@TimerLoop2:
mov r4,0FFh
add r4,r4,05h
orr r3,r4
ldrh r4,[r3]
lsr r4,r4,7h
@@TimerLoop1:

; Check for pressed A/B/Select/Start
ldr r1, [@@KeyData]
ldr r2, [@@InputAddr]
ldr r2, [r2]
bic r1, r2
cmp r1, 0h
bne @@FadeOut

ldrh r5,[r3]
lsr r5,r5,7h
cmp r5,r4
ble @@TimerLoop1
add r0,r0,1h
;ldr r1, [@@Time]
;cmp r0, r1
cmp r0,0F0h
blt @@TimerLoop2

;FadeOut
@@FadeOut:
mov r2,0FFh
@@LoopR2_1:
mov r0,02h
lsl r0,r0,18h
mov r1,05h
lsl r1,r1,18h
mov r3,0h
@@LoopR3_1:
ldrb r4,[r0]
ldrb r5,[r0,01h]
ldrb r6,[r0,02h]
add r0,r0,04h
mul r4,r2
mul r5,r2
mul r6,r2
lsr r4,r4,08h
lsr r5,r5,08h
lsr r6,r6,08h
lsr r4,r4,03h
lsr r5,r5,03h
lsr r6,r6,03h
lsl r5,r5,05h
lsl r6,r6,0Ah
orr r4,r5
orr r4,r6
strh r4,[r1]
add r1,r1,02h
add r3,r3,01h
cmp r3,0FFh
ble @@LoopR3_1
mov r3,04h
lsl r3,r3,18h
mov r4,0FFh
add r4,r4,05h
orr r3,r4
ldrh r4,[r3]
lsr r4,r4,6h
@@TimerLoop3:
ldrh r5,[r3]
lsr r5,r5,6h
cmp r5,r4
ble @@TimerLoop3
sub r2,r2,01h
cmp r2,0h
bge @@LoopR2_1

pop r2-r7
pop r0
bx r0

.align 4
@@InputAddr: dd 4000130h
@@KeyData:   dd 0Fh
;@@Time:		 dd 1F0h
end