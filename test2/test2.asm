.include "ATxmega128A1Udef.inc"
.list 

.org 0x0000
rjmp MAIN

.dseg

.equ outputall=0xFF  ;set all for output
.equ switch=0xFF     ;set all for input

.cseg
 
.org 0x200           ;where we will start the program

MAIN:

ldi r17, 0b00011000       ;load outputs (0xFF) to r17
sts PORTC_DIRSET, r17    ;set Port C to be output

rjmp MAIN

