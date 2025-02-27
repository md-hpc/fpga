`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/10/2025 10:20:07 PM
// Design Name: 
// Module Name: Adder
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


module Adder (
    input  [96:0] a,
    input  [96:0] b,
    output  [96:0] o,
    output en
);
    fp32_add add_x(.a(a[0+:32]),.b(b[0+:32]),.o(o[0+:32]));
    fp32_add add_y(.a(a[32+:32]),.b(b[32+:32]),.o(o[32+:32]));
    fp32_add add_z(.a(a[64+:32]),.b(b[64+:32]),.o(o[64+:32]));
    assign o = (a[96] == 1'b1 || b == 1'b1) ? {1'b1,{96{1'b0}}} : a + b;
    assign en = (a[96] == 1'b1 || b == 1'b1) ? 1'b0 : 1'b1;
    
endmodule