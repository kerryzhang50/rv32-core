package rv32_pkg;

    typedef enum logic [3:0] {

        ALU_ADD  = 4'd0,
        ALU_SUB  = 4'd1,
        ALU_AND  = 4'd2,
        ALU_OR   = 4'd3,
        ALU_XOR  = 4'd4,
        ALU_SLL  = 4'd5,
        ALU_SRL  = 4'd6,
        ALU_SRA  = 4'd7,
        ALU_SLT  = 4'd8,
        ALU_SLTU = 4'd9,
        ALU_COPY_B = 4'd10

    } alu_op_t;

    typedef enum logic [6:0] {

        OPCODE_LOAD    = 7'b0000011,
        OPCODE_STORE   = 7'b0100011,
        OPCODE_BRANCH  = 7'b1100011,
        OPCODE_JALR    = 7'b1100111,
        OPCODE_JAL     = 7'b1101111,
        OPCODE_OP_IMM  = 7'b0010011,
        OPCODE_OP      = 7'b0110011,
        OPCODE_LUI     = 7'b0110111,
        OPCODE_AUIPC   = 7'b0010111

    } opcode_t;

    typedef enum logic [2:0] {

        F3_ADD_SUB = 3'b000,
        F3_SLL     = 3'b001,
        F3_SLT     = 3'b010,
        F3_SLTU    = 3'b011,
        F3_XOR     = 3'b100,
        F3_SRL_SRA = 3'b101,
        F3_OR      = 3'b110,
        F3_AND     = 3'b111

    } funct3_alu_t;

    typedef enum logic [2:0] {
        F3_BEQ  = 3'b000,
        F3_BNE  = 3'b001,
        F3_BLT  = 3'b100,
        F3_BGE  = 3'b101,
        F3_BLTU = 3'b110,
        F3_BGEU = 3'b111
    } funct3_branch_t;

    typedef enum logic [2:0] {
        F3_LB  = 3'b000,
        F3_LH  = 3'b001,
        F3_LW  = 3'b010,
        F3_LBU = 3'b100,
        F3_LHU = 3'b101
    } funct3_load_t;

    typedef enum logic [2:0] {
        F3_SB = 3'b000,
        F3_SH = 3'b001,
        F3_SW = 3'b010
    } funct3_store_t;

    typedef enum logic [6:0] {

        F7_NORMAL = 7'b0000000,
        F7_ALT    = 7'b0100000

    } funct7_t;

    typedef enum logic [2:0] {
        IMM_NONE = 3'd0,
        IMM_I    = 3'd1,
        IMM_S    = 3'd2,
        IMM_B    = 3'd3,
        IMM_U    = 3'd4,
        IMM_J    = 3'd5
    } imm_type_t;

    typedef enum logic [1:0] {
        PC_PLUS_4,
        PC_JAL,
        PC_JALR,
        PC_BRANCH
    } pc_sel_t;

    typedef enum logic [1:0] {
        WB_ALU,
        WB_PC4,
        WB_MEM
    } wb_sel_t;

    typedef enum logic [1:0] {
        BYTE,
        HALF,
        WORD
    } mem_size_t;

    typedef struct packed {
        logic        mem_read;
        logic        mem_write;

        mem_size_t   mem_size;
        logic        mem_unsigned;
    } mem_ctrl_t;

    typedef enum logic {
        ALU_A_RS1,
        ALU_A_PC
    } alu_a_sel_t;

    typedef struct packed {

    logic reg_write;

    logic mem_read;
    logic mem_write;

    logic mem_to_reg;

    logic alu_b_sel;

    logic branch;
    logic jump;

    alu_op_t alu_op;

} control_t;

typedef struct packed {

    logic [31:0] pc;
    logic [31:0] instr;

} if_id_t;

typedef struct packed {

    logic [31:0] pc;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    logic [31:0] immediate;

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    logic [2:0] funct3;

    control_t control;

} id_ex_t;

endpackage