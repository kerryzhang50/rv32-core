#include <cassert>
#include <iostream>

#include "Vload_unit.h"
#include "verilated.h"

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vload_unit dut;

    dut.mem_word = 0xAABBCCDD;

    // LW
    dut.funct3 = 0b010;
    dut.addr_offset = 0;
    dut.eval();

    assert(dut.load_data == 0xAABBCCDD);

    // LBU
    dut.funct3 = 0b100;

    dut.addr_offset = 0;
    dut.eval();
    assert(dut.load_data == 0xDD);

    dut.addr_offset = 1;
    dut.eval();
    assert(dut.load_data == 0xCC);

    dut.addr_offset = 2;
    dut.eval();
    assert(dut.load_data == 0xBB);

    dut.addr_offset = 3;
    dut.eval();
    assert(dut.load_data == 0xAA);

    // LB
    dut.mem_word = 0x00000080;

    dut.funct3 = 0b000;
    dut.addr_offset = 0;
    dut.eval();

    assert(dut.load_data == 0xFFFFFF80);

    dut.mem_word = 0x0000007F;
    dut.eval();

    assert(dut.load_data == 0x7F);

    // LH
    dut.mem_word = 0x80017FFF;

    dut.funct3 = 0b001;

    dut.addr_offset = 0;
    dut.eval();

    assert(dut.load_data == 0x00007FFF);

    dut.addr_offset = 2;
    dut.eval();

    assert(dut.load_data == 0xFFFF8001);

    // LHU
    dut.funct3 = 0b101;

    dut.addr_offset = 0;
    dut.eval();

    assert(dut.load_data == 0x00007FFF);

    dut.addr_offset = 2;
    dut.eval();

    assert(dut.load_data == 0x00008001);

    std::cout << "All basic load tests passed!\n";

    return 0;
}