`timescale 1ns/1ps

module async_fifo_tb;

    // Testbench parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 6;
    parameter FIFO_DEPTH = 64;
    parameter WR_CLK_PERIOD = 12.5;  // 80 MHz = 12.5ns period
    parameter RD_CLK_PERIOD = 40;    // 25 MHz = 40ns period
    parameter BURST_LENGTH = 80;
    
    // Clock and reset signals
    reg wr_clk, rd_clk;
    reg wr_rst_n, rd_rst_n;
    
    // FIFO interface signals
    reg wr_en, rd_en;
    reg [DATA_WIDTH-1:0] wr_data;
    wire [DATA_WIDTH-1:0] rd_data;
    wire full, empty, almost_full, almost_empty;
    
    // Testbench variables
    integer i, j;
    integer write_count, read_count;
    integer error_count;
    reg [DATA_WIDTH-1:0] expected_data;
    reg [DATA_WIDTH-1:0] test_data [0:255];  // Test data array
    
    // Instantiate the FIFO
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty)
    );
    
    // Clock generation
    initial begin
        wr_clk = 0;
        forever #(WR_CLK_PERIOD/2) wr_clk = ~wr_clk;
    end
    
    initial begin
        rd_clk = 0;
        forever #(RD_CLK_PERIOD/2) rd_clk = ~rd_clk;
    end
    
    // Initialize test data
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            test_data[i] = i;
        end
    end
    
    // Main test sequence
    initial begin
        // Initialize signals
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        write_count = 0;
        read_count = 0;
        error_count = 0;
        
        // Reset sequence
        wr_rst_n = 0;
        rd_rst_n = 0;
        #100;
        wr_rst_n = 1;
        rd_rst_n = 1;
        #50;
        
        // Test 1: Basic functionality - write and read
        $display("Test 1: Basic write and read operations");
        test_basic_operations();
        
        // Test 2: Burst write and read
        $display("Test 2: Burst operations (80 elements)");
        test_burst_operations();
        
        // Test 3: Full FIFO test
        $display("Test 3: Full FIFO test");
        test_full_fifo();
        
        // Test 4: Empty FIFO test
        $display("Test 4: Empty FIFO test");
        test_empty_fifo();
        
        // Test 5: Almost full/empty flags
        $display("Test 5: Almost full/empty flag test");
        test_almost_flags();
        
        // Test 6: Concurrent read and write
        $display("Test 6: Concurrent read and write test");
        test_concurrent_operations();
        
        // Test 7: Reset during operation
        $display("Test 7: Reset during operation test");
        test_reset_during_operation();
        
        // Summary
        $display("Test Summary:");
        $display("Total writes: %0d", write_count);
        $display("Total reads: %0d", read_count);
        $display("Errors: %0d", error_count);
        
        if (error_count == 0) begin
            $display("All tests PASSED!");
        end else begin
            $display("Some tests FAILED!");
        end
        
        #1000;
        $finish;
    end
    
    // Test 1: Basic write and read operations
    task test_basic_operations;
        begin
            // Write 10 elements
            for (i = 0; i < 10; i = i + 1) begin
                @(posedge wr_clk);
                wr_en = 1;
                wr_data = test_data[i];
                write_count = write_count + 1;
                $display("Write: data=%0d", wr_data);
            end
            @(posedge wr_clk);
            wr_en = 0;
            
            // Read 10 elements
            for (i = 0; i < 10; i = i + 1) begin
                @(posedge rd_clk);
                rd_en = 1;
                @(posedge rd_clk);
                expected_data = test_data[i];
                if (rd_data !== expected_data) begin
                    $display("ERROR: Expected %0d, Got %0d", expected_data, rd_data);
                    error_count = error_count + 1;
                end else begin
                    $display("Read: data=%0d (PASS)", rd_data);
                end
                read_count = read_count + 1;
            end
            @(posedge rd_clk);
            rd_en = 0;
            #100;
        end
    endtask
    
    // Test 2: Burst operations
    task test_burst_operations;
        begin
            // Burst write 80 elements
            for (i = 0; i < BURST_LENGTH; i = i + 1) begin
                @(posedge wr_clk);
                if (!full) begin
                    wr_en = 1;
                    wr_data = test_data[i % 256];
                    write_count = write_count + 1;
                end else begin
                    wr_en = 0;
                    i = i - 1;  // Retry this element
                end
            end
            @(posedge wr_clk);
            wr_en = 0;
            
            // Burst read 80 elements
            for (i = 0; i < BURST_LENGTH; i = i + 1) begin
                @(posedge rd_clk);
                if (!empty) begin
                    rd_en = 1;
                    @(posedge rd_clk);
                    expected_data = test_data[i % 256];
                    if (rd_data !== expected_data) begin
                        $display("ERROR: Expected %0d, Got %0d", expected_data, rd_data);
                        error_count = error_count + 1;
                    end
                    read_count = read_count + 1;
                end else begin
                    rd_en = 0;
                    i = i - 1;  // Retry this element
                end
            end
            @(posedge rd_clk);
            rd_en = 0;
            #100;
        end
    endtask
    
    // Test 3: Full FIFO test
    task test_full_fifo;
        begin
            // Write until FIFO is full
            i = 0;
            while (!full && i < FIFO_DEPTH + 10) begin
                @(posedge wr_clk);
                wr_en = 1;
                wr_data = test_data[i % 256];
                write_count = write_count + 1;
                i = i + 1;
            end
            @(posedge wr_clk);
            wr_en = 0;
            
            if (full) begin
                $display("FIFO full flag asserted correctly");
            end else begin
                $display("ERROR: FIFO should be full");
                error_count = error_count + 1;
            end
            
            // Try to write when full (should be ignored)
            @(posedge wr_clk);
            wr_en = 1;
            wr_data = 8'hFF;
            @(posedge wr_clk);
            wr_en = 0;
            
            #100;
        end
    endtask
    
    // Test 4: Empty FIFO test
    task test_empty_fifo;
        begin
            // Read until FIFO is empty
            i = 0;
            while (!empty && i < FIFO_DEPTH + 10) begin
                @(posedge rd_clk);
                rd_en = 1;
                @(posedge rd_clk);
                read_count = read_count + 1;
                i = i + 1;
            end
            @(posedge rd_clk);
            rd_en = 0;
            
            if (empty) begin
                $display("FIFO empty flag asserted correctly");
            end else begin
                $display("ERROR: FIFO should be empty");
                error_count = error_count + 1;
            end
            
            // Try to read when empty (should return 0)
            @(posedge rd_clk);
            rd_en = 1;
            @(posedge rd_clk);
            if (rd_data === 0) begin
                $display("Empty FIFO read returns 0 correctly");
            end else begin
                $display("ERROR: Empty FIFO should return 0");
                error_count = error_count + 1;
            end
            rd_en = 0;
            
            #100;
        end
    endtask
    
    // Test 5: Almost full/empty flags
    task test_almost_flags;
        begin
            // Write until almost full
            i = 0;
            while (!almost_full && i < FIFO_DEPTH + 10) begin
                @(posedge wr_clk);
                wr_en = 1;
                wr_data = test_data[i % 256];
                write_count = write_count + 1;
                i = i + 1;
            end
            
            if (almost_full) begin
                $display("Almost full flag asserted correctly");
            end
            
            @(posedge wr_clk);
            wr_en = 0;
            
            // Read until almost empty
            i = 0;
            while (!almost_empty && i < FIFO_DEPTH + 10) begin
                @(posedge rd_clk);
                rd_en = 1;
                @(posedge rd_clk);
                read_count = read_count + 1;
                i = i + 1;
            end
            
            if (almost_empty) begin
                $display("Almost empty flag asserted correctly");
            end
            
            @(posedge rd_clk);
            rd_en = 0;
            #100;
        end
    endtask
    
    // Test 6: Concurrent read and write
    task test_concurrent_operations;
        begin
            // Start concurrent operations
            fork
                // Write thread
                begin
                    for (i = 0; i < 20; i = i + 1) begin
                        @(posedge wr_clk);
                        if (!full) begin
                            wr_en = 1;
                            wr_data = test_data[i % 256];
                            write_count = write_count + 1;
                        end else begin
                            wr_en = 0;
                        end
                    end
                    @(posedge wr_clk);
                    wr_en = 0;
                end
                
                // Read thread
                begin
                    for (i = 0; i < 20; i = i + 1) begin
                        @(posedge rd_clk);
                        if (!empty) begin
                            rd_en = 1;
                            @(posedge rd_clk);
                            read_count = read_count + 1;
                        end else begin
                            rd_en = 0;
                        end
                    end
                    @(posedge rd_clk);
                    rd_en = 0;
                end
            join
            
            #100;
        end
    endtask
    
    // Test 7: Reset during operation
    task test_reset_during_operation;
        begin
            // Start writing
            @(posedge wr_clk);
            wr_en = 1;
            wr_data = 8'hAA;
            
            // Reset during operation
            #50;
            wr_rst_n = 0;
            rd_rst_n = 0;
            #100;
            wr_rst_n = 1;
            rd_rst_n = 1;
            #50;
            
            // Check if FIFO is empty after reset
            if (empty) begin
                $display("FIFO properly reset to empty state");
            end else begin
                $display("ERROR: FIFO should be empty after reset");
                error_count = error_count + 1;
            end
            
            @(posedge wr_clk);
            wr_en = 0;
            #100;
        end
    endtask
    
    // Monitor FIFO status
    always @(posedge wr_clk) begin
        if (wr_en && !full) begin
            $display("Write: data=%0d, full=%0b, almost_full=%0b", wr_data, full, almost_full);
        end
    end
    
    always @(posedge rd_clk) begin
        if (rd_en && !empty) begin
            $display("Read: data=%0d, empty=%0b, almost_empty=%0b", rd_data, empty, almost_empty);
        end
    end

endmodule