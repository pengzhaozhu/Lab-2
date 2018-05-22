/* Lab 1 Part C
   Name: Pengzhao Zhu
   Section#: 112D
   TA Name: Chris Crary
   Description: This program toggles a LED with a 100ms delay between toggles.
*/

.include "ATxmega128A1Udef.inc"     ;include the file
.list                               ;list it 

.org 0x00                           ;start the program here
rjmp MAIN                           ;jump to MAIN

.equ stack_init=0x3FFF   ;initialize stack pointer

MAIN:
ldi YL, low(stack_init)    ;Load 0xFF to YL
out CPU_SPL, YL			   ;transfer to CPU_SPL
ldi YL, high(stack_init)   ;Load 0x3F to YH
out CPU_SPH, YL			   ;transfer to CPU_SPH

ldi r16, 0x80  ;set last LED as output
sts PORTC_DIRSET, r16    ;set last LED as output using DIRSET

ldi r21, 10   ;initialize how many times i want to mulitply delay_10ms for

LOOP:
ldi r17, 0x80            ;load r17 with 0x80
sts PORTC_OUTTGL, r17    ;toggle last LED of PORTC

rcall Delay_mult        ;call delay 100ms subroutine
rjmp LOOP                ;infinite loop



Delay_mult:
push r20        ;push r20
mov r20, r21      ;load 9 in r20. it runs it 10 times and the delay will be 10ms.

REPEAT:
rcall Delay_10ms    ;call delay_10ms
dec r20             ;decrement r20. keep the code running
cpi r20, 0          ;load 0 to r20
breq DONE           ;when it is done, prepare to get back into main routine
rjmp REPEAT         ;going back to the place to call delay_10ms again

DONE:
pop r20             ;pop r20
ret                 ;return to main routine

Delay_10ms:      ;delay 10ms subroutine
push r16         ;push r16
push r17         ;push r17
ldi r17, 15      ;do this loop 15 times. Just need a large number to make sure the delay is long enough

START:
ldi r16, 0xFF    ;some value to take up running time

HI:
cpi r16,0        ;compare to 0
breq SECOND      ;go to second loop if loop one is done
dec r16          ;dec 16
rjmp HI          ;jump to HI if first loop is not done

SECOND:
cpi r17, 0       ;compare r17 too 0
breq rdone       ;if r17=0, we are finished with the subroutine and ready to return to main code
dec r17          ;dec r17
rjmp START       ;start loop one

rdone:            ;by the time the code gets back here.
pop r17           ;should be a 10ms delay
pop r16
ret               ; return to main routine