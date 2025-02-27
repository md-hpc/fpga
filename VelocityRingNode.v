`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2025 01:35:28 PM
// Design Name: 
// Module Name: VelocityRingNode
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


module VelocityRingNode #(parameter NSIZE=256, parameter DBSIZE=256)(
    input  clk,
    input  reset,
    input [31:0] Cell,
    input  [32*4:0] prev,
    input  [31:0] prev_cell,
    output [32*4:0] next,
    output [31:0] next_cell,
    output rempty,
    input [(32)*4:0] neighbor,
    input [(31):0] neighbor_cell,
    input [32*4:0] reference,
    input [31:0] reference_cell,
    output [32*3:0] fragment_out,
    output [32:0] addr
    );
    // Newer Logic
    genvar i;
    
    reg [3:0] counter;
    
    reg emp_out;
    reg emp_next;
    
    wire [159:0] inputs [2:0];
    
    
    wire q_empty_next, wr_en_next, rd_en_next, q_full_next;
    
    wire [159:0] data_in;
    wire [159:0] data_out_next;
    
    
    
    wire q_empty_out, wr_en_out, rd_en_out, q_full_out;
    
    wire [159:0] data_out_out;
    
    wire [31:0] neg_out;
    
    assign inputs[0] = {Cell, reference};
    assign inputs[1] = {neighbor_cell, neighbor};
    assign inputs[2] = {prev_cell, prev};
    
    assign {neg_out,fragment_out,addr} = (emp_out)? {{32{1'b0}},{1'b1,{95{1'b0}}},{32{1'b0}}}: data_out_out;
    assign {next_cell,next} = (emp_next) ? {{32{1'b0}},{1'b1,{95{1'b0}}},{32{1'b0}}}: data_out_next;
    assign data_in = inputs[counter];
    assign wr_en_out = (inputs[counter][32*4+:32] == Cell && counter<3 && inputs[counter][32*3]==0);
    assign wr_en_next = (inputs[counter][32*4+:32] != Cell && counter<3 && inputs[counter][32*3]==0);
    assign rd_en = counter == 3;
    VelocityQueueFIFO vq_next(.empty(q_empty_next),.srst(reset),.clk(clk),.din(data_in),.wr_en(wr_en_next),.full(q_full_next),.rd_en(rd_en_next),.dout(fata_out_next));
    VelocityQueueFIFO vq_out(.empty(q_empty_out),.srst(reset),.clk(clk),.din(data_in),.wr_en(wr_en_out),.full(q_full_out),.rd_en(rd_en_out),.dout(data_out_out));
    
    assign rempty = emp_out & emp_next;
    assign rempty = emp_out & emp_next;
    
    
    always @(posedge clk) begin
        if(reset) begin
            counter <= 0;
        end begin
            if(counter == 15) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
                emp_out <= q_empty_out;
                emp_next <= q_empty_next;
            end
            
        end
    end
    
    
    
    
    
    /*
    //integer i = 0;
    
    
    // New Logic
    
    wire ref_out_we;
    wire ref_out_re;
    wire ref_out_empty;
    wire ref_out_full;
    wire [160:0] ref_out_dout;
    wire [160:0] ref_out_din;
    
    wire nei_out_we;
    wire nei_out_re;
    wire nei_out_empty;
    wire nei_out_full;
    wire [160:0] nei_out_dout;
    wire [160:0] nei_out_din;
    
    wire prev_out_we;
    wire prev_out_re;
    wire prev_out_empty;
    wire prev_out_full;
    wire [160:0] prev_out_dout;
    wire [160:0] prev_out_din;
    
    wire ref_next_we;
    wire ref_next_re;
    wire ref_next_empty;
    wire ref_next_full;
    wire [160:0] ref_next_dout;
    wire [160:0] ref_next_din;
    
    wire nei_next_we;
    wire nei_next_re;
    wire nei_next_empty;
    wire nei_next_full;
    wire [160:0] nei_next_dout;
    wire [160:0] nei_next_din;
    
    wire prev_next_we;
    wire prev_next_re;
    wire prev_next_empty;
    wire prev_next_full;
    wire [160:0] prev_next_dout;
    wire [160:0] prev_next_din;
    
    
    VelocityQueue queue_reference_out(.clk(clk),.srst(reset),.din(ref_out_din),.dout(ref_out_dout),.wr_en(ref_out_we),.rd_en(ref_out_re),.empty(ref_out_empty),.full(ref_out_full));
    VelocityQueue queue_neighbor_out(.clk(clk),.srst(reset),.din(prev_out_din),.dout(prev_out_dout),.wr_en(prev_out_we),.rd_en(prev_out_re),.empty(prev_out_empty),.full(prev_out_full));
    VelocityQueue queue_prev_out(.clk(clk),.srst(reset),.din(nei_out_din),.dout(nei_out_dout),.wr_en(nei_out_we),.rd_en(nei_out_re),.empty(nei_out_empty),.full(nei_out_full));
   
    VelocityQueue queue_reference_next(.clk(clk),.srst(reset),.din(ref_next_din),.dout(ref_next_dout),.wr_en(ref_next_we),.rd_en(ref_next_re),.empty(ref_next_empty),.full(ref_next_full));
    VelocityQueue queue_neighbor_next(.clk(clk),.srst(reset),.din(prev_next_din),.dout(prev_next_dout),.wr_en(prev_next_we),.rd_en(prev_next_re),.empty(prev_next_empty),.full(prev_next_full));
    VelocityQueue queue_prev_next(.clk(clk),.srst(reset),.din(nei_next_din),.dout(nei_next_dout),.wr_en(nei_next_we),.rd_en(nei_next_re),.empty(nei_next_empty),.full(nei_next_full));
    
    assign ref_out_we = (reference[96] != 1 && reference_cell == Cell)?1:0;
    assign ref_next_we = (reference[96] != 1 && reference_cell != Cell)?1:0;
    assign prev_out_we = (prev[96] != 1 && prev_cell == Cell)?1:0;
    assign prev_next_we = (prev[96] != 1 && prev_cell != Cell)?1:0;
    assign nei_out_we = (neighbor[96] != 1 && neighbor_cell == Cell)?1:0;
    assign nei_next_we = (neighbor[96] != 1 && neighbor_cell != Cell)?1:0;
    
    assign ref_out_din = {reference,reference_cell};
    assign ref_next_din = {reference,reference_cell};
    assign prev_out_din = {prev,prev_cell};
    assign prev_next_din = {prev,prev_cell};
    assign nei_out_din = {neighbor,neighbor_cell};
    assign nei_next_din = {neighbor,neighbor_cell};
    
    assign ref_out_re = (ref_out_empty == 0)? 1:0;
    assign nei_out_re = (ref_out_empty == 1 && nei_out_empty == 0)? 1:0;
    assign prev_out_re = (ref_out_empty == 1 && nei_out_empty == 1 && prev_out_empty == 0)? 1:0;
    assign ref_next_re = (ref_next_empty == 0)? 1:0;
    assign nei_next_re = (ref_next_empty == 1 && nei_next_empty == 0)? 1:0;
    assign prev_next_re = (ref_next_empty == 1 && nei_next_empty == 1 && prev_next_empty == 0)? 1:0;
    
    assign rempty = (ref_next_empty & ref_out_empty & nei_next_empty & nei_out_empty & prev_next_empty & prev_out_empty); 
    
    assign fragment_out = (ref_out_empty == 0)? ref_out_dout[32+:97]:
                           (nei_out_empty == 0)?nei_out_dout[32+:97]:
                           (prev_out_empty == 0)?prev_out_dout[32+:97]:{129{1'b1}};
    
    assign addr = (ref_out_empty == 0)? {1'b0,ref_out_dout[129+:32]}:
                           (nei_out_empty == 0)?{1'b0,nei_out_dout[129+:32]}:
                           (prev_out_empty == 0)?{1'b0,prev_out_dout[129+:32]}:{129{1'b1}};
   assign next = (ref_next_empty == 0)? ref_next_dout[32+:129]:
                           (nei_next_empty == 0)?nei_next_dout[32+:129]:
                           (prev_next_empty == 0)?prev_next_dout[32+:129]:{129{1'b1}};
   assign next_cell = (ref_next_empty == 0)? ref_next_dout[0+:32]:
                           (nei_next_empty == 0)?nei_next_dout[0+:32]:
                           (prev_next_empty == 0)?prev_next_dout[0+:32]:{32{1'b0}};
     
    */                       
    // New Logic End
    
    /*
    reg  [32*3:0] queue_out [32:0];
    reg [32*3:0] queue_next [32:0];
    
    reg [7:0] out_start;
    reg [7:0] next_start;
    
    wire [2:0] indexer_out;
    wire [2:0] indexer_next;
    
    wire [7:0] first_index_out;
    wire [7:0] second_index_out;
    wire [7:0] third_index_out;
    
    wire [7:0] first_index_next;
    wire [7:0] second_index_next;
    wire [7:0] third_index_next;
    
    assign indexer_out[0] = (reference[96] != 1 && reference_cell == Cell)?1:0;
    assign indexer_out[1] = (neighbor[96] != 1 && neighbor_cell == Cell)?1:0;
    assign indexer_out[2] = (prev[96] != 1 && prev_cell == Cell)?1:0;
    
    assign indexer_next[0] = (reference[96] != 1 && reference_cell != Cell)?1:0;
    assign indexer_next[1] = (neighbor[96] != 1 && neighbor_cell != Cell)?1:0;
    assign indexer_next[2] = (prev[96] != 1 && prev_cell != Cell)?1:0;
    
    assign first_index_out = out_start + indexer_out[0];
    assign second_index_out = first_index_out + indexer_out[1];
    assign third_index_out = second_index_out + indexer_out[2];
    
    assign first_index_next = next_start + indexer_next[0];
    assign second_index_next = first_index_next + indexer_next[1];
    assign third_index_next = second_index_next + indexer_next[2];
    
    assign rempty = (third_index_out == 0 && third_index_next == 0);
    
    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            for( i = 0; i < 256; i=i+1) begin
                queue_out[i][96] <= 1;
                queue_next[i][96] <= 1;
            end
            out_start <= 0;
            next_start <= 0;
        end else begin
            
            
            if(prev[96] != 1 && prev_cell == Cell) begin
                //queue_out[third_index_out - 1] = prev;
                fragment_out <= prev;
                // and addr too!
            end else if(prev[96] != 1 && prev_cell != Cell) begin
                //queue_next[third_index_next - 1] = prev;
                next <= prev;
            end
            
            if(neighbor[96] != 1 && neighbor_cell == Cell) begin
                if(prev[96] == 1) begin
                    fragment_out <= neighbor;
                    // and addr too!
                end else begin
                    queue_out[second_index_out - 1] = neighbor;
                end
            end else if(neighbor[96] != 1 && neighbor_cell != Cell) begin
                if(prev[96] == 1) begin
                    next <= neighbor;
                    // and addr too!
                end else begin
                    queue_next[second_index_next - 1] = neighbor;
                end
            end
            
            
            if(reference[96] != 1 && reference_cell == Cell) begin
                if(prev[96] == 1 && neighbor[96] == 1) begin
                    fragment_out <= reference;
                    // and addr too!
                end else begin
                    queue_out[first_index_out - 1] = reference;
                end
            end else if(reference[96] != 1 && reference_cell != Cell) begin
                if(prev[96] == 1 && neighbor[96] == 1) begin
                    next <= neighbor;
                    // and addr too!
                end else begin
                    queue_next[first_index_next - 1] = reference;
                end
            end
            
            
            
            if(third_index_out - out_start == 0) begin
            
                if(out_start > 0) begin
                    fragment_out <= queue_out[out_start - 1];
                    out_start <= out_start - 1;
                    // and addr too!
                end else begin
                    fragment_out[96] <= 1'b1;
                end
                
            end else begin
                out_start <= third_index_out;
            end
            
            if(third_index_next - next_start == 0) begin
                if(next_start > 0) begin
                    next <= queue_next[next_start - 1];
                    next_start <= next_start - 1;
                end else begin
                    next[96] <= 1'b1;
                end
            end else begin
                next_start <= third_index_next;
            end
    
        end
    end
    */
endmodule
