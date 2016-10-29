.gba	
.code 16
.thumb
org 083EDA00h
;  b 083EA700h
;SetMode
push r3-r4
mov r3,04h
lsl r3,r3,18h
mov r4,04h
lsl r4,r4,08h
add r4,r4,04h
strh r4,[r3]
pop r3-r4
bx lr

end