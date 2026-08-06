.section .text
.globl _start

_start:
    addi x1,x0,5
    addi x2,x0,6
    beq x1,x2,equal

    addi x3,x0,111
    jal x0,done

equal:
    addi x3,x0,42

done:
    jal x0,done