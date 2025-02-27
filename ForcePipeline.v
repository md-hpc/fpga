`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 01:22:11 PM
// Design Name: 
// Module Name: ForcePipeline
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


module ForcePipeline(
    input clk,
    input reset,
    input [193:0] in, //two velocities are in the input:
    input done,
    output reg [96*2:0] out
    //output reg [96:0] reference,
    //output reg [96:0] neighbor
    );
    
    wire [95:0] lj_force;
    LJ lj(in[0+:96],in[97+:96],lj_force);
    
    always @(posedge clk, posedge reset) begin
        if(reset || in[193] == 1) begin
            out[96*2] <= 1;
        end else begin
            out[0+:95] <= lj_force;
            out[96+:31] <= lj_force[0+:31];
            out[127] <= ~lj_force[31];
            out[128+:31] <= lj_force[32+:31];
            out[159] <= lj_force[63];
            
            out[160+:31] <= lj_force[64+:31];
            out[191] <= lj_force[95];
            out[192] <= 0;
    
        end
    end
    
    
    
    
endmodule
