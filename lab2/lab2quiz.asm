/* Lab 1 Part D
   Name: Pengzhao Zhu
   Section#: 112D
   TA Name: Chris Crary
   Description: This program is game that will turn on the green LED if user wins, or turn on the red LED if user loses.
				LEDs will move inward and outward before game the concludes (win or lose). There is also an option to reset 
				the game after the game concludes
*/

.include "ATxmega128A1Udef.inc"       ;include the file
.list                                 ;list it

.org 0x00                             ;start the program here
rjmp MAIN                             ;jump to MAIN

.equ stack_init=0x3FFF   ;initialize stack pointer

.org 0x200    ;put table here
Table: .db 0b10000000, 0b01000000, 0b00100000, 0b00010000,0b00001000, 0b00000100,0b00000010,0b00000001  ;load table to turn on LED  

.org 0x210
Table1: .db 0b00000010, 0b00000100, 0b00001000, 0b00010000, 0b00100000,0b01000000

.org 0x300    ;code start here

MAIN:
ldi YL, low(stack_init)    ;Load 0xFF to YL
out CPU_SPL, YL			   ;transfer to CPU_SPL
ldi YL, high(stack_init)   ;Load 0x3F to YH
out CPU_SPH, YL			   ;transfer to CPU_SPH

ldi r21, 5   ;initialize how many times i want to mulitply delay_10ms for

ldi r17, 0xFF   ;to turn off all active low LED later 

ldi r22, 0b00001100     ;set S1 and S2 as input
sts PORTF_DIRCLR, r22   ;transfer to PORTF_DIRCLR

ldi r16, 0xFF            ;load r26 with 0xFF
sts PORTC_DIRSET, r16    ;set Port C to be output

HI:
sts PORTC_OUTSET, r17        ;turn off all LED (active low LED)
lds r23, PORTF_IN                        ;if PORTF_IN is pressed
bst r23, 3                               ;if pressed. store bit 3 of r23 into T-flag
brtc LEDLOOP
rjmp  HI

LEDLOOP:

ldi ZL, low(Table << 1)        ;load low byte of table to ZL
ldi ZH, high(Table << 1)       ;load high byte of table to ZH
ldi r20, 8                     ;table counter=8

LEDSWITCH:
lpm r16, Z+                  ;load the first data at the table to r16. post increment
sts PORTC_OUTSET, r17        ;turn off all LED (active low LED)
sts PORTC_OUTCLR, r16        ;turn the LED I want on
rcall Delay_mult             ;call my delay
dec r20                                 ;decrement r20
cpi r20, 0                              ;if r20=0, start the table over
breq DEC1                           ;start table over
rjmp LEDSWITCH                          ;load the next value in table

CHECK:
lds r23, PORTF_IN                        ;if PORTF_IN is pressed
bst r23, 2                               ;if pressed. store bit 3 of r23 into T-flag
brtc PRESS                               ;if pressed. voltage is 0, so that is why it breaks if cleared
brts OVER

DEC1:
dec ZL
rjmp CHECK

PRESS:
ldi r20, 8
PRESS1:
lpm r16, Z
dec ZL                  ;load the first data at the table to r16. post increment
sts PORTC_OUTSET, r17        ;turn off all LED (active low LED)
sts PORTC_OUTCLR, r16        ;turn the LED I want on
rcall Delay_mult             ;call my delay

dec r20                                 ;decrement r20
cpi r20, 0                              ;if r20=0, start the table over
breq CHECK2                        ;start table over
rjmp PRESS1                        ;load the next value in table

CHECK2:
lds r23, PORTF_IN                        ;if PORTF_IN is pressed
bst r23, 3                              ;if pressed. store bit 3 of r23 into T-flag
brtc HI                              ;if pressed. voltage is 0, so that is why it breaks if cleared
rjmp OVER

OVER:
sts PORTC_OUTSET, r17  ;to turn off all active low LED
lds r23, PORTF_IN                        ;if PORTF_IN is pressed
bst r23, 3                               ;if pressed. store bit 3 of r23 into T-flag
brtc LEDLOOP                               ;if pressed. voltage is 0, so that is why it breaks if cleared
brts OVER



Delay_mult:
push r20        ;push r20
mov r20, r21      ;load 9 (r21) in r20. it runs it 10 times and the delay will be 10ms.

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

HII:
cpi r16,0        ;compare to 0
breq SECOND      ;go to second loop if loop one is done
dec r16          ;dec 16
rjmp HII         ;jump to HI if first loop is not done

SECOND:
cpi r17, 0       ;compare r17 too 0
breq rdone       ;if r17=0, we are finished with the subroutine and ready to return to main code
dec r17          ;dec r17
rjmp START       ;start loop one

rdone:            ;by the time the code gets back here.
pop r17           ;should be a 10ms delay
pop r16
ret               ; return to main routine