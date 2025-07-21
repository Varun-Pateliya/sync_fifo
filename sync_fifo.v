`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Varun Pateliya
// 
// Create Date: 21.07.2025 15:23:56
// Design Name: sync_fifo
// Module Name: sync_fifo
// Project Name: sync_fifo_v1
// Tool Versions: Vivado 2018.2
// Description: To practice verilog design synchronous fifo
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sync_fifo(   full, empty, data_out,                  // output signal 
                    clk, reset, wr_en, rd_en, data_in   );  // input signal
  
  parameter DATA_WIDTH = 16;                                // word size
  parameter DEPTH = 32;                                     // memory size
  
  input clk;
  input reset;
  input wr_en;
  input rd_en;
  input [DATA_WIDTH - 1: 0] data_in;
  
  output full;
  output empty;
  output reg [DATA_WIDTH - 1: 0] data_out;
  
  parameter POINTER_SIZE = $clog2(DATA_WIDTH);
  
  reg [POINTER_SIZE : 0] wr_pointer;
  reg [POINTER_SIZE : 0] rd_pointer;
  //no need to minus one becouse to check full and empty condition we need extra bit
  
  reg [DATA_WIDTH - 1: 0] mem [0: DEPTH - 1];
  
  assign full =   ((wr_pointer[POINTER_SIZE-1 :0] == rd_pointer[POINTER_SIZE-1 :0])
                  &&(wr_pointer[POINTER_SIZE] != rd_pointer[POINTER_SIZE]))
                  ? 1'b1 : 1'b0;
  assign empty =  (wr_pointer[POINTER_SIZE :0] == rd_pointer[POINTER_SIZE :0])
                  ? 1'b1 : 1'b0;
                  
  always @ (posedge clk or negedge reset) begin
    if(!reset) begin
      rd_pointer <= 0;
      wr_pointer <= 0;
    end
    else begin
      if (rd_en) begin
        data_out <= mem[rd_pointer];
        rd_pointer <= rd_pointer + 1'b1;
      end
      else if (wr_en) begin
        mem[wr_pointer] <= data_in;
        wr_pointer <= wr_pointer + 1'b1;
      end
    end
  end
endmodule
