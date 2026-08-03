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
                immediate = {{20{instruction[31]}},
                            instruction[31:25],
                            instruction[11:7]};
            IMM_B:
                immediate = {
                    {19{instruction[31]}},
                    instruction[31],      // imm[12]
                    instruction[7],       // imm[11]
                    instruction[30:25],   // imm[10:5]
                    instruction[11:8],    // imm[4:1]
                    1'b0
                };
            IMM_U:
                immediate =
                {
                    instruction[31:12],
                    12'b0
                };
            IMM_J:
                immediate = {
                    {11{instruction[31]}},
                    instruction[31],      // imm[20]
                    instruction[19:12],   // imm[19:12]
                    instruction[20],      // imm[11]
                    instruction[30:21],   // imm[10:1]
                    1'b0
                };
            default:
            ;
        endcase

    end
endmodule