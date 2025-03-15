`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 01:00:56 PM
// Design Name: 
// Module Name: mem_init
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


module mem_init #(parameter N_CELL = 27)(
        input clk,
        input reset,
        input position_ready,
        input velocity_ready,
        input bram_index,
        output [8:0] address
    );
    reg [8:0] index [N_CELL-1:0];
    
    always @(posedge clk) begin
        if(reset) begin
        
        end else  begin
            
        end
    end
    
endmodule
