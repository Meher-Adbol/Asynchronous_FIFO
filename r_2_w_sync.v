// Synchronizer: Read to Write
module sync_rd_to_wr #(
    parameter ADDR_WIDTH = 6
)(
    output reg [ADDR_WIDTH:0] wr_sync_to_rd,
    input wire [ADDR_WIDTH:0] rd_ptr,
    input wire wr_clk, wr_rst_n
);
                 
    reg [ADDR_WIDTH:0] temp_ptr;
    
    // 2 flop synchronizer for read pointer with respect to write clock
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            {wr_sync_to_rd, temp_ptr} <= 0;
        end else begin
            {wr_sync_to_rd, temp_ptr} <= {temp_ptr, rd_ptr};
        end
    end
            
endmodule
