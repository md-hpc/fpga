`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2025 04:41:56 PM
// Design Name: 
// Module Name: LJ_tb
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


module LJ_tb(

    );
    
    reg [95:0] reference;
    reg [95:0] neighbor;
    wire [95:0] lj_out;
    
    
    LJ lj(reference,neighbor,lj_out);
    //['4151eb85', '40a66666', '41580000']
    //['4083d70a', '400ccccd', '40600000']
    
    
//['bdbc983c', 'bcfb75a5', 'bdd18cb4']
    initial begin
    #5 
     reference[0+:32] <= 32'h4151eb85;
    reference[32+:32] <= 32'h40a66666;
    reference[64+:32] <= 32'h41580000;
    neighbor[0+:32] <= 32'h4083d70a;
    neighbor[32+:32] <= 32'h400ccccd;
    neighbor[64+:32] <= 32'h40600000;
    
    
    
    
    
    
    end
endmodule
