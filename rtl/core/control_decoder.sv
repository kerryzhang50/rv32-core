import rv32_pkg::*;

module control_decoder
(
    input opcode_t opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,

    output alu_op_t alu_op,
    output imm_type_t imm_type,

    output logic reg_write,
    output logic mem_read,
    output logic mem_write,
    output logic branch,
    output logic jump,
    output logic alu_src,
    output logic mem_to_reg
);

    always_comb begin
        alu_op      = ALU_ADD;
        imm_type    = IMM_NONE;

        reg_write   = 0;

        mem_read    = 0;
        mem_write   = 0;

        branch      = 0;
        jump        = 0;

        alu_src     = 0;
        mem_to_reg  = 0;

        unique case (opcode)
            OPCODE_OP:
            begin
                reg_write = 1;
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
                alu_src   = 1;
                imm_type  = IMM_I;
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
            default:
            ;
        endcase
    end

endmodule