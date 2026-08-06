.section .text
.globl _start

_start:
    addi x1, x0, 42

    sw x1, 32(x0)

    lw x2, 32(x0)

loop:
    jal x0, loop