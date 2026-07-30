module imem
(
    input  logic [31:0] addr,
    output logic [31:0] instruction
);
    initial begin
        $readmemh("program.hex", memory);
    end
endmodule