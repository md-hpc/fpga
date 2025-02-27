`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2025 03:24:34 PM
// Design Name: 
// Module Name: PositionUpdater
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

module PositionUpdater #(parameter DBSIZE = 256, parameter DT = 1, parameter L = 10, parameter cutoff = 1, parameter UNIVERSE = 3)(
    input wire clk,
    input wire rst,
    input wire ready,
    input wire [1:0] double_buffer,
    input wire [32:0] overwrite_addr,
    input wire [(32*3):0] vi,
    input wire [(32*3):0] pi,
    input wire [(32*3):0] nodePosIn,
    input wire [(32*3):0] nodeVelIn,
    input wire [(32*3):0] nodeCellIn,
    input wire [32:0] Cell,
    output reg [32:0] iaddr,
    output reg [(32*3):0] vo,
    output reg [(32*3):0] po,
    output reg we,
    output reg done,
    output reg block,
    output reg [(32*3):0] nodePosOut,
    output reg [(32*3):0] nodeVelOut,
    output reg [32:0] nodeCellOut
);
    wire [32:0] cIndex;
    wire [(32*3):0] newp;
    CellIndex CI(.pi(pi),.vi(vi),.cIndex(cIndex),.newp(newp));
    reg [32:0] new_addr;
    reg [(32*3):0] nodePos, nodeVel, nodeCell;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            new_addr[32] <= 1'b1;
            nodePos[96] <= 1'b1;
            nodeVel[96] <= 1'b1;
            nodeCell[32] <= 1'b1;
            done <= 0;
            block <= 0;
            iaddr[32] <= 1'b1;
            vo[96] <= 1'b1;
            po[96] <= 1'b1;
            we <= 1'b0;
            nodePosOut[96] <= 1'b1;
            nodeVelOut[96] <= 1'b1;
            nodeCellOut[32] <= 1'b1;
        end else if (!ready) begin
            new_addr[32] <= 1'b1;
            done <= 0;
            block <= 0;
            iaddr[32] <= 1'b1;
            vo[96] <= 1'b1;
            po[96] <= 1'b1;
            we <= 1'b0;
            nodePosOut[96] <= 1'b1;
            nodeVelOut[96] <= 1'b1;
            nodeCellOut[32] <= 1'b1;
        end else if (overwrite_addr[32] != 1'b1) begin
            iaddr <= overwrite_addr;
            vo[96] <= 1'b1;
            po[96] <= 1'b1;
            we <= 1'b0;
            done <= 0;
            nodePosOut[96] <= 1'b1;
            nodeVelOut[96] <= 1'b1;
            nodeCellOut[32] <= 1'b1;
            block <= 0;
        end else if (nodePos[96] != 1'b1 && nodeVel[96] != 1'b1 && nodeCell[32] != 1'b1) begin
            done <= 0;
            block <= 1;
            if (nodeCell != Cell) begin
                nodePosOut <= nodePos;
                nodeVelOut <= nodeVel;
                nodeCellOut <= nodeCell;
                we <= 1'b0;
            end else begin
                nodePosOut[96] <= 1'b1;
                nodeVelOut[96] <= 1'b1;
                nodeCellOut[32] <= 1'b1;
                po <= nodePos;
                vo <= nodeVel;
                we <= 1'b1;
            end
        end else begin
            nodePos <= nodePosIn;
            nodeVel <= nodeVelIn;
            nodeCell <= nodeCellIn;

            if (pi[96] == 1'b1 && vi[96] == 1'b1  && nodePos[96] == 1'b1  && nodeVel[96] == 1'b1  && nodeCell[32] == 1'b1 ) begin
                done <= 1;
                iaddr[32] <= 1'b1;
                po[96] <= 1'b1;
                vo[96] <= 1'b1;
                we <= 1'b0;
                block <= 0;
                nodePosOut[96] <= 1'b1;
                nodeVelOut[96] <= 1'b1;
                nodeCellOut[32] <= 1'b1;
            end else begin
                done <= 0;
                //nodeCellOut <= (pi[8:0]/CUTOFF)%UNIVERSE_SIZE;
                // Assume vi * DT = vi, since DT = 1
                // NEWCELL = ((pi[7:0]+ (vi * DT)) % L)/CUTOFF)%UNIVERSE_SIZE) + ((pi[15:8]+ (vi * DT)) % L)/CUTOFF)%UNIVERSE_SIZE)*UNIVERSE_SIZE + ((pi[23:16]+ (vi * DT)) % L)/CUTOFF)%UNIVERSE_SIZE) * UNIVERSE_SIZE * UNIVERSE_SIZE
                // NEWCELL = ((pi[7:0]+ vi) % L)/CUTOFF)%UNIVERSE_SIZE) + ((pi[15:8]+ vi) % L)/CUTOFF)%UNIVERSE_SIZE)*UNIVERSE_SIZE + ((pi[23:16]+ vi) % L)/CUTOFF)%UNIVERSE_SIZE) * UNIVERSE_SIZE * UNIVERSE_SIZE
                
                
                //Cell == NEWCELL
                if(Cell == cIndex) begin
                    po <= newp;
                    vo <= vi;
                    we <= 1'b1;
                    iaddr <= new_addr;
                    new_addr <= new_addr + 1;
                    block <=0;
                    nodePosOut[96] <= 1'b1;
                    nodeVelOut[96] <= 1'b1;
                    nodeCellOut[32] <= 1'b1;
                end else begin
                    block <= 1;
                    nodePosOut <= newp;
                    nodeVelOut <= vi;
                    nodeCellOut <= cIndex;
                    po[96] <= 1'b1;
                    vo[96] <= 1'b1;
                    iaddr[32] <= 1'b1;
                    we <= 1'b0;
                
                
                end
            end
        end
    end

endmodule
