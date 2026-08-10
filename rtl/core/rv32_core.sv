import rv32_pkg::*;
import mem_if::*;

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
    output logic [31:0] dbg_write_data,

    output  logic        req_valid,
    output  logic        req_write,
    output  logic [31:0] req_addr,
    output  logic [31:0] req_wdata,
    output  logic [3:0]  req_wstrb,

    output logic        resp_valid,
    output logic [31:0] resp_rdata,

    output logic dbg_stall
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

    // Exposed regfile write enable
    logic rf_we;

    // ALU
    logic [31:0] alu_result;

    // ALU Operand MUX
    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;

    // Control
    alu_op_t alu_op;

    imm_type_t imm_type;

    logic reg_write;

    alu_a_sel_t alu_a_sel;

    logic alu_b_sel;

    pc_sel_t pc_sel;

    wb_sel_t wb_sel;

    // Program counter
    logic [31:0] pc;
    logic [31:0] pc_next;

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
    logic [1:0] mem_size;
    logic mem_unsigned;

    // Branch variable
    logic take_branch;

    // Memory request
    dmem_req_t  dmem_req;
    dmem_resp_t dmem_resp;

    // Address offset for store/load
    logic [1:0] addr_offset;

    // Load/store variables
    logic [31:0] load_data;
    logic [31:0] store_wdata;
    logic [3:0]  store_wstrb;

    // Stall
    logic stall;
    logic start_load;
    logic finish_load;

    // ID/EX input signals
    id_ex_t id_ex_in;
    id_ex_t id_ex_out;
    control_t control;

    // IF/ID input signals
    if_id_t if_id_in;
    if_id_t if_id_out;

    assign start_load = mem_read && !stall;
    assign finish_load = stall && dmem_resp.valid;    

    //assign alu_operand_a = (alu_a_sel == ALU_A_PC) ? pc : rs1_data;
    //assign alu_operand_b = alu_b_sel ? immediate : rs2_data;

    assign alu_operand_a =
    (id_ex_out.control.alu_a_sel == ALU_A_PC)
        ? id_ex_out.pc
        : id_ex_out.rs1_data;

    assign alu_operand_b =
    id_ex_out.control.alu_b_sel
        ? id_ex_out.immediate
        : id_ex_out.rs2_data;

    // Simple Memory
    assign imem_addr = pc;
    //assign instruction = imem_rdata;

    //assign rf_we = (!stall && reg_write && !mem_read && rd != 0) || finish_load;

    // Debug variables
    assign dbg_pc = pc;
    assign dbg_instr = instruction;

    assign dbg_reg_write = rf_we;
    assign dbg_rd        = id_ex_out.rd;
    assign dbg_write_data = writeback_data;    

    assign dbg_stall = stall;

    assign addr_offset = alu_result[1:0];

    assign if_id_in.pc    = pc;
    assign if_id_in.instr = imem_rdata;

    assign instruction = if_id_out.instr;

    assign id_ex_in.pc          = if_id_out.pc;

    assign id_ex_in.rs1_data    = rs1_data;
    assign id_ex_in.rs2_data    = rs2_data;

    assign id_ex_in.immediate   = immediate;

    assign id_ex_in.rs1         = rs1;
    assign id_ex_in.rs2         = rs2;
    assign id_ex_in.rd          = rd;

    assign id_ex_in.funct3      = funct3;

    always_comb begin
        control.reg_write = reg_write;
        control.mem_read  = mem_read;
        control.mem_write = mem_write;
        control.mem_to_reg = mem_to_reg;
        control.alu_a_sel  = alu_a_sel;
        control.alu_b_sel  = alu_b_sel;
        control.branch     = branch;
        control.jump       = jump;
        control.alu_op     = alu_op;
        control.wb_sel = wb_sel;
    end

    assign id_ex_in.control     = control;

    always_ff @(posedge clk) begin
        if (rst)
            pc <= 32'h0;
        else
            pc <= pc_next;
    end

    assign pc_next = pc + 32'd4;

    assign rf_we = id_ex_out.control.reg_write;
