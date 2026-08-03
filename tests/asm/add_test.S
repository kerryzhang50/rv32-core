.section .text
.globl _start

_start:
    addi x1, x0, 10
    addi x2, x0, 32
    add  x3, x1, x2
    sub  x4, x3, x1

loop:
    jal x0, loop