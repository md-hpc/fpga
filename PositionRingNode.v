`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/10/2025 09:20:44 PM
// Design Name: 
// Module Name: PositionRingNode
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


module PositionRingNode #(parameter NSIZE=14, parameter DBSIZE=256)(
    input  clk,
    input  reset,
    input  double_buffer,
    input [1:0] dispatch,
    input  [96:0] prev,
    input  [31:0] prev_cell,
    input  [96:0] bram_in,
    input [31:0] Cell,
    output reg [96:0] next,
    output reg [31:0] next_cell,
    output reg [(97*NSIZE)-1:0] neighbors,
    output reg [96:0] reference,
    output reg [31:0] addr,
    output  done_batch,
    output  done_all,
    output reg in_flight
);
    integer iter;
    reg [96:0] neighbor_buffer [NSIZE-1:0];
    reg [7:0] i;
    reg [1:0] ptype;
    reg done_batch_reg, done_all_reg;
    reg [31:0] addr_n, addr_r;

    reg [96:0] p;
    
    wire n3l_o;
    n3l_cell n3l(prev_cell,Cell,n3l_o);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            addr_n <= 0;
            addr_r <= 0;
            done_batch_reg <= 0;
            done_all_reg <= 0;
            next <= 0;
            in_flight <= 0;
            ptype <= 0;
            p <= {97{1'b1}};
        end else begin
           if(dispatch == 2'b11) begin
                addr_n <= 0;
                addr_r <= 0;
                done_batch_reg <= 0;
                done_all_reg <= 0;
                next <= 0;
                in_flight <= 0;
           end else if(dispatch == 2'b01) begin
                if(prev[96] != 1'b1) begin
               // Do Nothing since this is an error
                end else begin
                    for(iter = 0; iter < NSIZE; iter=iter+1) begin
                        neighbors[iter*97+:97] <= neighbor_buffer[iter];
                        neighbor_buffer[iter] <=  {97{1'b1}};
                        
                    end
                    reference <=  {97{1'b1}};
                    if(done_all_reg !=  1'b1) begin
                        addr <= addr_n + double_buffer*DBSIZE;
                    end else begin
                        addr <= {32{1'b1}};
                    end
                    ptype <= 1; // ptype = "n"
                    i <= 0;
                    addr_r <= 0;
                    done_batch_reg <= 0;
                    next <= {97{1'b1}};
                end
           
           end else if(ptype == 1) begin
               if(prev[96] != 1'b1) begin
                   // Do Nothing since this is an error
               end else begin
                   if(bram_in[96] == 1'b1) begin
                       done_all_reg <= 1;
                       p <= {97{1'b1}};
                       next <= {97{1'b1}};
                   end else begin
                       p <= bram_in;
                       addr_n <= addr_n + 1;
                       neighbor_buffer[i] <= p;
                       i <= i + 1;
                       next <= p;
                       next_cell <= Cell;
                   end
                   reference <= {97{1'b1}};
                   ptype <= 2;
                   addr <= addr_r;
               end
           end else if (ptype == 2) begin
                if(bram_in[96] == 1'b1) begin
                   done_batch_reg <= 1;
                   p <= {97{1'b1}};
               end else begin
                   p <= bram_in;
                   addr_r <= addr_r + 1;
               end
               reference <= p;
               ptype <= 2;
               addr <= addr  + double_buffer*DBSIZE;
               next <= {97{1'b1}};
               
               if(prev[96] != 1'b1 && prev_cell != Cell) begin
                    if(n3l_o == 1) begin
                        neighbor_buffer[i] <= prev;
                        i = i + 1;
                    end
                    next <= prev;
               
               end
    
           end
           
           if(!dispatch) begin
                for(iter = 0; iter < NSIZE; iter=iter+1) begin
                    neighbors[iter*97+:97] <= {97{1'b1}};
                end
           end
        end
    end

    assign done_batch = done_batch_reg;
    assign done_all = done_all_reg;

endmodule
