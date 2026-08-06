#include <cassert>
#include <iostream>

#include "Vbranch_unit.h"
#include "verilated.h"

int main(int argc,char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vbranch_unit dut;

    dut.rs1 = 5;
    dut.rs2 = 5;

    dut.funct3 = 0b000;

    dut.eval();
    assert(dut.take_branch);

    dut.rs1 = 5;
    dut.rs2 = 6;

    dut.funct3 = 0b000;
    
    dut.eval();
    assert(!dut.take_branch);

    return 0;
}