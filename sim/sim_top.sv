module sim_top
(
    input logic clk,
    input logic rst,

    output logic [31:0] dbg_pc,
    output logic [31:0] dbg_instr,
    output logic        dbg_reg_write,
    output logic [4:0]  dbg_rd,
    output logic [31:0] dbg_write_data
);

logic [31:0] imem_addr;
logic [31:0] imem_rdata;

logic [31:0] odbg_pc;
logic [31:0] odbg_instr;

logic        odbg_reg_write;
logic [4:0]  odbg_rd;
logic [31:0] odbg_write_data;

assign dbg_pc = odbg_pc;
assign dbg_instr = odbg_instr;
assign dbg_reg_write = odbg_reg_write;
assign dbg_rd = odbg_rd;
assign dbg_write_data = odbg_write_data;

rv32_core core(
    .clk(clk),
    .rst(rst),

    .imem_addr(imem_addr),
    .imem_rdata(imem_rdata),

    .dbg_pc(odbg_pc),
    .dbg_instr(odbg_instr),
    .dbg_reg_write(odbg_reg_write),
    .dbg_rd(odbg_rd),
    .dbg_write_data(odbg_write_data)
);

imem #(
    .INIT_FILE("../tests/hex/add_test.hex")
) imem0(
    .addr(imem_addr),
    .instruction(imem_rdata)
);

endmodule