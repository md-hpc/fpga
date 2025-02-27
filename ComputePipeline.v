`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 05:54:48 PM
// Design Name: 
// Module Name: ComputePipeline
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


module ComputePipeline(
    input read_controller_done,
    input clk,
    input reset,
    input [104:0] reference,
    input[(105)*14 - 1:0] neighbors,
    output done,
    output [96:0] neighbor_out,
    output [96:0] reference_out
    //output  [96:0] reference,
    //output  [96:0] neighbor
    );
    
    genvar i;
    
    wire  [193*14:0] filter_bank_out;
    wire  [193:0] pair_queue_out;
    wire  [193:0] force_pipeline_out;
    wire force_pipeline_done;
    wire pq_empty;
    wire [104:0] _reference;
    
    wire _done;
    assign done = _done;
    wire [13:0] and_acc_pf;
    wire and_pf;
    assign and_acc_pf[0] = filter_bank_out[192];
    assign and_pf = and_acc_pf[13];
    generate
        for(i = 0; i < 14; i=i+1) begin
         ParticleFilter pf(.neighbor(neighbors[i*97+:97]),.neighbor_cell(neighbors[(i*105 + 97)+:8]),.reference(_reference[96:0]),.reference_cell(_reference[104:97]),.o(filter_bank_out[193*i+:193]));
        end
        for(i = 1; i < 14; i=i+1) begin
            assign and_acc_pf[i] = and_acc_pf[i-1] &  filter_bank_out[193*i+192];
        end
    endgenerate
    PairQueue pq(.clk(clk),.reset(reset),.in(filter_bank_out),.out(pair_queue_out),.qempty(pq_empty));
    ForcePipeline fp(.clk(clk),.reset(reset),.in(pair_queue_out),.out(force_pipeline_out),.done(force_pipeline_done));
    PipelineReader pr(.clk(clk),.reset(reset),.in(force_pipeline_out),.neighbor(neighbor_out),.reference(reference_out),.done(_done));
    Noop ref(.i(reference),.o(_reference));
    reg [97*14:0] _neighbors;
    
    assign _done = read_controller_done & and_pf & pair_queue_out[193] & force_pipeline_out[192];
    
endmodule
