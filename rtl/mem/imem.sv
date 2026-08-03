module imem
#(
    parameter string INIT_FILE = "program.hex"
)
(
    input  logic [31:0] addr,
    output logic [31:0] instruction
);

logic [31:0] memory [0:255];

initial begin
    $readmemh(INIT_FILE, memory);
end

assign instruction = memory[addr[9:2]];

endmodule