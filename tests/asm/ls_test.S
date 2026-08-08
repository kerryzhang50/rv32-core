.section .text
.globl _start

_start:
    addi x0,x0,0
    auipc x5,0

loop:
    jal x0,loop