module id_ex_reg (

    input logic clk,
    input logic rst,

    input  id_ex_t d,
    output id_ex_t q,
    
    input logic flush,
    input logic enable
);

    import rv32_pkg::*;

    id_ex_t q_reg;

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