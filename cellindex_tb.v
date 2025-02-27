`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2025 10:22:10 AM
// Design Name: 
// Module Name: cellindex_tb
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


module cellindex_tb(

    );
    reg[(32*3):0] vi;
    reg [(32*3):0] pi;
    wire [32:0] cIndex;
    wire [(32*3):0] new;
    
    
    CellIndex CI(.pi(pi),.vi(vi),.cIndex(cIndex),.newp(new));
    /*
    
    
        
Position 1 : 4151eb85
Position 2 : 40a66666
Position 3 : 41580000
Velocity 1 : 4089999a
Velocity 2 : 40133333
Velocity 3 : 40a9999a
[2.42 0.   3.8 ]
New Position 1 : 401ae148
New Position 2 : 00000000
New Position 3 : 40733333

*/
    initial begin
    #10
    pi[0+:32] <= 32'h4151eb85;
    pi[32+:32] <= 32'h40a66666;
    pi[64+:32] <= 32'h41580000;
    pi[96] <= 1'b0;
    vi[0+:32] <= 32'h4089999a;
    vi[32+:32] <= 32'h40133334;
    vi[64+:32] <= 32'h40a9999a;
    vi[96] <= 1'b0;
    
    end
    
    
endmodule
