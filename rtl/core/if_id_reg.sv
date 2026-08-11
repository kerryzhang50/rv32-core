module if_id_reg (

    input logic clk,
    input logic rst,

    input  if_id_t d,
    output if_id_t q,

    input logic flush,
    input logic enable
);

    import rv32_pkg::*;

    if_id_t q_reg;

    assign q = q_reg;

    always_ff @(posedge clk) begin
        if (rst)
            q_reg <= '0;
        else if (flush)
            q_reg <= '0;
        else if (enable)
            q_reg <= d;
    end

endmodule