// Read Pointer and Empty Logic
module rd_ptr_empty #(
    parameter ADDR_WIDTH = 6
)(
    output reg empty,
    output wire [ADDR_WIDTH-1:0] rd_addr,
    output reg [ADDR_WIDTH:0] rd_ptr,
    input wire [ADDR_WIDTH:0] wr_sync_to_rd,
    input wire rd_en, rd_clk, rd_rst_n
);
    
    reg [ADDR_WIDTH:0] rd_bin;
    wire [ADDR_WIDTH:0] rd_gray_next, rd_bin_next;
    wire empty_val;
    
    // Gray Style 2 pointer (both gray code and binary code registers are present)
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            {rd_bin, rd_ptr} <= 0;
        end else begin
            {rd_bin, rd_ptr} <= {rd_bin_next, rd_gray_next};
        end
    end
    
    assign rd_bin_next = rd_bin + (rd_en & ~empty);
    assign rd_gray_next = (rd_bin_next >> 1) ^ rd_bin_next;
    
    // Memory read-address pointer (binary is used to address memory)
    assign rd_addr = rd_bin[ADDR_WIDTH-1:0];
    
    // FIFO empty when the next rd_ptr == synchronized wr_ptr or on reset
    assign empty_val = (rd_gray_next == wr_sync_to_rd);
    
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            empty <= 1'b1;
        end else begin
            empty <= empty_val;
        end
    end
    
endmodule