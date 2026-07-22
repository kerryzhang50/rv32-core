module top(

    input logic clk,
    input logic rst

);

rv32_core cpu(

    .clk(clk),
    .rst(rst)

);

endmodule