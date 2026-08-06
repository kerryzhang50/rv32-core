import mem_if::*;

module simple_dmem
#(
    parameter DEPTH = 256
)
(
    input  logic clk,
    input  logic rst,
    
    //input  dmem_req_t req,
    //output dmem_resp_t resp,

    
    input  logic        req_valid,
    input  logic        req_write,
    input  logic [31:0] req_addr,
    input  logic [31:0] req_wdata,
    input  logic [3:0]  req_wstrb,

    output logic        resp_valid,
    output logic [31:0] resp_rdata
    
);
    logic [31:0] memory [0:DEPTH-1];

    logic        pending_read;

    logic [31:0] pending_addr;

    
    dmem_req_t req;
    dmem_resp_t resp;

    
    assign req.valid = req_valid;
    assign req.write = req_write;
    assign req.addr  = req_addr;
    assign req.wdata = req_wdata;
    assign req.wstrb = req_wstrb;

    assign resp_valid = resp.valid;
    assign resp_rdata = resp.rdata;
    

    always_ff @(posedge clk) 
    begin
        if (rst)
        begin
            pending_read <= 0;
            pending_addr <= '0;

            resp.valid <= 0;
            resp.rdata <= '0;
        end
        else
        begin
            // default: no pending read next cycle
            pending_read <= 0;  
            resp.valid <= pending_read;
            if (pending_read)
                resp.rdata <= memory[pending_addr[9:2]];
            else
                resp.valid <= 1'b0;
            if (req.valid)
            begin

                if (req.write)
                begin
                    memory[req.addr[9:2]] <= req.wdata;
                    
                    pending_read <= 0;
                end
                else
                begin
                    pending_read <= 1;
                    pending_addr <= req.addr;
                end

            end            
        end
    end
endmodule