/*
    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 0;
            stall <= 0;
        end
        else begin
            if (finish_load) begin
                stall <= 0;
                pc <= pc_next;
            end
            else if (start_load)
                stall <= 1;
            else if (!stall)
                pc <= pc_next;
        end
    end

    // PC_next MUX
    always_comb begin
        unique case (pc_sel)
            PC_PLUS_4:
                pc_next = pc + 32'd4;

            PC_JAL:
                pc_next = pc + immediate;

            PC_JALR:
                pc_next = (rs1_data + immediate) & 32'hFFFF_FFFE;

            PC_BRANCH:
                if (take_branch)
                    pc_next = pc + immediate;
                else
                    pc_next = pc + 4;

            default:
                pc_next = pc + 32'd4;
        endcase
    end
*/
    // Writeback MUX
    always_comb begin
        unique case (id_ex_out.control.wb_sel)

            WB_ALU:
                writeback_data = alu_result;

            WB_PC4:
                writeback_data = id_ex_out.pc + 32'd4;

            WB_MEM:
                writeback_data = load_data;

            default:
                writeback_data = 32'd0;

        endcase
    end

    // Drive deme_req
    assign dmem_req.valid = (mem_read || mem_write) && !stall;
    assign dmem_req.write = mem_write;
    assign dmem_req.addr = alu_result;
    assign dmem_req.wdata = store_wdata;
    assign dmem_req.wstrb = store_wstrb;

    assign req_valid = dmem_req.valid;
    assign req_write = dmem_req.write;
    assign req_addr = dmem_req.addr;
    assign req_wdata = dmem_req.wdata;
    assign req_wstrb = dmem_req.wstrb;

    assign resp_valid = dmem_resp.valid;

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
        .pc_sel(pc_sel),
        .wb_sel(wb_sel),
        .alu_a_sel(alu_a_sel),

        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .alu_b_sel(alu_b_sel),
        .mem_to_reg(mem_to_reg),
        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned)
    );

    imm_gen imm(
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );

    regfile rf(
        .clk(clk),

        .we(rf_we),

        .rs1(rs1),
        .rs2(rs2),
        .rd(id_ex_out.rd),

        .write_data(writeback_data),

        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    /*
    alu alu0(
        .a(alu_operand_a),
        .b(alu_operand_b),

        .alu_op(alu_op),

        .result(alu_result)
    );
    */

    alu alu0(
        .a(alu_operand_a),
        .b(alu_operand_b),
        .alu_op(id_ex_out.control.alu_op),
        .result(alu_result)
    );

    branch_unit bu(
        .rs1(rs1_data),
        .rs2(rs2_data),

        .funct3(funct3),

        .take_branch(take_branch)
    );

    simple_dmem #(
        .DEPTH(256)
    ) dmem (
        .clk(clk),
        .rst(rst),
        .req_valid(dmem_req.valid),
        .req_write(dmem_req.write),
        .req_addr(dmem_req.addr),
        .req_wdata(dmem_req.wdata),
        .req_wstrb(dmem_req.wstrb),
        .resp_valid(dmem_resp.valid),
        .resp_rdata(dmem_resp.rdata)
    );

    load_unit lu(
        .mem_word(dmem_resp.rdata),
        .addr_offset(addr_offset),
        .funct3(funct3),
        .load_data(load_data)
    );

    store_unit su(
        .addr_offset(addr_offset),
        .funct3(funct3),
        .rs2_data(rs2_data),
        .wdata(store_wdata),
        .wstrb(store_wstrb)
    );

    if_id_reg if_id_reg0 (
        .clk(clk),
        .rst(rst),

        .d(if_id_in),
        .q(if_id_out)
    );

    id_ex_reg id_ex_reg0 (
        .clk(clk),
        .rst(rst),

        .d(id_ex_in),
        .q(id_ex_out)
    );

endmodule