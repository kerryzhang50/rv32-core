import rv32_pkg::*;

module load_unit(
    input logic [31:0] mem_word,
    input logic [1:0]  addr_offset,
    input logic [2:0]  funct3,

    output logic [31:0] load_data
);

    logic [7:0] selected_byte;
    logic [15:0] selected_half;

    always_comb begin
        unique case (addr_offset)

            2'b00:
                selected_byte = mem_word[7:0];

            2'b01:
                selected_byte = mem_word[15:8];

            2'b10:
                selected_byte = mem_word[23:16];

            2'b11:
                selected_byte = mem_word[31:24];

        endcase
    end

    always_comb begin

        unique case(addr_offset[1])

            1'b0:
                selected_half = mem_word[15:0];

            1'b1:
                selected_half = mem_word[31:16];

        endcase

    end

    always_comb begin
        load_data = 32'd0;
        unique case (funct3)

            F3_LW:
                load_data = mem_word;

            F3_LB:
                load_data = {{24{selected_byte[7]}}, selected_byte};

            F3_LBU:
                load_data = {24'd0, selected_byte};

            F3_LH:
                load_data = {{16{selected_half[15]}}, selected_half};

            F3_LHU:
                load_data = {16'd0, selected_half};
            default:
                load_data = 32'd0;

        endcase

    end

endmodule