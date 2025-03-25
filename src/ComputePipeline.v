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
    input fast_clk,
    input reset,
    input [113:0] reference,
    input[(114)*14 - 1:0] neighbors,
    output done,
    output [113:0] neighbor_out,
    output [113:0] reference_out
    //output  [96:0] reference,
    //output  [96:0] neighbor
    );
    
    integer iter;
    genvar i;
    reg [3:0] counter;
    wire [3:0] indexor;
    wire  [226:0] filter_bank_out;
    wire  [226:0] pair_queue_out;
    wire  [226:0] force_pipeline_out;
    wire pq_empty;
    wire [113:0] _reference;
    reg [113:0] _reference_buff;
    
    reg [(114)*14 - 1:0] neighbor_buff;
    wire _done;
    assign done = _done;
    reg null_pf;
    wire and_pf;
    assign indexor = counter <14 ? counter: 0;
    //assign and_acc_pf[0] = filter_bank_out[192];
    assign and_pf = null_pf & filter_bank_out[226];
    
    ParticleFilter pf(.fast_clk(fast_clk),.reset(reset),.neighbor({neighbor_buff[indexor*114+105+:9],neighbor_buff[indexor*114+:97]}),.neighbor_cell(neighbor_buff[(indexor*114 + 97)+:8]),.reference({_reference_buff[113:105],_reference_buff[96:0]}),.reference_cell(_reference_buff[104:97]),.o(filter_bank_out));
    /*
    generate
        for(i = 0; i < 14; i=i+1) begin
         //ParticleFilter pf(.neighbor(neighbors[i*97+:97]),.neighbor_cell(neighbors[(i*105 + 97)+:8]),.reference(_reference[96:0]),.reference_cell(_reference[104:97]),.o(filter_bank_out[193*i+:193]));
        end
        for(i = 1; i < 14; i=i+1) begin
            assign and_acc_pf[i] = and_acc_pf[i-1] &  filter_bank_out[193*i+192];
        end
    endgenerate
    */
    PairQueue pq(.clk(fast_clk),.reset(reset),.in(filter_bank_out),.out(pair_queue_out),.qempty(pq_empty));
    ForcePipeline fp(.clk(clk),.reset(reset),.in(pair_queue_out),.out(force_pipeline_out),.done(force_pipeline_done));
    PipelineReader pr(.clk(clk),.reset(reset),.in(force_pipeline_out),.neighbor(neighbor_out),.reference(reference_out),.done(_done));
    Noop ref(.i(reference),.o(_reference));
    
    assign _done = read_controller_done & and_pf & pair_queue_out[226] & force_pipeline_done;
    
    
    always @(posedge fast_clk) begin
        if(reset) begin
            counter <= 4'd15;
            null_pf <= 1;
            _reference_buff <= reference;
            for(iter = 0; iter < 14; iter = iter + 1) begin
                neighbor_buff[iter*114+:114] = neighbors[iter*114+:114];
            end
        end else begin
            if(counter == 15) begin
                counter <= 0;
                null_pf <= 1;
                _reference_buff <= reference;
                for(iter = 0; iter < 14; iter = iter + 1) begin
                    if(neighbors[iter*114+96] != 1) begin
                        neighbor_buff[iter*114+:114] = neighbors[iter*114+:114];
                    end
                end
            end else begin
                null_pf <= and_pf;
                counter <= counter + 1;
            end
            
            
        end
    end
endmodule
