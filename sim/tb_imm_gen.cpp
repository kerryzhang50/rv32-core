#include <cassert>
#include <iostream>

#include "Vimm_gen.h"
#include "verilated.h"

enum IMM_TYPE
{
    IMM_NONE = 0,
    IMM_I,
    IMM_S,
    IMM_B,
    IMM_U,
    IMM_J
};

// Helper to construct the immediate field
uint32_t make_i_type_imm(uint16_t imm12)
{
    return ((uint32_t)(imm12 & 0xFFF)) << 20;
}

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vimm_gen dut;

    // Test 1: Positive Number
    dut.instruction = make_i_type_imm(42);
    dut.imm_type = IMM_I;

    dut.eval();

    assert(dut.immediate == 42);

    // Test 2: Zero
    dut.instruction = make_i_type_imm(0);

    dut.eval();

    assert(dut.immediate == 0);

    // Test 3: -1
    dut.instruction = make_i_type_imm(0xFFF);

    dut.eval();

    assert((int32_t)dut.immediate == -1);

    // Test 4: -8
    dut.instruction = make_i_type_imm(0xFF8);

    dut.eval();

    assert((int32_t)dut.immediate == -8);

    // Test 5: Largest Positive
    dut.instruction = make_i_type_imm(0x7FF);

    dut.eval();

    assert((int32_t)dut.immediate == 2047);

    // Test 6: Smallest Negative
    dut.instruction = make_i_type_imm(0x800);

    dut.eval();

    assert((int32_t)dut.immediate == -2048);

    std::cout << "Basic immediate generator test passed!\n";
}