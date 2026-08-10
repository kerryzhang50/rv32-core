module sim_top
(
    input logic clk,
    input logic rst,

    output logic [31:0] dbg_pc,
    output logic [31:0] dbg_instr,
    output logic        dbg_reg_write,
    output logic [4:0]  dbg_rd,
    output logic [31:0] dbg_write_data,

    output  logic        req_valid,
    output  logic        req_write,
    output  logic [31:0] req_addr,
    output  logic [31:0] req_wdata,
    output  logic [3:0]  req_wstrb,

    output logic        resp_valid,
    output logic [31:0] resp_rdata,

    output logic        dbg_stall
);

logic [31:0] imem_addr;
logic [31:0] imem_rdata;

rv32_core core(
    .clk(clk),
    .rst(rst),

    .imem_addr(imem_addr),
    .imem_rdata(imem_rdata),

    .dbg_pc(dbg_pc),
    .dbg_instr(dbg_instr),
    .dbg_reg_write(dbg_reg_write),
    .dbg_rd(dbg_rd),
    .dbg_write_data(dbg_write_data),

    .req_valid(req_valid),
    .req_write(req_write),
    .req_addr(req_addr),
    .req_wdata(req_wdata),
    .req_wstrb(req_wstrb),

    .resp_valid(resp_valid),
    .resp_rdata(resp_rdata),

    .dbg_stall(dbg_stall)

);

imem #(
    .INIT_FILE("../tests/hex/pipeline_test.hex")
) imem0(
    .addr(imem_addr),
    .instruction(imem_rdata)
);

endmodule