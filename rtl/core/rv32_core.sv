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

    output logic dbg_stall,

    output logic dbg_branch,
    output logic dbg_take_branch,
    output logic [31:0] dbg_branch_rs1,
    output logic [31:0] dbg_branch_rs2,
    output logic dbg_redirect,
    output logic [31:0] dbg_redirect_pc
);  
    // VARIABLES

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

    // Redirect signals for branching
    logic        redirect;
    logic [31:0] redirect_pc;

    // Branch target
    logic [31:0] branch_target;

    // Jump targets
    logic [31:0] jal_target;
    logic [31:0] jalr_target;

    // Forwarding signals
    logic [31:0] forwarded_rs1;
    logic [31:0] forwarded_rs2;

    logic forward_rs1;
    logic forward_rs2;

    // Previous EX instructions
    logic [4:0] ex_rd;
    logic       ex_reg_write;
    logic [31:0] ex_result;

    // Load hazard
    logic load_use_hazard;

    logic uses_rs1;
    logic uses_rs2;

    // Memory-wait state
    logic mem_stall;
    logic start_mem;
    logic finish_mem;

    // Memory pending state
    logic mem_pending;

    // Load metadata
    logic [4:0] load_rd;
    logic [2:0] load_funct3;
    logic [1:0] load_addr_offset;
    //logic       load_unsigned;

    // Load writeback

    logic load_wb;

    logic [4:0] rf_rd;

    // LOGIC

    assign finish_load = stall && dmem_resp.valid;

    assign alu_operand_a =
        (id_ex_out.control.alu_a_sel == ALU_A_PC)
            ? id_ex_out.pc
            : forwarded_rs1;

    assign alu_operand_b =
        id_ex_out.control.alu_b_sel
            ? id_ex_out.immediate
            : forwarded_rs2;

    // Simple Memory
    assign imem_addr = pc;
    //assign instruction = imem_rdata;

    //assign rf_we = (!stall && reg_write && !mem_read && rd != 0) || finish_load;

    // Debug variables
    assign dbg_pc = pc;
    assign dbg_instr = instruction;

    assign dbg_reg_write = rf_we;
    assign dbg_rd        = rf_rd;
    assign dbg_write_data = writeback_data;    

    assign dbg_stall = mem_stall || load_use_hazard;

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
        control.pc_sel = pc_sel;
    end

    assign id_ex_in.control     = control;

    assign if_id_in.valid = 1'b1;
    assign id_ex_in.valid = if_id_out.valid;

    assign rf_we =
        (
            id_ex_out.valid &&
            id_ex_out.control.reg_write &&
            !id_ex_out.control.mem_read &&
            (id_ex_out.rd != 5'd0)
        )
        ||
        (
            load_wb &&
            (load_rd != 5'd0)
        );

    assign branch_target = id_ex_out.pc + id_ex_out.immediate;

    always_comb begin
        redirect = 1'b0;
        redirect_pc = pc + 32'd4;

        if (id_ex_out.control.branch && take_branch) begin
            redirect = 1'b1;
            redirect_pc = id_ex_out.pc + id_ex_out.immediate;
        end
        else if (id_ex_out.control.jump) begin
            redirect = 1'b1;

            if (id_ex_out.control.pc_sel == PC_JAL)
                redirect_pc = id_ex_out.pc + id_ex_out.immediate;

            else if (id_ex_out.control.pc_sel == PC_JALR)
                redirect_pc =
                    (id_ex_out.rs1_data + id_ex_out.immediate)
                    & 32'hFFFF_FFFE;
        end
    end

    always_ff @(posedge clk) begin
        if (rst)
            pc <= 32'h0;
        else if (redirect)
            pc <= redirect_pc;
        else if (!load_use_hazard && !mem_stall)
            pc <= pc + 32'd4;
    end

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
        if (load_wb) begin
            writeback_data = load_data;
        end
        else begin
            unique case (id_ex_out.control.wb_sel)
                WB_ALU:
                    writeback_data = alu_result;

                WB_PC4:
                    writeback_data = id_ex_out.pc + 32'd4;

                default:
                    writeback_data = 32'd0;
            endcase
        end
    end

    // Forwarding
    always_ff @(posedge clk) begin
        if (rst) begin
            ex_rd        <= 5'd0;
            ex_reg_write <= 1'b0;
            ex_result    <= 32'd0;
        end
        else begin
            ex_rd        <= id_ex_out.rd;
            ex_reg_write <= id_ex_out.valid &&
                            id_ex_out.control.reg_write;
            ex_result    <= writeback_data;
        end
    end

    assign forward_rs1 =
        ex_reg_write &&
        ex_rd != 5'd0 &&
        ex_rd == id_ex_out.rs1;

    assign forward_rs2 =
        ex_reg_write &&
        ex_rd != 5'd0 &&
        ex_rd == id_ex_out.rs2;

    assign forwarded_rs1 =
        forward_rs1 ? ex_result : id_ex_out.rs1_data;

    assign forwarded_rs2 =
        forward_rs2 ? ex_result : id_ex_out.rs2_data;

    always_comb begin
        uses_rs1 = 1'b0;
        uses_rs2 = 1'b0;

        unique case (opcode)

            OPCODE_OP: begin
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b1;
            end

            OPCODE_OP_IMM: begin
                uses_rs1 = 1'b1;
            end

            OPCODE_LOAD: begin
                uses_rs1 = 1'b1;
            end

            OPCODE_STORE: begin
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b1;
            end

            OPCODE_BRANCH: begin
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b1;
            end

            OPCODE_JALR: begin
                uses_rs1 = 1'b1;
            end

            default: begin
            end

        endcase
    end

    assign load_use_hazard =
        id_ex_out.valid &&
        id_ex_out.control.mem_read &&
        id_ex_out.rd != 5'd0 &&
        (
            (uses_rs1 && (id_ex_out.rd == rs1)) ||
            (uses_rs2 && (id_ex_out.rd == rs2))
        );

    assign start_mem =
        id_ex_out.valid &&
        (id_ex_out.control.mem_read ||
        id_ex_out.control.mem_write) &&
        !mem_stall;

    assign finish_mem =
        mem_stall &&
        dmem_resp.valid;

    assign start_load =
        id_ex_out.valid &&
        id_ex_out.control.mem_read &&
        !mem_stall;

    always_ff @(posedge clk) begin
        if (rst) begin
            mem_pending <= 1'b0;
        end
        else begin
            if (dmem_req.valid && !dmem_req.write)
                mem_pending <= 1'b1;
            else if (mem_pending && dmem_resp.valid)
                mem_pending <= 1'b0;
        end
    end

    assign mem_stall = mem_pending;

    always_ff @(posedge clk) begin
        if (rst) begin
            load_rd          <= 5'd0;
            load_funct3      <= 3'd0;
            load_addr_offset <= 2'd0;
            //load_unsigned    <= 1'b0;
        end
        else if (dmem_req.valid && !dmem_req.write) begin
            load_rd          <= id_ex_out.rd;
            load_funct3      <= id_ex_out.funct3;
            load_addr_offset <= alu_result[1:0];
            //load_unsigned    <= id_ex_out.control.mem_unsigned;
        end
    end

    assign load_wb = mem_pending && dmem_resp.valid;

    assign rf_rd =
        load_wb
            ? load_rd
            : id_ex_out.rd;

    // Drive deme_req
    assign dmem_req.valid =
        id_ex_out.valid &&
        (id_ex_out.control.mem_read ||
        id_ex_out.control.mem_write) &&
        !mem_pending;
    assign dmem_req.write =
        id_ex_out.valid &&
        id_ex_out.control.mem_write;
    assign dmem_req.addr = alu_result;
    assign dmem_req.wdata = store_wdata;
    assign dmem_req.wstrb = store_wstrb;

    assign req_valid = dmem_req.valid;
    assign req_write = dmem_req.write;
    assign req_addr = dmem_req.addr;
    assign req_wdata = dmem_req.wdata;
    assign req_wstrb = dmem_req.wstrb;

    assign resp_valid = dmem_resp.valid;

    assign dbg_branch          = id_ex_out.control.branch;
    assign dbg_take_branch     = take_branch;
    assign dbg_branch_rs1     = id_ex_out.rs1_data;
    assign dbg_branch_rs2     = id_ex_out.rs2_data;
    assign dbg_redirect       = redirect;
    assign dbg_redirect_pc    = redirect_pc;

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
        .rd(rf_rd),

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
        .rs1(forwarded_rs1),
        .rs2(forwarded_rs2),

        .funct3(id_ex_out.funct3),

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
        .addr_offset(load_addr_offset),
        .funct3(load_funct3),
        .load_data(load_data)
    );

    store_unit su(
        .addr_offset(addr_offset),
        .funct3(id_ex_out.funct3),
        .rs2_data(forwarded_rs2),
        .wdata(store_wdata),
        .wstrb(store_wstrb)
    );

    if_id_reg if_id_reg0 (
        .clk(clk),
        .rst(rst),

        .d(if_id_in),
        .q(if_id_out),
        .flush(redirect),
        .enable(!load_use_hazard && !mem_stall)
    );

    id_ex_reg id_ex_reg0 (
        .clk(clk),
        .rst(rst),

        .d(id_ex_in),
        .q(id_ex_out),
        .flush(redirect || load_use_hazard),
        .enable(!mem_stall)
    );

endmodule