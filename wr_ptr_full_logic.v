

// Write Pointer and Full Logic
module wr_ptr_full #(
    parameter ADDR_WIDTH = 6
)(
    output reg full,
    output wire [ADDR_WIDTH-1:0] wr_addr,
    output reg [ADDR_WIDTH:0] wr_ptr,
    input wire [ADDR_WIDTH:0] rd_sync_to_wr,
    input wire wr_en, wr_clk, wr_rst_n
);
    
    reg [ADDR_WIDTH:0] wr_bin;
    wire [ADDR_WIDTH:0] wr_gray_next, wr_bin_next;
    wire full_val;
    
    // Gray Style 2 pointer (both gray code and binary code registers are present)
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            {wr_bin, wr_ptr} <= 0;
        end else begin
            {wr_bin, wr_ptr} <= {wr_bin_next, wr_gray_next};
        end
    end
    
    assign wr_bin_next = wr_bin + (wr_en & ~full);
    assign wr_gray_next = (wr_bin_next >> 1) ^ wr_bin_next;
    
    // Memory write-address pointer (binary is used to address memory)
    assign wr_addr = wr_bin[ADDR_WIDTH-1:0];
    
    // Full condition: simplified version
    assign full_val = (wr_gray_next == {~rd_sync_to_wr[ADDR_WIDTH:ADDR_WIDTH-1], rd_sync_to_wr[ADDR_WIDTH-2:0]});
    
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            full <= 1'b0;
        end else begin
            full <= full_val;
        end
    end
    
endmodule
