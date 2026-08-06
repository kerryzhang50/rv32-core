.section .text
.globl _start

_start:

    # Base address
    addi x1, x0, 64

    # Store word
    li x2, 0x12345678
    sw x2, 0(x1)

    # Load word
    lw x3, 0(x1)

    # Store byte
    li x4, 0xAA
    sb x4, 1(x1)

    # Load byte
    lb  x5, 1(x1)

    # Load byte unsigned
    lbu x6, 1(x1)

    # Store half
    li x7, 0xBBBB
    sh x7, 2(x1)

    # Load half
    lh  x8, 2(x1)

    # Load half unsigned
    lhu x9, 2(x1)

loop:
    jal x0, loop