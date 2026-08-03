#include <cassert>
#include <iostream>

#include "Vimm_gen.h"
#include "verilated.h"

enum imm_type_t {
        IMM_NONE = 0,
        IMM_I,
        IMM_S,
        IMM_B,
        IMM_U,
        IMM_J
};

void check(
    Vimm_gen& dut,
    uint32_t instruction,
    imm_type_t type,
    int32_t expected,
    const char* test_name)
{
    dut.instruction = instruction;
    dut.imm_type = type;
    dut.eval();

    if ((int32_t)dut.immediate != expected)
    {
        std::cerr
            << test_name
            << " failed!\n"
            << "Expected: " << expected
            << "\nGot:      " << (int32_t)dut.immediate
            << std::endl;

        std::abort();
    }
}

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vimm_gen dut;

    // Tests go here...
    // Test 1 — I-Type (Positive)
    check(
        dut,
        0x00A00093,
        IMM_I,
        10,
        "I-type positive");

    // Test 2 — I-Type (Negative)
    check(
        dut,
        0xFFF00093,
        IMM_I,
        -1,
        "I-type negative");

    // Test 3 — S-Type
    check(
        dut,
        0x0053A023,
        IMM_S,
        0,
        "S-type");

    // Test 4 — B-Type
    check(
        dut,
        0x00628463,
        IMM_B,
        8,
        "B-type");

    // Test 5 — U-Type
    check(
        dut,
        0x123452B7,
        IMM_U,
        0x12345000,
        "U-type");

    // Test 6 — J-Type
    check(
        dut,
        0x00C000EF,
        IMM_J,
        12,
        "J-type");

    std::cout << "All imm_gen tests passed!\n";
    return 0;
}