#include <iostream>

#include "Vsim_top.h"
#include "verilated.h"

vluint64_t sim_time = 0;

void tick(Vsim_top* dut)
{
    dut->clk = 0;
    dut->eval();
    sim_time++;

    dut->clk = 1;
    dut->eval();
    sim_time++;
}

int main(int argc,char** argv)
{
    Verilated::commandArgs(argc, argv);

    auto* dut = new Vsim_top;

    dut->rst = 1;

    tick(dut);
    tick(dut);

    dut->rst = 0;

    for (int cycle = 0; cycle < 10; cycle++)
    {
        std::cout
            << "Cycle " << cycle
            << "  PC = 0x"
            << std::hex << dut->dbg_pc
            << "  Instr = 0x"
            << dut->dbg_instr;

        if (dut->dbg_reg_write)
        {
            std::cout
                << "  Write x"
                << std::dec
                << (int)dut->dbg_rd
                << " = "
                << dut->dbg_write_data;
        }

        std::cout << std::endl;

        tick(dut);
    }

    delete dut;

    return 0;
}