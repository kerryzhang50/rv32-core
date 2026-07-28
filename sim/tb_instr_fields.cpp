#include <cassert>
#include <iostream>

#include "Vinstr_fields.h"
#include "verilated.h"

uint32_t make_r_type(
    uint8_t funct7,
    uint8_t rs2,
    uint8_t rs1,
    uint8_t funct3,
    uint8_t rd,
    uint8_t opcode)
{
    // Shift each field to match the bit slices in your SystemVerilog file:
    // opcode: [6:0], rd: [11:7], funct3: [14:12], rs1: [19:15], rs2: [24:20], funct7: [31:25]
    return ((uint32_t)(funct7 & 0x7F) << 25) |
           ((uint32_t)(rs2    & 0x1F) << 20) |
           ((uint32_t)(rs1    & 0x1F) << 15) |
           ((uint32_t)(funct3 & 0x07) << 12) |
           ((uint32_t)(rd     & 0x1F) << 7)  |
           ((uint32_t)(opcode & 0x7F));
}

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vinstr_fields dut;

    dut.instruction = make_r_type(
    0,
    2,
    1,
    0,
    5,
    0b0110011);
    
    dut.eval();

    assert(dut.funct7 == 0);
    assert(dut.rs2 == 2);
    assert(dut.rs1 == 1);
    assert(dut.funct3 == 0);
    assert(dut.rd == 5);
    assert(dut.opcode == 0b0110011);

    std::cout << "Basic instruction field test passed!\n";

    return 0;
}