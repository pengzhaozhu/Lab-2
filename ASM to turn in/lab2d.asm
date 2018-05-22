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
Table: .db 0b10000001, 0b01000010, 0b00100100, 0b00011000,0b00100100, 0b01000010,0b10000001,0b00000000  ;load table to turn on LED  

.org 0x300    ;code start here

MAIN:
ldi YL, low(stack_init)    ;Load 0xFF to YL
out CPU_SPL, YL			   ;transfer to CPU_SPL
ldi YL, high(stack_init)   ;Load 0x3F to YH
out CPU_SPH, YL			   ;transfer to CPU_SPH

ldi r21, 10   ;initialize how many times i want to mulitply delay_10ms for

ldi r17, 0xFF   ;to turn off all active low LED later
ldi r18, 0b00110000 ;to turn off the red and green   

ldi r22, 0b00001100     ;set S1 and S2 as input
sts PORTF_DIRCLR, r22   ;transfer to PORTF_DIRCLR
ldi r22, 0b00110000      ;bit 5 is red, bit 6 is green
sts PORTD_DIRSET, r22    ;set as input
sts PORTD_OUTSET, r18  ;to turn off the LED for now. set them as HIGH so they will be off

ldi r16, 0xFF            ;load r26 with 0xFF
sts PORTC_DIRSET, r16    ;set Port C to be output

LEDLOOP:

ldi ZL, low(Table << 1)        ;load low byte of table to ZL
ldi ZH, high(Table << 1)       ;load high byte of table to ZH
ldi r20, 8                     ;table counter=8

LEDSWITCH:
lpm r16, Z+                  ;load the first data at the table to r16. post increment
sts PORTC_OUTSET, r17        ;turn off all LED (active low LED)
sts PORTC_OUTCLR, r16        ;turn the LED I want on
rcall Delay_mult             ;call my delay

lds r23, PORTF_IN                        ;if PORTF_IN is pressed
bst r23, 3                               ;if pressed. store bit 3 of r23 into T-flag
brtc PRESS                               ;if pressed. voltage is 0, so that is why it breaks if cleared


dec r20                                 ;decrement r20
cpi r20, 0                              ;if r20=0, start the table over
breq LEDLOOP                            ;start table over
rjmp LEDSWITCH                          ;load the next value in table


PRESS:

bst r16, 4    ;store bit 4 of r16 into T-flag
brts GREEN    ;if bit 4 is set, then I win the game
brtc RED      ;if bit 4 is not set, then I lose the game


GREEN:             
ldi r23, 0b00100000    ;low true. load onto r23
sts PORTD_OUTCLR, r23  ;turn on GREEN
rjmp RESET             ;jump to where I will reset the game


RED:
ldi r23, 0b00010000       ;low true. load onto r23
sts PORTD_OUTCLR, r23     ;turn on RED
rjmp RESET              ;jump to where I will reset the game

RESET:
lds r23, PORTF_IN            ;check if user have pressed S1 to reset
bst r23, 2                   ;read where S1 switch is at. i.e. bit 2 
brtc OFF                     ;if pressed. reset game
brts RESET                   ;if not pressed. infinite loop

OFF:
sts PORTD_OUTSET, r18  ;to turn off all active low LED
rjmp LEDLOOP           ;jump to LEDLOOP and start everything over

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