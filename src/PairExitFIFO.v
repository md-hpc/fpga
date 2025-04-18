`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2025 04:47:24 PM
// Design Name: 
// Module Name: PairExitFIFO
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


module PairExitFIFO(
input  clk,
    input  reset,
    input  [226:0] in,
    output [191:0] out,
    output qempty,
    input read_ctrl
    );
    genvar i;
    reg emp;
    reg [3:0] counter;
    
    wire [226:0] im_out;
    //wire [193:0] inputs [13:0];
    reg delayed_emp;
    
    wire q_empty, wr_en, rd_en, q_full;
    
    wire [226:0] data_in;
    /*
    generate
        for(i = 0; i < 14; i = i + 1) begin
            assign inputs[i] = in[194*i+:194];
        end  
    endgenerate
    */
    reg host_read;
    wire host_en = (read_ctrl == 1'b1 && host_read == 1'b0)? 1'b1 : 1'b0;
    assign qempty = emp;
    assign data_in = in;
    assign wr_en = (counter < 14) && ~(in[194] & in[195]);
    assign rd_en = host_en && counter == 15;
    assign out = (emp)? {192{1'b0}}:im_out[0+:191];
    PQFIFO pq(.empty(q_empty),.srst(reset),.clk(clk),.din(in),.wr_en(wr_en),.full(q_full),.rd_en(rd_en),.dout(im_out));
    
    always @(posedge clk) begin
        if(reset) begin
            counter <= 4'd15;
            emp <= q_empty;
            delayed_emp <= 1;
            host_read <= 0;
        end else begin
            host_read <= read_ctrl;
            if(counter == 15) begin
                counter <= 0;
                emp <= q_empty;
                if(delayed_emp == 1) begin
                    delayed_emp <= q_empty;
                end else begin
                    delayed_emp <= emp;
                end
            end else begin
                counter <= counter + 1;
            end
            
        end
    end
endmodule
