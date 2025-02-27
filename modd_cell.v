`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/22/2025 04:11:54 PM
// Design Name: 
// Module Name: modd_cell
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


module modd_cell(
    input [31:0] a,
    input [31:0] b,
    input [31:0] M,
    output [31:0] o,
    output [31:0] o_abs
    );
    //opts = [(b-M)-a, b-a, (b+M)-a]
    
    wire [31:0] opta;
    wire [31:0] opta_abs;
    wire [31:0] optb;
    wire [31:0] optb_abs;
    wire [31:0] optc;
    wire [31:0] optc_im;
    wire [31:0] optc_abs;
    
    wire [31:0] comp_im;
    wire [31:0] comp_im_abs;
    
    
    assign opta = optb - M;
    assign opta_abs = (opta[31] == 0)? opta: ~opta+1;
    assign optb_abs = (optb[31] == 0)? optb: ~optb+1;
    assign optc_abs = (optc[31] == 0)? optc: ~optc+1;
    
    
    assign optb = b - a;
    
    assign optc = optb + M;
    
    assign comp_im = (opta_abs < optb_abs)? opta : optb;
    assign comp_im_abs = (opta_abs < optb_abs)? opta_abs : optb_abs;
    assign o = (comp_im < optc_abs)? comp_im : optc;
    assign o_abs = (comp_im < optc_abs)? comp_im : optc_abs;
    
endmodule

