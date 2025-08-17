// Synchronizer: Write to Read
module sync_wr_to_rd #(
    parameter ADDR_WIDTH = 6
)(
    output reg [ADDR_WIDTH:0] rd_sync_to_wr,
    input wire [ADDR_WIDTH:0] wr_ptr,
    input wire rd_clk, rd_rst_n
);
                 
    reg [ADDR_WIDTH:0] temp_ptr;
    
    // 2 flop synchronizer for write pointer with respect to read clock
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            {rd_sync_to_wr, temp_ptr} <= 0;
        end else begin
            {rd_sync_to_wr, temp_ptr} <= {temp_ptr, wr_ptr};
        end
    end
            
endmodule