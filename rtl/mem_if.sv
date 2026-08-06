package mem_if;

typedef struct packed {
    logic        valid;      // Request is valid
    logic        write;      // 1 = store, 0 = load

    logic [31:0] addr;       // Byte address

    logic [31:0] wdata;      // Store data

    logic [3:0]  wstrb;      // Byte enables
} dmem_req_t;

typedef struct packed {
    logic        valid;
    logic [31:0] rdata;
} dmem_resp_t;

endpackage