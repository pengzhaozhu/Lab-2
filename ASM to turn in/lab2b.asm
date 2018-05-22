/* Lab 1 Part B
   Name: Pengzhao Zhu
   Section#: 112D
   TA Name: Chris Crary
   Description: This Program turns the 8 LED on/off by reading the data at the switch
*/

.include "ATxmega128A1Udef.inc"        ;include the file
.list                                  ;list it 

.org 0x0000                            ;start our program here
rjmp MAIN                              ;jump to main

.dseg                                   ;data segment. not really needed

.equ set1=0xFF                  ;set all for output.used later

.cseg                           ;code segment
 
.org 0x200           ;where we will start the program

MAIN:
ldi r16, set1        ;load inputs(0xFF) to r16
sts PORTA_DIRCLR, r16    ;set Port A to be input

ldi r17, set1       ;load outputs (0xFF) to r17
sts PORTC_DIRSET, r17    ;set Port C to be output

sts PORTC_OUTSET, r16       ;turn off all LED (active low LED)

LOOP:
lds r16, PORTA_IN        ;load value at input to r16. switch=0n, closed circuit. Port A grounded.
sts PORTC_OUT, r16        ;input to output.  0 to output. active low output. LED on
rjmp LOOP                 ;infinite loop

 


 
