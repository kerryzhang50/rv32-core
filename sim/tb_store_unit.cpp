#include <cassert>
#include <iostream>

#include "Vstore_unit.h"
#include "verilated.h"

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vstore_unit dut;

    dut.rs2_data = 0xAABBCCDD;

    // SW
    dut.funct3 = 0b010;
    dut.eval();

    assert(dut.wdata == 0xAABBCCDD);
    assert(dut.wstrb == 0b1111);

    // SB
    dut.funct3 = 0b000;

    dut.addr_offset = 0;
    dut.eval();
    assert(dut.wdata == 0xAABBCCDD);
    assert(dut.wstrb == 0b0001);

    dut.addr_offset = 1;
    dut.eval();
    assert(dut.wdata == 0xBBCCDD00);
    assert(dut.wstrb == 0b0010);

    dut.addr_offset = 2;
    dut.eval();
    assert(dut.wdata == 0xCCDD0000);
    assert(dut.wstrb == 0b0100);

    dut.addr_offset = 3;
    dut.eval();
    assert(dut.wdata == 0xDD000000);
    assert(dut.wstrb == 0b1000);

    // SH
    dut.funct3 = 0b001;

    dut.addr_offset = 0;
    dut.eval();
    assert(dut.wdata == 0xAABBCCDD);
    assert(dut.wstrb == 0b0011);

    dut.addr_offset = 2;
    dut.eval();
    assert(dut.wdata == 0xCCDD0000);
    assert(dut.wstrb == 0b1100);

    std::cout << "All basic store tests passed!\n";

    return 0;
}