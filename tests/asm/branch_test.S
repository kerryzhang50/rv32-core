.section .text
.globl _start

_start:
addi x2, x0, 100
addi x1, x0, 42
sw   x1, 0(x2)
lw   x3, 0(x2)