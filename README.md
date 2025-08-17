# Asynchronous FIFO Design

This repository contains the Verilog implementation and report for a 64-depth asynchronous FIFO.

## Project Overview
- **Purpose**: Safe data transfer between two clock domains (write: 80 MHz, read: 25 MHz).  
- **Depth**: 64 elements (burst length: 80).  
- **Data Width**: 8 bits.  
- **Key Features**:
  - Gray-code based read/write pointers
  - Dual-flop synchronizers to prevent metastability
  - Status flags: full, empty, almost full, almost empty

## Files
- `async_fifo.v` – Top-level FIFO  
- `fifo_mem.v` – Dual-port memory  
- `wr_ptr_full_logic.v` – Write pointer & full logic  
- `rd_ptr_empty_logic.v` – Read pointer & empty logic  
- `w_2_r_sync.v`, `r_2_w_sync.v` – Cross-domain synchronizers  
- `async_fifo_tb.v` – Testbench  
