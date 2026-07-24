#include <cassert>
#include <iostream>

#include "Valu.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

vluint64_t sim_time = 0;

enum ALU_OP
{
    ALU_ADD = 0,
    ALU_SUB,
    ALU_AND,
    ALU_OR,
    ALU_XOR,
    ALU_SLL,
    ALU_SRL,
    ALU_SRA,
    ALU_SLT,
    ALU_SLTU
};

void evaluate(Valu& dut, VerilatedVcdC* trace)
{
    dut.eval();
    trace->dump(sim_time++);
}

void check_operation(
    Valu& dut,
    VerilatedVcdC* trace,
    uint32_t a,
    uint32_t b,
    ALU_OP op,
    uint32_t expected)
{
    dut.a = a;
    dut.b = b;
    dut.op = op;

    evaluate(dut, trace);

    if (dut.result != expected)
    {
        std::cerr << "ALU test failed\n"
                << "  op       = " << static_cast<int>(op) << "\n"
                << "  a        = 0x" << std::hex << a << "\n"
                << "  b        = 0x" << b << "\n"
                << "  expected = 0x" << expected << "\n"
                << "  got      = 0x" << dut.result << std::dec << "\n";
        assert(false);

        assert(dut.result == expected);
    }
}

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Valu dut;

    Verilated::traceEverOn(true);

    VerilatedVcdC* trace = new VerilatedVcdC;

    dut.trace(trace, 5);

    trace->open("alu.vcd");

    check_operation(dut, trace, 10, 20, ALU_ADD, 30);
    check_operation(dut, trace, 0, 0, ALU_ADD, 0);
    check_operation(dut, trace, 100, 50, ALU_ADD, 150);

    check_operation(dut, trace, 20, 5, ALU_SUB, 15);
    check_operation(dut, trace, 100, 100, ALU_SUB, 0);

    check_operation(
        dut,
        trace,
        0b1100,
        0b1010,
        ALU_AND,
        0b1000);

    check_operation(
        dut,
        trace,
        0b1100,
        0b1010,
        ALU_OR,
        0b1110);

    check_operation(
        dut,
        trace,
        0b1100,
        0b1010,
        ALU_XOR,
        0b0110);

    check_operation(
        dut,
        trace,
        1,
        4,
        ALU_SLL,
        16);

    check_operation(
        dut,
        trace,
        16,
        2,
        ALU_SRL,
        4);

    check_operation(
        dut,
        trace,
        0xFFFFFFF0,
        2,
        ALU_SRA,
        0xFFFFFFFC);

    check_operation(
        dut,
        trace,
        static_cast<uint32_t>(-5),
        3,
        ALU_SLT,
        1);

    check_operation(
        dut,
        trace,
        0xFFFFFFFF,
        0,
        ALU_SLTU,
        0);

    check_operation(
        dut,
        trace,
        0xFFFFFFFF,
        1,
        ALU_ADD,
        0);

    check_operation(
        dut,
        trace,
        1,
        36,
        ALU_SLL,
        16);

    trace->close();

    delete trace;

    std::cout << "All ALU tests passed!" << std::endl;

    return 0;
}