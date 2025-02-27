`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2025 11:13:34 AM
// Design Name: 
// Module Name: fp32_add
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fp32_add (
    input  [31:0] a,  // FP32 input A
    input  [31:0] b,  // FP32 input B
    input sub,
    output  [31:0] o   // FP32 output (A + B)
);
wire out_valid;
add_sub add (
  1'b1,
  a,
  1'b1,
  b,
  1'b1,
  {{7{1'b0}},sub},
  out_valid,
  o
);

endmodule