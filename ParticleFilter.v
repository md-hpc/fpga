`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 03:24:17 PM
// Design Name: 
// Module Name: ParticleFilter
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


module ParticleFilter(
    input [96:0] reference,
    input [96:0] neighbor,
    input [7:0] reference_cell,
    input [7:0] neighbor_cell,
    output [96*2:0] o
    );
    
    wire n3l_w;
    wire[95:0] mod;
    wire[31:0] r;
    
    wire less;
    assign o = (reference[96] == 1 || neighbor[96] == 1 || (neighbor_cell == reference_cell && ~n3l_w) || reference == neighbor || ~less )?{1'b1,{192{1'b0}}} : {1'b0,reference[0+:96],neighbor[0+:96]};
    
    n3l n3l_module(neighbor[0+:96],reference[0+:96],n3l_w);
    
    modr m(reference,neighbor,mod);
    Norm norm(mod,r);
    
    
    fp32_lessthan lessthan(r,32'h40c80000,less);
    
    
endmodule
