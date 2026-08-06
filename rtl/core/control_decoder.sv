import rv32_pkg::*;

/*
Instruction Control Table

             reg_write  imm_type  wb_sel   pc_sel

ADD              1        NONE     ALU     PC+4
ADDI             1        I        ALU     PC+4
LUI              1        U        IMM     PC+4
JAL              1        J        PC4     JUMP
JALR             1        I        PC4     JALR
BEQ              0        B        NONE    BRANCH

*/

module control_decoder
(
    input opcode_t opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,

    output alu_op_t alu_op,
    output imm_type_t imm_type,
    output pc_sel_t pc_sel,
    output wb_sel_t wb_sel,
    output alu_a_sel_t alu_a_sel,

    output logic reg_write,
    output logic mem_read,
    output logic mem_write,
    output logic branch,
    output logic jump,
    output logic alu_b_sel,
    output logic mem_to_reg,
    output logic [1:0] mem_size,
    output logic mem_unsigned
);

    always_comb begin
        // defaults
        alu_op      = ALU_ADD;
        imm_type    = IMM_NONE;

        pc_sel = PC_PLUS_4;
        wb_sel = WB_ALU;

        alu_a_sel = ALU_A_RS1;

        reg_write   = 0;

        mem_read    = 0;
        mem_write   = 0;

        branch      = 0;
        jump        = 0;

        alu_b_sel     = 0;
        mem_to_reg  = 0;

        unique case (opcode)
            OPCODE_OP:
            begin
                reg_write = 1;
                pc_sel = PC_PLUS_4;
                wb_sel = WB_ALU;
                unique case(funct3)
                F3_AND:
                    alu_op = ALU_AND;
                F3_OR:
                    alu_op = ALU_OR;
                F3_XOR:
                    alu_op = ALU_XOR;
                F3_SLL:
                    alu_op = ALU_SLL;
                F3_SLT:
                    alu_op = ALU_SLT;
                F3_SLTU:
                    alu_op = ALU_SLTU;
                F3_ADD_SUB:
                begin

                    if (funct7 == F7_NORMAL)
                        alu_op = ALU_ADD;
                    else if (funct7 == F7_ALT)
                        alu_op = ALU_SUB;

                end
                F3_SRL_SRA:
                begin

                    if (funct7 == F7_NORMAL)
                        alu_op = ALU_SRL;
                    else if (funct7 == F7_ALT)
                        alu_op = ALU_SRA;

                end
                endcase
            end

            OPCODE_OP_IMM:
            begin
                reg_write = 1;
                alu_b_sel   = 1;
                imm_type  = IMM_I;
                pc_sel = PC_PLUS_4;
                wb_sel = WB_ALU;
                unique case(funct3)
                F3_AND:
                    alu_op = ALU_AND;
                F3_OR:
                    alu_op = ALU_OR;
                F3_XOR:
                    alu_op = ALU_XOR;
                F3_SLL:
                    alu_op = ALU_SLL;
                F3_SLT:
                    alu_op = ALU_SLT;
                F3_SLTU:
                    alu_op = ALU_SLTU;
                F3_ADD_SUB:
                begin

                    if (funct7 == F7_NORMAL)
                        alu_op = ALU_ADD;
                    else if (funct7 == F7_ALT)
                        alu_op = ALU_SUB;

                end
                F3_SRL_SRA:
                begin

                    if (funct7 == F7_NORMAL)
                        alu_op = ALU_SRL;
                    else if (funct7 == F7_ALT)
                        alu_op = ALU_SRA;

                end
                endcase
            end
            OPCODE_JAL:
            begin
                reg_write = 1;
                imm_type = IMM_J;
                branch = 0;
                jump = 1;
                alu_b_sel = 0;
                pc_sel = PC_JAL;
                wb_sel = WB_PC4;
            end
            OPCODE_JALR:
            begin
                pc_sel = PC_JALR;
                wb_sel = WB_PC4;

                reg_write = 1;
                jump = 1;
                alu_b_sel = 1;
                imm_type = IMM_I;
                alu_op = ALU_ADD;
            end
            OPCODE_BRANCH:
            begin
                reg_write = 0;
                imm_type = IMM_B;
                pc_sel = PC_BRANCH;
            end
            OPCODE_LOAD:
            begin
                reg_write = 1;
                mem_read = 1;
                imm_type = IMM_I;
                wb_sel = WB_MEM;

                alu_b_sel   = 1;
                alu_op    = ALU_ADD;


                unique case(funct3)

                    F3_LB:
                        begin
                            mem_size = BYTE;
                            mem_unsigned = 0;
                        end

                    F3_LBU:
                        begin
                            mem_size = BYTE;
                            mem_unsigned = 1;
                        end

                    F3_LH:
                        begin
                            mem_size = HALF;
                            mem_unsigned = 0;
                        end

                    F3_LHU:
                        begin
                            mem_size = HALF;
                            mem_unsigned = 1;
                        end

                    F3_LW:
                        begin
                            mem_size = WORD;
                            mem_unsigned = 0;
                        end
                    default:
                    ;
                endcase
            end
            OPCODE_STORE:
            begin
                mem_write = 1;
                imm_type = IMM_S;

                alu_b_sel   = 1;
                alu_op    = ALU_ADD;

                unique case(funct3)

                    F3_SB:
                        mem_size = BYTE;

                    F3_SH:
                        mem_size = HALF;

                    F3_SW:
                        mem_size = WORD;
                    default:
                    ;
                endcase
            end
            OPCODE_LUI:
            begin
                reg_write = 1;
                imm_type = IMM_U;
                wb_sel = WB_ALU;
                alu_b_sel = 1;
                alu_op = ALU_COPY_B;
            end
            OPCODE_AUIPC:
            begin
                reg_write = 1;
                imm_type = IMM_U;
                wb_sel = WB_ALU;
                alu_b_sel = 1;
                alu_op = ALU_ADD;
                alu_a_sel = ALU_A_PC;
            end
            default:
            ;
        endcase
    end

endmodule