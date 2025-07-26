`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Varun Pateliya
// 
// Design Name: sync_fifo
// Module Name: sync_fifo
// Project Name: sync_fifo_v1
// Tool Versions: Vivado 2018.2
// Description: Design parameterized synchronous FIFO using verilog,
//              with Full/Empty flags,
//              configurable width and depth
// Revision:    Revision 0.01
// Additional Comments: for more feature we can also add almost_full and
//                      almost_empty flags
//                      we can add reset synchronizer for better performance
//////////////////////////////////////////////////////////////////////////////////

module sync_fifo #( parameter DATA_WIDTH = 16,              // word size
                    parameter DEPTH = 32                    // memory size
                 )( // output signals
                    output full,                            // FIFO full flag
                    output empty,                           // FIFO empty flag
                    output reg [DATA_WIDTH - 1: 0] data_out,// output data bus
                    output reg valid,                       // valid flag
                    // input signals
                    input clk,                              // system clock
                    input rst_n,                            // active-low reset
                    input wr_en,                            // write enable signal
                    input rd_en,                            // read enable signal
                    input [DATA_WIDTH - 1: 0] data_in       // input data bus
                    );
  
  // calculate pointer size
  localparam PTR_SIZE = $clog2(DEPTH);
  
  // [PTR_SIZE - 1 : 0] these bits are to point memory location
  // extra MSB bit for full and empty detection  
  reg [PTR_SIZE : 0] wr_pointer;
  reg [PTR_SIZE : 0] rd_pointer;

  // FIFO memory with size : DATA_WIDTH x DEPTH
  reg [DATA_WIDTH - 1: 0] mem [0: DEPTH - 1];
  
  // FIFO is full when write and read pointers are equal in lower bits
  // but MSBs are different (indicates one complete wrap-around)
  assign full =   ((wr_pointer[PTR_SIZE-1 :0] == rd_pointer[PTR_SIZE-1 :0])
                  &&(wr_pointer[PTR_SIZE] != rd_pointer[PTR_SIZE]))
                  ? 1'b1 : 1'b0;
                  
  // FIFO is empty when write and read pointers are exactly same
  assign empty =  (wr_pointer[PTR_SIZE :0] == rd_pointer[PTR_SIZE :0])
                  ? 1'b1 : 1'b0;

  // WRITE LOGIC
  always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      wr_pointer <= 0;
    end
    else if (wr_en && !full) begin
      mem[wr_pointer[PTR_SIZE - 1 : 0]] <= data_in;
      wr_pointer <= wr_pointer + 1'b1;
    end
  end  
  
  // READ LOGIC
  always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      rd_pointer <= 0;
      data_out <= 0;
      valid <= 0;
    end
    else if (rd_en && !empty) begin
      data_out <= mem[rd_pointer[PTR_SIZE - 1 : 0]];
      rd_pointer <= rd_pointer + 1'b1;
      valid <= 1;
    end
    else valid <= 0;
  end
endmodule
