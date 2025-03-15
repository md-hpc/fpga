`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 07:57:53 PM
// Design Name: 
// Module Name: ControlUnit
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


module simulator#(parameter N_CELL = 27, parameter N_PARTICLES = 300)(
input clk,
input fast_clk,
input reset,

input data_in_ready,
input [255:0]data_in
);



wire double_buffer;

reg phase1_done;
reg phase3_done;
reg mem_set;
wire phase1_done_w;
wire [N_CELL:0] phase3_done_w_out;
wire [N_CELL:0] phase3_done_w_acc;
wire [N_CELL:0] phase3_done_w;

wire phase3_ready;
wire phase1_ready;

wire [N_CELL-1:0] p1_wea;
wire [32*N_CELL-1:0] p1_addra;
wire [32*N_CELL-1:0] p1_addrb;
wire [97*N_CELL-1:0] p1_v_dina;
wire [97*N_CELL-1:0] p1_v_doutb;
wire [32*N_CELL-1:0] p1_v_iaddr;


wire [97*N_CELL-1:0] p1_p_doutb;


wire [N_CELL-1:0] p3_wea;
wire [32*N_CELL-1:0] p3_addra;
wire [32*N_CELL-1:0] p3_addrb;

wire [97*N_CELL-1:0] p3_v_dina;
wire [97*N_CELL-1:0] p3_v_doutb;

wire [97*N_CELL-1:0] p3_p_dina;
wire [97*N_CELL-1:0] p3_p_doutb;

wire [N_CELL-1:0] v_wea;
wire [8:0] v_addra[N_CELL-1:0];
wire [96:0] v_dina[N_CELL-1:0];
wire [8:0] v_addrb[N_CELL-1:0];
wire [96:0] v_doutb[N_CELL-1:0];

wire [N_CELL-1:0] p_wea;
wire [8:0] p_addra[N_CELL-1:0];
wire [96:0] p_dina[N_CELL-1:0];
wire [8:0] p_addrb[N_CELL-1:0];
wire [96:0] p_doutb[N_CELL-1:0];



ControlUnit CU(.clk(clk),.reset(reset),.phase1_done(phase1_done),.phase3_done(phase3_done),.mem_set(mem_set),.double_buffer(double_buffer),.phase3_ready(phase3_ready),.phase1_ready(phase1_ready));
 
phase_1 phase1(.clk(clk),.fast_clk(fast_clk),.reset(reset | (~mem_set)),.CTL_DONE(phase1_done_w),.CTL_DOUBLE_BUFFER(double_buffer),.CTL_READY(phase1_ready),.oaddr(p1_addra),.iaddr(p1_addrb),.r_p_caches(p1_p_doutb),.r_v_caches(p1_v_doutb),.w_v_caches(p1_v_dina),.wr_en(p1_wea),.v_iaddr(p1_v_iaddr));
phase_3 phase3(.clk(clk),.reset(reset | (~mem_set)),.CTL_DONE(phase3_done_w_out),.CTL_DOUBLE_BUFFER(double_buffer),.CTL_READY(phase3_ready),.wr_en(p3_wea),.oaddr(p3_addrb),.iaddr(p3_addra),.r_p_caches(p3_p_doutb),.w_p_caches(p3_p_dina),.r_v_caches(p3_v_doutb),.w_v_caches(p3_v_dina));


reg [9:0] init_counter;


assign phase3_done_w_acc[0] = phase3_done_w_out[0];
assign phase3_done_w = phase3_done_w_acc[27];

genvar i;
generate
for(i = 0; i < N_CELL; i = i + 1) begin
    assign p_wea[i] = phase1_ready? 1'b0 : 
                      phase3_ready? p3_wea[i]: data_in_ready & data_in[192+:8] == i;
    assign p_addra[i] = phase1_ready? p1_addra[i*32+:32] : 
                      phase3_ready? p3_addra[i*32+:32] : data_in[200+:9];
    assign p_addrb[i] = phase1_ready? p1_addrb[i*32+:32] : 
                      phase3_ready? p3_addrb[i*32+:32] : 0;
    assign p_dina[i] = phase1_ready? {1'b0,data_in[0+:96]} : 
                      phase3_ready? p3_p_dina[i*97+:97] : {1'b0,data_in[0+:96]};
    //assign p_doutb[i] = phase1_ready? p1_p_doutb[i*97+:97] : 
    //                 phase3_ready? p3_p_doutb[i*97+:97] : 0;
    assign p1_p_doutb[i*97+:97] = phase1_ready? p_doutb[i] : 0;
    assign p3_p_doutb[i*97+:97] = phase3_ready? p_doutb[i] : 0;
                      
    assign v_wea[i] = phase1_ready? p1_wea[i] : 
                      phase3_ready? p3_wea[i] : data_in_ready & data_in[192+:8] == i;
    assign v_addra[i] = phase1_ready? p1_v_iaddr[i*32+:32] : 
                      phase3_ready? p3_addra[i*32+:32] : data_in[200+:9];
    assign v_addrb[i] = phase1_ready? p1_addra[i*32+:32] : 
                      phase3_ready? p3_addrb[i*32+:32] : 0;
    assign v_dina[i] = phase1_ready? p1_v_dina[i*97+:97] : 
                      phase3_ready? p3_v_dina[i*97+:97] : {1'b0,data_in[96+:96]};
    //assign v_doutb[i] = phase1_ready? p1_p_doutb[i*97+:97] : 
    //                  phase3_ready? p3_p_doutb[i*97+:97] : 0;
    assign p1_v_doutb[i*97+:97] = phase1_ready? v_doutb[i] : 0;
    assign p3_v_doutb[i*97+:97] = phase3_ready? v_doutb[i] : 0;
    BRAM PBRAM(.clka(clk),.clkb(clk),.ena(1'b1),.wea(p_wea[i]),.addra(p_addra[i]),.dina(p_dina[i]),.enb(1'b1),.addrb(p_addrb[i]),.doutb(p_doutb[i]));
    BRAM VBRAM(.clka(clk),.clkb(clk),.ena(1'b1),.wea(v_wea[i]),.addra(v_addra[i]),.dina(v_dina[i]),.enb(1'b1),.addrb(v_addrb[i]),.doutb(v_doutb[i]));
    
end
for(i = 1; i < 28; i = i + 1) begin
    assign phase3_done_w_acc[i] = phase3_done_w_acc[i-1] & phase3_done_w_out[i];
end
endgenerate



always @(posedge clk, posedge reset) begin
    if(reset) begin
        phase1_done <= 0;
        phase3_done <= 0;
        init_counter <= 0;
        mem_set <= 0;
    end else begin
        if(init_counter < N_PARTICLES+4) begin
            if(data_in_ready) begin
                init_counter = init_counter + 1;
            end
            if(init_counter == N_PARTICLES + 3) begin
                mem_set <= 1;
            end
        end else begin
            phase1_done <= phase1_done_w;
            phase3_done <= phase3_done_w;
        end
    end




end




endmodule