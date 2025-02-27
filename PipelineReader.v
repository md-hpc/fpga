`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2025 05:13:10 PM
// Design Name: 
// Module Name: PipelineReader
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


module PipelineReader(
    input clk,
    input reset,
    input [193:0] in, //two velocities are in the input:
    input done,
    output reg [96:0] reference,
    output reg [96:0] neighbor
    );
    
    reg [96:0] ref;
    reg [96:0] neigh;
    
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            ref[96] <= 1;
            neigh <= 1;
            
            reference[96] <= 1;
            neighbor[96] <= 1;
        end else begin
            if(done) begin
                if(ref[96] != 1) begin
                    reference <= ref;
                    ref[96] <= 1;
                end else begin
                    reference[96] <= 1;
                end
            
                if(neigh[96] != 1) begin
                    neighbor <= neigh;
                    neigh[96] <= 1;
                end else begin
                    neighbor[96] <= 1;
                end
                
                
                if(in[96] != 1 && in[193] != 1) begin
                    if(ref[96] == 1) begin
                        ref <= in[96:0];
                        reference[96] <= 1;
                    end else if (ref != in[96:0]) begin
                        reference <= ref;
                        ref <= in[96:0];
                    end else begin
                        ref[95:0] <=ref[95:0] + in[95:0];
                        reference[96] <= 1;
                    end
                
                    if(neigh[96] == 1) begin
                        neigh <= in[193:97];
                        neighbor[96] <= 1;
                    end else if (neigh != in[193:97]) begin
                        neighbor <= neigh;
                        neigh <= in[193:97];
                    end else begin
                        neigh[95:0] <=neigh[95:0] + in[193:97];
                        neighbor[96] <= 1;
                    end
                
                end
                
            end
        end
    end
    
    
    
endmodule
