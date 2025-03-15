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
    input  [105:0] prev,
    input  [7:0] prev_cell,
    input  [96:0] bram_in,
    input [31:0] Cell,
    output reg [105:0] next,
    output reg [7:0] next_cell,
    output reg [(114*NSIZE)-1:0] neighbors,
    output reg [113:0] reference,
    output  [31:0] addr,
    output  done_batch,
    output  done_all,
    output reg in_flight
);
    integer iter;
    reg [113:0] neighbor_buffer [NSIZE-1:0];
    reg [7:0] i;
    reg [1:0] ptype;
    reg done_batch_reg, done_all_reg;
    reg [31:0] addr_n, addr_r;

    wire [104:0] p;
    
    wire n3l_o;
    
    assign p = (bram_in[96] == 1'b1 || reset)? {{8{1'b0}},1'b1,{96{1'b0}}}: {Cell[0+:8],bram_in};
                       
    wire [31:0] possible_addr = reset ?  0  :
                (dispatch ==  2'b01 && done_all_reg !=  1'b1 && prev[96] == 1'b1)? addr_n + double_buffer*DBSIZE :
                (dispatch ==  2'b01 &&done_all_reg ==  1'b1 && prev[96] == 1'b1)? 0 : 
                (ptype == 1 && prev[96] == 1'b1) ? addr_r : 
                (ptype == 2 && bram_in[96] == 1'b1) ?  addr_r + double_buffer*DBSIZE :
                (ptype == 2 && bram_in[96] !=  1'b1) ? addr_r + 1  + double_buffer*DBSIZE : 0;
    assign addr = possible_addr;            
    //(reset == 0 && dispatch == 2'b01 )?:{32{1'b0}};                   
                       
    n3l_cell n3l(Cell,{{24{1'b0}},prev_cell},n3l_o);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            addr_n <= 0;
            addr_r <= 0;
            done_batch_reg <= 0;
            done_all_reg <= 0;
            next  <= {{9{1'b0}},1'b1,{96{1'b0}}};
            next_cell <= 0;
            in_flight <= 0;
            ptype <= 0;
            //addr <= 0;
            i <= 0;
            reference <=  {{17{1'b0}},1'b1,{96{1'b0}}};
            for(iter = 0; iter < NSIZE; iter=iter+1) begin
                    neighbors[iter*114+:114] <= {{17{1'b0}},1'b1,{96{1'b0}}};
                    neighbor_buffer[iter] <= {{17{1'b0}},1'b1,{96{1'b0}}};
            end
        end else begin
           if(dispatch == 2'b11) begin
                addr_n <= 0;
                addr_r <= 0;
                done_batch_reg <= 0;
                done_all_reg <= 0;
                next <= {{9{1'b0}},1'b1,{96{1'b0}}};
                next_cell <= 0;
                in_flight <= 0;
                reference <=  {{17{1'b0}},1'b1,{96{1'b0}}};
           end else if(dispatch == 2'b01) begin
                if(prev[96] != 1'b1) begin
               // Do Nothing since this is an error
                end else begin
                    reference <=  {{17{1'b0}},1'b1,{96{1'b0}}};
                    if(ptype == 2)begin
                    if(done_all_reg !=  1'b1) begin
                        //addr <= addr_n + double_buffer*DBSIZE;
                    end else begin
                        //addr <= 0;
                    end
                    end /*else if(ptype == 1) begin
                    if(done_all_reg !=  1'b1) begin
                        addr <= addr_r;
                    end else begin
                        addr <= 0;
                    end
                    end*/
                    ptype <= 1; // ptype = "n"
                    i <= 0;
                    addr_r <= 0;
                    done_batch_reg <= 0;
                    next <= {{9{1'b0}},1'b1,{96{1'b0}}};
                    next_cell <= 0;
                    in_flight <= 0;
                    for(iter = 0; iter < NSIZE; iter=iter+1) begin
                        neighbors[iter*114+:114] <=  neighbor_buffer[iter];
                        neighbor_buffer[iter] <= {{17{1'b0}},1'b1,{96{1'b0}}};
                    end
                end
           
           end else if(ptype == 1) begin
               if(prev[96] != 1'b1) begin
                   // Do Nothing since this is an error
               end else begin
                   if(bram_in[96] == 1'b1) begin
                       done_all_reg <= 1;
                       next <= {{9{1'b0}},1'b1,{96{1'b0}}};
                       next_cell <= 0;
                       in_flight <= 0;
                   end else begin
                       addr_n <= addr_n + 1;
                       neighbor_buffer[i] <= {addr_n[0+:9],Cell[0+:8],bram_in};
                       i <= i + 1;
                       next <= {addr_n,bram_in};
                       in_flight <= 1;
                       next_cell <= Cell[0+:8];
                   end
                   reference <= {{17{1'b0}},1'b1,{96{1'b0}}};
                   ptype <= 2;
                   //addr <= addr_r;
               end
           end else if (ptype == 2) begin
                if(bram_in[96] == 1'b1) begin
                   reference <= {{17{1'b0}},1'b1,{96{1'b0}}};
                   done_batch_reg <= 1;
                   //addr <= addr_r  + double_buffer*DBSIZE;
               end else begin
                   reference <= {addr_r[0+:9],Cell[0+:8],p[0+:97]};
                   addr_r <= addr_r + 1;
                   //addr <= addr_r + 1  + double_buffer*DBSIZE;
               end
               
               ptype <= 2;
               
               if(prev[96] != 1'b1 && prev_cell != Cell) begin
                    if(n3l_o == 1) begin
                         neighbor_buffer[i] <= {prev[97+:9],prev_cell,prev[0+:97]};
                        i = i + 1;
                    end
                    next <= prev;
                    next_cell <= prev_cell;
                    in_flight <= 1;
               end else begin
                    next <= {{9{1'b0}},1'b1,{96{1'b0}}};
                    next_cell <= 0;
                    in_flight <= 0;
               end
    
           end
           
           if(dispatch == 2'b00) begin
                for(iter = 0; iter < NSIZE; iter=iter+1) begin
                    neighbors[iter*114+:114] <= {{17{1'b0}},1'b1,{96{1'b0}}};
                end
           end
        end
    end

    assign done_batch = done_batch_reg;
    assign done_all = done_all_reg;

endmodule
