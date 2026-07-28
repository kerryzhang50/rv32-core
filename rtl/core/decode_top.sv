import rv32_pkg::*;

module decode_top
(
    input logic [31:0] instruction,

    output alu_op_t alu_op,

    output logic reg_write,
    output logic mem_read,
    output logic mem_write,
    output logic branch,
    output logic jump,
    output logic alu_src,
    output logic mem_to_reg
);

logic [6:0] opcode;
logic [4:0] rd;
logic [2:0] funct3;
logic [4:0] rs1;
logic [4:0] rs2;
logic [6:0] funct7;

instr_fields fields (
    .instruction(instruction),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7)
);

control_decoder decoder (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),

    .alu_op(alu_op),

    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .branch(branch),
    .jump(jump),
    .alu_src(alu_src),
    .mem_to_reg(mem_to_reg)
);

endmodule