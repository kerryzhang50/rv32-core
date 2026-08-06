import rv32_pkg::*;

module store_unit(
    input logic [1:0]  addr_offset,
    input logic [2:0]  funct3,
    input logic [31:0] rs2_data,

    output  logic [31:0] wdata,
    output  logic [3:0]  wstrb
);

    always_comb begin
        wdata = 32'd0;
        wstrb = 4'b0000;
        unique case (funct3)
            F3_SW: begin
                wdata = rs2_data;
                wstrb = 4'b1111;
            end
            F3_SB: begin
                case (addr_offset)
                    2'b00:
                    begin
                        wdata = rs2_data;
                        wstrb = 4'b0001;
                    end
                    2'b01:
                    begin
                        wdata = rs2_data << 8;
                        wstrb = 4'b0010;
                    end
                    2'b10:
                    begin
                        wdata = rs2_data << 16;
                        wstrb = 4'b0100;
                    end
                    2'b11:
                    begin
                        wdata = rs2_data << 24;
                        wstrb = 4'b1000;
                    end
                endcase
            end
            F3_SH: begin
                case (addr_offset[1])
                    0:
                    begin
                        wdata = rs2_data;
                        wstrb = 4'b0011;
                    end

                    1:
                    begin
                        wdata = rs2_data << 16;
                        wstrb = 4'b1100;
                    end
                endcase
            end
            default: begin
                wdata = 32'd0;
                wstrb = 4'b0000;
            end
        endcase
    end

endmodule