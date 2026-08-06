#include <cassert>
#include <iostream>

#include "Vsimple_dmem.h"
#include "verilated.h"

vluint64_t sim_time = 0;

void tick(Vsimple_dmem& dut)
{
    dut.clk = 0;
    dut.eval();
    sim_time++;

    dut.clk = 1;
    dut.eval();
    sim_time++;
}

void write_word(Vsimple_dmem& dut, uint32_t addr, uint32_t data)
{
    dut.req_valid = 1;
    dut.req_write = 1;
    dut.req_addr  = addr;
    dut.req_wdata = data;
    dut.req_wstrb = 0b1111;

    tick(dut);

    dut.req_valid = 0;
}

uint32_t read_word(Vsimple_dmem& dut, uint32_t addr)
{
    dut.req_valid = 1;
    dut.req_write = 0;
    dut.req_addr  = addr;

    tick(dut);

    dut.req_valid = 0;

    tick(dut);

    assert(dut.resp_valid);

    return dut.resp_rdata;
}

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vsimple_dmem dut;

    dut.rst = 1;

    tick(dut);
    tick(dut);

    dut.rst = 0;

    write_word(dut, 0x20, 42);
    assert(read_word(dut, 0x20) == 42);

    write_word(dut, 0x24, 99);
    assert(read_word(dut, 0x24) == 99);

    write_word(dut, 0x20, 123);
    assert(read_word(dut, 0x20) == 123);

    assert(read_word(dut, 0x24) == 99);

    write_word(dut, 0x20, 55);

    // These all index the same word.
    assert(read_word(dut, 0x20) == 55);
    assert(read_word(dut, 0x21) == 55);
    assert(read_word(dut, 0x22) == 55);
    assert(read_word(dut, 0x23) == 55);
    std::cout << "All simple_dmem tests passed!\n";

    return 0;
    }