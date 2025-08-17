// FIFO Memory Module
module fifo_memory #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 6,
    parameter FIFO_DEPTH = 64
)(
    output wire [DATA_WIDTH-1:0] rd_data,
    input wire [DATA_WIDTH-1:0] wr_data,
    input wire [ADDR_WIDTH-1:0] wr_addr, rd_addr,
    input wire wr_en, full, wr_clk
);

    // RTL Verilog memory model
    reg [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];
    
    assign rd_data = mem[rd_addr];
    
    always @(posedge wr_clk) begin
        if (wr_en & (~full)) 
            mem[wr_addr] <= wr_data;
    end
    
endmodule
