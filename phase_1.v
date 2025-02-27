`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2025 01:54:20 PM
// Design Name: 
// Module Name: phase_1
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


module phase_1 #(parameter N_CELL = 27)(
    input clk,
    input reset,

    output CTL_DONE,
    output CTL_DOUBLE_BUFFER,
    
    output [(N_CELL*32)-1:0] oaddr,
    input [(N_CELL*97)-1:0] r_v_caches,
    input [(N_CELL*97)-1:0] r_p_caches,
    output [32*N_CELL:0] iaddr,
    output [(N_CELL*97)-1:0] w_v_caches,
    output[(N_CELL)-1:0] wr_en
    );
    
    wire prc_done;
    
    reg  [32*5:0]p_ring_regs[N_CELL-1:0];
    wire  [32*5:0]p_ring_next[N_CELL-1:0];
    wire [31:0] p_ring_addrs[N_CELL-1:0];
    
    wire [32*5:0]p_ring_reference[N_CELL-1:0];
    wire [(105)*14 - 1:0]p_ring_neighbors[N_CELL-1:0];
    
    wire [32*5:0] pipeline_reference_out [N_CELL-1:0];
    wire [32*5:0] pipeline_neighbor_out [N_CELL-1:0];
    wire [N_CELL-1:0] pipeline_done;
    //reg [13:0] p_ring_addrs;
    
    reg [32*5:0] v_ring_regs [N_CELL-1:0];
    wire  [32*5:0]v_ring_next[N_CELL-1:0];
    wire  [32*3:0]fragment_out[N_CELL-1:0];
    wire  [32:0] v_ring_addr[N_CELL-1:0];
    wire [N_CELL-1:0]v_rempty;
    
    reg finished_batch;
    reg finished_all;
    
    
    wire [1:0] dispatch;
    
    wire [N_CELL*2:0] done_acc;
    
    wire [N_CELL-1:0] done_batch;
    wire [N_CELL-1:0] done_all;
    wire [N_CELL-1:0] in_flight;
    
    assign done_acc[0] = prc_done;
    assign CTL_DONE = done_acc[N_CELL*2];
    integer iter;
    genvar i;
    generate
        for(i = 0; i < N_CELL; i=i+1) begin
         ComputePipeline cp(.clk(clk),.reset(reset),.reference(p_ring_reference[i]),.neighbors(p_ring_neighbors[i]),.neighbor_out(pipeline_neighbor_out[i]),.reference_out(pipeline_reference_out[i]),.done(pipeline_done[i]),.read_controller_done(prc_done));
         VelocityRingNode vn(.clk(clk),.reset(reset),.Cell(i),.neighbor_cell(pipeline_neighbor_out[i][129+:32]),.neighbor(pipeline_neighbor_out[i][128:0]),.reference(pipeline_reference_out[i][128:0]),.reference_cell(pipeline_reference_out[i][129+:32]),.next(v_ring_next[i][128:0]),.next_cell(v_ring_next[i][129+:32]),.prev(v_ring_regs[(i+N_CELL-1)%N_CELL][128:0]),.prev_cell(v_ring_regs[(i+N_CELL-1)%N_CELL][129+:32]),.fragment_out(fragment_out[i]),.rempty(v_rempty[i]),.addr(iaddr[32*i+:32]));
         PositionRingNode pn(.clk(clk),.reset(reset),.Cell(i),.dispatch(dispatch),.next(p_ring_next[i][128:0]),.next_cell(p_ring_next[i][129+:32]),.prev(p_ring_regs[(i+N_CELL-1)%N_CELL][128:0]),.prev_cell(p_ring_regs[(i+N_CELL-1)%N_CELL][129+:32]),.reference(p_ring_reference[i]),.neighbors(p_ring_neighbors[i]),.double_buffer(CTL_DOUBLE_BUFFER),.done_batch(done_batch),.done_all(done_all),.in_flight(in_flight),.bram_in(r_p_caches[i*97+:97]),.addr(oaddr[32*i+:32]));
         Adder adder(.a(fragment_out[i]),.b(r_v_caches[97*i+:97]),.en(wr_en[i]),.o(w_v_caches[97*i+:97]));
         assign done_acc[i+1] = done_acc[i] & pipeline_done[i];
         assign done_acc[i+N_CELL+1] = done_acc[i+N_CELL] & v_rempty;
        end
    endgenerate
    PositionReadController prc(.clk(clk),.reset(reset),.finished_batch(finished_batch),.finished_all(finished_all),.in_flight(in_flight),.dispatch(dispatch),.done(prc_done));
    
    always @ (posedge clk, posedge reset) begin
    if(reset) begin
            for(iter = 0; iter<N_CELL; iter = iter + 1) begin
            p_ring_regs[iter] <= {161{1'b1}};
            v_ring_regs[iter] <= {161{1'b1}};
        
        end
    end else begin    
        for(iter = 0; iter<N_CELL; iter = iter + 1) begin
            p_ring_regs[iter] <= p_ring_next[iter];
            v_ring_regs[iter] <= v_ring_next[iter];
        
        end
    end
    end
endmodule
