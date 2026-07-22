`timescale 1ns/1ps

module tb_core;

logic clk;
logic rst;

rv32_core dut(
    .clk(clk),
    .rst(rst)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;

    #20;

    rst = 0;

    #200;

    $finish;

end

endmodule