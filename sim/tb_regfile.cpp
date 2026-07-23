#include <cassert>
#include <iostream>

#include "Vregfile.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

vluint64_t sim_time = 0;

void tick(Vregfile& dut, VerilatedVcdC* trace)
{
    dut.clk = 0;
    dut.eval();
    trace->dump(sim_time++);

    dut.clk = 1;
    dut.eval();
    trace->dump(sim_time++);
}

void write_register(
    Vregfile& dut,
    VerilatedVcdC* trace,
    uint8_t reg,
    uint32_t value)
{
    dut.rd = reg;
    dut.write_data = value;
    dut.we = 1;

    tick(dut, trace);

    dut.we = 0;
    dut.rd = 0;
    dut.write_data = 0;

    dut.eval();
}

uint32_t read_register(Vregfile& dut, uint8_t reg)
{
    dut.rs1 = reg;
    dut.eval();

    return dut.read_data1;
}

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vregfile dut;

    Verilated::traceEverOn(true);

    VerilatedVcdC* trace = new VerilatedVcdC;

    dut.trace(trace, 5);

    trace->open("regfile.vcd");

    dut.clk = 0;
    dut.we = 0;

    dut.rs1 = 0;
    dut.rs2 = 0;
    dut.rd = 0;

    dut.write_data = 0;

    dut.eval();

    assert(dut.read_data1 == 0);
    assert(dut.read_data2 == 0);

    write_register(dut, trace, 5, 123);

    dut.rs1 = 5;
    dut.eval();

    write_register(dut, trace, 0, 999);

    dut.rs1 = 0;
    dut.eval();

    assert(dut.read_data1 == 0);

    for (int i = 1; i < 32; i++)
    {
        write_register(dut, trace, i, i * 100);
    }

    for (int i = 1; i < 32; i++)
    {
        assert(read_register(dut, i) == static_cast<uint32_t>(i * 100));
    }

    trace->close();

    delete trace;

    std::cout << "Basic register file test passed!\n";

    return 0;
    }