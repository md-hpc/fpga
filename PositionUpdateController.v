`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2025 02:51:50 PM
// Design Name: 
// Module Name: PositionUpdateController
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


module PositionUpdateController #(parameter DBSIZE = 256)(
    input ready,
    output reg done,
    input double_buffer,
    input block,
    output reg [31:0] oaddr,
    output reg [31:0] overwrite_addr,
    input clk,
    input rst
    );
    
    reg [31:0] raddr;
    
    reg [31:0] _overwrite_addr;
    
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            raddr <= 0;
            _overwrite_addr <= {32{1'b1}};
            done <= 0;
            oaddr <= {32{1'b1}};
            overwrite_addr <= 0;
        end else  if(!ready) begin
            raddr <= (double_buffer == 1) ? DBSIZE : 0;
            _overwrite_addr <= (double_buffer == 1) ? 0 : DBSIZE;
            done <= 0;
            oaddr <= {32{1'b1}};
            overwrite_addr <= {32{1'b1}};
        end else  if(raddr == ((double_buffer == 1) ? DBSIZE : 0) +DBSIZE) begin
            done <= 1;
            oaddr <= {32{1'b1}};
            overwrite_addr <= {32{1'b1}};
        end else  begin
            oaddr <= raddr;
            overwrite_addr <= _overwrite_addr;
            done <= 0;
            
            if(_overwrite_addr == {32{1'b1}} && block == 1) begin
                raddr <= raddr + 1;
            end else begin
                _overwrite_addr <= _overwrite_addr + 1;
                if (_overwrite_addr == ((double_buffer == 1) ? 0 : DBSIZE) + DBSIZE) begin
                    _overwrite_addr <= {32{1'b1}};
                    raddr <= (double_buffer == 1) ? DBSIZE : 0;
                 end
            end
        end
    end
    
    
endmodule
