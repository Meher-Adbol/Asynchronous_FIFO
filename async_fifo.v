module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 6,  // For 64-depth FIFO (2^6 = 64)
    parameter FIFO_DEPTH = 64
)(
    // Write port (write clock domain)
    input wire wr_clk,
    input wire wr_rst_n,
    input wire wr_en,
    input wire [DATA_WIDTH-1:0] wr_data,
    output wire full,
    
    // Read port (read clock domain)
    input wire rd_clk,
    input wire rd_rst_n,
    input wire rd_en,
    output wire [DATA_WIDTH-1:0] rd_data,
    output wire empty,
    
    // Status flags
    output wire almost_full,
    output wire almost_empty
);

    // Internal signals
    wire [ADDR_WIDTH-1:0] wr_addr, rd_addr;
    wire [ADDR_WIDTH:0] wr_ptr, rd_ptr, wr_sync_to_rd, rd_sync_to_wr;

    // Synchronizers
    sync_rd_to_wr sync_rd2wr (
        .wr_sync_to_rd(wr_sync_to_rd),
        .rd_ptr(rd_ptr),
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n)
    );

    sync_wr_to_rd sync_wr2rd (
        .rd_sync_to_wr(rd_sync_to_wr),
        .wr_ptr(wr_ptr),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n)
    );

    // FIFO memory
    fifo_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) fifo_mem (
        .rd_data(rd_data),
        .wr_data(wr_data),
        .wr_addr(wr_addr),
        .rd_addr(rd_addr),
        .wr_en(wr_en),
        .full(full),
        .wr_clk(wr_clk)
    );

    // Read pointer and empty logic
    rd_ptr_empty #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) rd_ptr_ctrl (
        .empty(empty),
        .rd_addr(rd_addr),
        .rd_ptr(rd_ptr),
        .wr_sync_to_rd(wr_sync_to_rd),
        .rd_en(rd_en),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n)
    );

    // Write pointer and full logic
    wr_ptr_full #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) wr_ptr_ctrl (
        .full(full),
        .wr_addr(wr_addr),
        .wr_ptr(wr_ptr),
        .rd_sync_to_wr(rd_sync_to_wr),
        .wr_en(wr_en),
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n)
    );

    // Almost full/empty flags (simplified implementation)
    assign almost_full = 1'b0;  // Can be implemented based on pointer difference
    assign almost_empty = 1'b0; // Can be implemented based on pointer difference

endmodule

