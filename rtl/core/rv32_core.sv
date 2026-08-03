import rv32_pkg::*;

module rv32_core
(
    input logic clk,
    input logic rst,

    output logic [31:0] imem_addr,
    input  logic [31:0] imem_rdata,

    output logic [31:0] dbg_pc,
    output logic [31:0] dbg_instr,
    output logic        dbg_reg_write,
    output logic [4:0]  dbg_rd,
    output logic [31:0] dbg_write_data
);

    // From instruction memory
    logic [31:0] instruction;

    // Register addresses
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    // Register values
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    // Immediate
    logic [31:0] immediate;

    // ALU
    logic [31:0] alu_result;

    // Control
    alu_op_t alu_op;

    imm_type_t imm_type;

    logic reg_write;

    logic alu_src;

    // Program counter
    logic [31:0] pc;
    logic [31:0] next_pc;

    // Writeback data
    logic [31:0] writeback_data;

    // Instruction fields result
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    // Control decoder result
    logic mem_read;
    logic mem_write;
    logic branch;
    logic jump;
    logic mem_to_reg;

    assign next_pc = pc + 32'd4;

    assign writeback_data = alu_result;

    logic [31:0] alu_operand_b;

    assign alu_operand_b = alu_src ? immediate : rs2_data;

    assign imem_addr = pc;
    assign instruction = imem_rdata;

    assign dbg_pc = pc;
    assign dbg_instr = instruction;

    assign dbg_reg_write = reg_write;
    assign dbg_rd        = rd;
    assign dbg_write_data = writeback_data;

    always_ff @(posedge clk) begin
        if (rst)
            pc <= 32'd0;
        else
            pc <= next_pc;
    end

    instr_fields fields(
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7)
    );

    control_decoder decoder(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),

        .alu_op(alu_op),
        .imm_type(imm_type),

        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg)
    );

    imm_gen imm(
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );

    regfile rf(
        .clk(clk),

        .we(reg_write),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .write_data(writeback_data),

        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    alu alu0(
        .a(rs1_data),
        .b(alu_operand_b),

        .alu_op(alu_op),

        .result(alu_result)
    );

endmodule