#include <cassert>
#include <iostream>

#include "Vdecode_top.h"
#include "verilated.h"

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

enum IMM_TYPE
{
        IMM_NONE = 0,
        IMM_I,
        IMM_S,
        IMM_B,
        IMM_U,
        IMM_J
};

uint32_t make_r_type(
    uint8_t funct7,
    uint8_t rs2,
    uint8_t rs1,
    uint8_t funct3,
    uint8_t rd,
    uint8_t opcode)
{
    return
        ((uint32_t)funct7 << 25) |
        ((uint32_t)rs2    << 20) |
        ((uint32_t)rs1    << 15) |
        ((uint32_t)funct3 << 12) |
        ((uint32_t)rd     << 7 ) |
        opcode;
}

void check_r_type(
    Vdecode_top& dut,

    uint8_t funct7,
    uint8_t funct3,

    int expected_alu)
{
    dut.instruction = make_r_type(
        funct7,
        2,
        1,
        funct3,
        5,
        0b0110011);

    dut.eval();

    assert(dut.alu_op == expected_alu);

    assert(dut.reg_write);

    assert(!dut.mem_read);
    assert(!dut.mem_write);

    assert(!dut.branch);
    assert(!dut.jump);

    assert(!dut.alu_b_sel);
    assert(!dut.mem_to_reg);
}

uint32_t make_i_type(
    uint16_t imm,
    uint8_t rs1,
    uint8_t funct3,
    uint8_t rd,
    uint8_t opcode)
{
    return ((uint32_t)(imm & 0xFFF) << 20) |
           ((uint32_t)rs1 << 15) |
           ((uint32_t)funct3 << 12) |
           ((uint32_t)rd << 7) |
           opcode;
}

uint32_t make_shift_imm(
    uint8_t shamt,
    uint8_t rs1,
    uint8_t funct3,
    uint8_t rd,
    uint8_t opcode,
    uint8_t funct7)
{
    return
        ((uint32_t)funct7 << 25) |
        ((uint32_t)(shamt & 0x1F) << 20) |
        ((uint32_t)rs1 << 15) |
        ((uint32_t)funct3 << 12) |
        ((uint32_t)rd << 7) |
        opcode;
}

void check_i_type(
    Vdecode_top& dut,

    uint8_t funct3,

    int expected_alu)
{
    dut.instruction = make_i_type(
        42,
        1,
        funct3,
        5,
        0b0010011);

    dut.eval();
    
    if (dut.alu_op != expected_alu)
    {
        std::cerr << "Decode test failed\n"
                << "  expected = 0x" << expected_alu << "\n"
                << "  got      = 0x" << dut.alu_op << "\n";
        assert(false);
    }
    assert(dut.alu_op == expected_alu);

    assert(dut.reg_write);

    assert(dut.alu_b_sel);
    assert(dut.imm_type == IMM_I);

    assert(!dut.mem_read);
    assert(!dut.mem_write);

    assert(!dut.branch);
    assert(!dut.jump);
}

void check_shift_imm(
    Vdecode_top& dut,

    uint8_t funct7,

    int expected_alu)
{
    dut.instruction = make_shift_imm(
        5,
        1,
        0b101,
        5,
        0b0010011,
        funct7);

    dut.eval();
    
    if (dut.alu_op != expected_alu)
    {
        std::cerr << "Decode test failed\n"
                << "  expected = 0x" << expected_alu << "\n"
                << "  got      = 0x" << dut.alu_op << "\n";
        assert(false);
    }
    assert(dut.alu_op == expected_alu);

    assert(dut.reg_write);

    assert(dut.alu_b_sel);
    assert(dut.imm_type == IMM_I);

    assert(!dut.mem_read);
    assert(!dut.mem_write);

    assert(!dut.branch);
    assert(!dut.jump);
}

int main(int argc,char** argv)
{
    Verilated::commandArgs(argc, argv);

    Vdecode_top dut;
    /*
    check_r_type(
        dut,
        0b0000000,
        0b000,
        ALU_ADD);      // ADD

    check_r_type(
        dut,
        0b0100000,
        0b000,
        ALU_SUB);      // SUB

    check_r_type(
        dut,
        0b0000000,
        0b111,
        ALU_AND);      // AND

    check_r_type(
        dut,
        0b0000000,
        0b110,
        ALU_OR);      // OR

    check_r_type(
        dut,
        0b0000000,
        0b100,
        ALU_XOR);      // XOR

    check_r_type(
        dut,
        0b0000000,
        0b001,
        ALU_SLL);      // SLL

    check_r_type(
        dut,
        0b0000000,
        0b101,
        ALU_SRL);      // SRL

    check_r_type(
        dut,
        0b0100000,
        0b101,
        ALU_SRA);      // SRA

    check_r_type(
        dut,
        0b0000000,
        0b010,
        ALU_SLT);      // SLT

    check_r_type(
        dut,
        0b0000000,
        0b011,
        ALU_SLTU);      // SLTU

    dut.instruction = 0xFFFFFFFF;
    dut.eval();
    assert(!dut.reg_write);
    assert(!dut.mem_read);
    assert(!dut.mem_write);
    assert(!dut.branch);
    assert(!dut.jump);
    */

    check_i_type(
        dut,
        0b000,
        ALU_ADD);

    check_i_type(
        dut,
        0b010,
        ALU_SLT);

    check_i_type(
        dut,
        0b011,
        ALU_SLTU);

    check_i_type(
        dut,
        0b100,
        ALU_XOR);

    check_i_type(
        dut,
        0b110,
        ALU_OR);

    check_i_type(
        dut,
        0b111,
        ALU_AND);

    check_i_type(
        dut,
        0b001,
        ALU_SLL);

    check_shift_imm(
        dut,
        0b0000000,
        ALU_SRL);

    check_shift_imm(
        dut,
        0b0100000,
        ALU_SRA);

    std::cout << "Basic decoder test passed!\n";

    return 0;
}