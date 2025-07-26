`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Varun Pateliya
// 
// Design Name: tb_sync_fifo
// Module Name: tb_sync_fifo
// Project Name: tb_sync_fifo_v1
// Tool Versions: Vivado 2018.2
// Description: testbench for sync_fifo
// Revision:    Revision 0.01
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_sync_fifo;

  parameter WORD_SIZE = 8;                      // word size for FIFO and data mem
  parameter DEPTH = 16;                         // FIFO depth
  parameter TIMEOUT_LIMIT = 128;               // how long to wait for write/read
  parameter DATA_MEM_DEPTH = 256;               // data memory size
  parameter ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);// bit count to indicate data mem

  // input signals
  reg clk;                                      // system clock
  reg rst_n;                                    // Active-low reset
  reg wr_en;                                    // write enable signal
  reg rd_en;                                    // read enable signal
  reg [WORD_SIZE- 1: 0]in_data;                 // input data bus

  // output signals
  wire full;                                    // FIFO full flag
  wire empty;                                   // FIFO empty flag
  wire [WORD_SIZE- 1: 0] out_data;              // output data bus
  wire valid;                                   // data valid flag

  // FIFO instantiation  
  sync_fifo #(  .DATA_WIDTH(WORD_SIZE),
                .DEPTH(DEPTH)
             ) FIFO (
                .clk(clk), 
                .rst_n(rst_n), 
                .wr_en(wr_en), 
                .rd_en(rd_en), 
                .data_in(in_data), 
                .full(full), 
                .empty(empty), 
                .data_out(out_data),
                .valid(valid)
             );
  
  // testbench memory
  reg [WORD_SIZE - 1: 0] data_mem [0 : DATA_MEM_DEPTH - 1];
  
  // clock generation
  always #5 clk = ~clk;

  // initialize data memory
  integer k;
  initial
    for(k = 0; k < 256; k = k + 1) begin
      data_mem [k] = $random;
    end
  
  // write task
  integer i, timeout_w;
  task write(input [ADDR_WIDTH - 1 :0] data_start_add, input [ADDR_WIDTH - 1:0] data_end_add);
  begin
    for(i = data_start_add, timeout_w = TIMEOUT_LIMIT; (i <= data_end_add) && rst_n && timeout_w; )begin
      @(posedge clk);
      if (!full) begin
        wr_en = 1;
        in_data = data_mem[i];
        i = i + 1;
        timeout_w = TIMEOUT_LIMIT;
      end
      else begin 
        wr_en = 0;
        $display ("!!!!!  FIFO is full  !!!!!");
        timeout_w = timeout_w - 1;
       end
    end
    #10 wr_en = 0;
    if (timeout_w == 0) $display("ERROR: Write timeout occurred");
  end
  endtask

  // read task with verification
  integer j, timeout_r;
  task read(input [ADDR_WIDTH - 1 : 0] SIZE, input [ADDR_WIDTH - 1 : 0] start_mem_loc);
  begin
    for(j = 0, timeout_r = TIMEOUT_LIMIT; (j < SIZE) && rst_n && timeout_r;) begin
      @(posedge clk);
      if (!empty)begin
        rd_en = 1;
        end
      else begin
        rd_en = 0;
        $display("!!!!! FIFO is Empty  !!!!!");
        timeout_r = timeout_r - 1;
      end
      if (valid) begin
        if (out_data == data_mem[start_mem_loc + j]) begin
          $display("%0t data matched    | output data = %0d, expected data = %0d",
                    $time, out_data, data_mem[start_mem_loc + j]);
        end
        else begin
          $display("%0t data mismatched | output data = %0d, expected data = %0d",
                    $time, out_data, data_mem[start_mem_loc +j]);
        end
        j = j + 1;
        timeout_r = TIMEOUT_LIMIT;
      end
    end
    rd_en = 0;
    if(timeout_r == 0) $display("ERROR: Read timeout occurred");
  end
  endtask
  
  // initial block to control test sequence
  initial begin
    clk = 0;
    rst_n = 0;
    wr_en = 0;
    rd_en = 0;
    in_data = 0;
    #15 rst_n = 1;
    

    #2000 $finish;
  end
  
  initial #35 write(3, 30);     // write 28 values from index 3 to 30
  initial begin
    #55 read(3, 3);             // read first 3 values offset is 3
    #155 read(25, 6);           // read remaining 25 values, starting with offset 6
  end
endmodule