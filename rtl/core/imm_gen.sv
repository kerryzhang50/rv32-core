import rv32_pkg::*;

module imm_gen
(
    input  logic [31:0] instruction,
    input  imm_type_t   imm_type,

    output logic [31:0] immediate
);

    always_comb begin

        immediate = 32'd0;

        unique case (imm_type)
            IMM_I:
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            IMM_S:
                immediate = {{20{instr[31]}},
                            instr[31:25],
                            instr[11:7]};
            IMM_B:
                immediate =
                {
                    {19{instr[31]}},
                    instr[31],
                    instr[7],
                    instr[30:25],
                    instr[11:8],
                    1'b0
                };
            IMM_U:
                immediate =
                {
                    instr[31:12],
                    12'b0
                };
            IMM_J:
                imm =
                {
                    {11{instr[31]}},
                    instr[31],
                    instr[19:12],
                    instr[20],
                    instr[30:21],
                    1'b0
                };
            default:
            ;
        endcase

    end
endmodule