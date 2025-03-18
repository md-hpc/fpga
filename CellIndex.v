`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2025 11:28:51 AM
// Design Name: 
// Module Name: CellIndex
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

// CUTOFF is 2.5
module CellIndex #(parameter L = 32'h40f00000, parameter CUTOFF = 32'h40200000, parameter UNIVERSE_SIZE = 32'h40400000, parameter DT = 32'h33d6bf95)(
    input wire [(32*3):0] vi,
    input wire [(32*3):0] pi,
    output [32:0] cIndex,
    output[(32*3):0] newp
    );
    
    wire [32:0] add_a;
    wire [32:0] mod_a;
    wire [32:0] div_a;
    wire [32:0] modd_a;
    
    wire [32:0] add_b;
    wire [32:0] mod_b;
    wire [32:0] div_b;
    wire [32:0] modd_b;
    wire [32:0] mult_b;
    
    wire [32:0] add_c;
    wire [32:0] mod_c;
    wire [32:0] div_c;
    wire [32:0] modd_c;
    wire [32:0] mult_c;
    wire [32:0] multt_c;
    
    wire [32:0] add_xy;
    
    wire [31:0] temp_out;
    wire [31:0] shifted_mantissa;
    
    wire[31:0] dV_a;
    wire[31:0] dV_b;
    wire[31:0] dV_c;
    // x axis
    fp32_mul dVa (
        .a(vi[0+:32]),
        .b(DT[0+:32]),
        .o(dV_a)
    );
    fp32_mul dVb (
        .a(vi[32+:32]),
        .b(DT[0+:32]),
        .o(dV_b)
    );
    fp32_mul dVc (
        .a(vi[64+:32]),
        .b(DT[0+:32]),
        .o(dV_c)
    );
    
    fp32_add adder_a (
        .a(pi[0+:32]),
        .b(dV_a),
        .o(add_a[0+:32]),
        .sub(0)
    );
    fp32_mod modulo_a(.a(add_a[0+:32]),.b(L),.o(mod_a[0+:32]));
    fp32_div division_a(.a(mod_a[0+:32]),.b(CUTOFF),.o(div_a[0+:32]));
    fp32_mod moddulo_a(.a(div_a[0+:32]),.b(UNIVERSE_SIZE),.o(modd_a[0+:32]));
    
    
    // y axis
    fp32_add adder_b (
        .a(pi[32+:32]),
        .b(dV_b),
        .o(add_b[0+:32]),
        .sub(0)
    );
    fp32_mod modulo_b(.a(add_b[0+:32]),.b(L),.o(mod_b[0+:32]));
    fp32_div division_b(.a(mod_b[0+:32]),.b(CUTOFF),.o(div_b[0+:32]));
    fp32_mod moddulo_b(.a(div_b[0+:32]),.b(UNIVERSE_SIZE),.o(modd_b[0+:32]));
    fp32_mul mul_b (
        .a(modd_b[0+:32]),
        .b(UNIVERSE_SIZE),
        .o(mult_b[0+:32])
    );
    // z axis
    fp32_add adder_c (
        .a(pi[64+:32]),
        .b(dV_c),
        .o(add_c[0+:32]),
        .sub(0)
    );
    fp32_mod modulo_c(.a(add_c[0+:32]),.b(L),.o(mod_c[0+:32]));
    fp32_div division_c(.a(mod_c[0+:32]),.b(CUTOFF),.o(div_c[0+:32]));
    fp32_mod moddulo_c(.a(div_c[0+:32]),.b(UNIVERSE_SIZE),.o(modd_c[0+:32]));
    
    
    wire modda_valid;
    wire [31:0] _probe_a;
    wire [31:0] probe_a;
    wire moddb_valid;
    wire [31:0] _probe_b;
    wire [31:0] probe_b;
    wire moddc_valid;
    wire [31:0] _probe_c;
    wire [31:0] probe_c;
    
    
    float_to_int inta (
  1'b1,
  modd_a[0+:32],
  modda_valid,
  _probe_a
);

float_to_int intb (
  1'b1,
  modd_b[0+:32],
  moddb_valid,
  _probe_b
);

float_to_int intc (
  1'b1,
  modd_c[0+:32],
  moddc_valid,
  _probe_c
);
    
    assign probe_a = (modd_a[0+:32] == {32{1'b0}})? 0 : _probe_a - 1;
    assign probe_b = (modd_b[0+:32] == {32{1'b0}})? 0 : _probe_b - 1;
    assign probe_c = (modd_c[0+:32] == {32{1'b0}})? 0 : _probe_c - 1;
    
    
    fp32_mul mul_c (
        .a(probe_a),
        .b(UNIVERSE_SIZE),
        .o(mult_c[0+:32])
    );
    
    
    fp32_mul mull_c (
        .a(mult_c[0+:32]),
        .b(UNIVERSE_SIZE),
        .o(multt_c[0+:32])
    );
    
    
    
    
    fp32_add adder_xy (
        .a(probe_b),
        .b(mult_b[0+:32]),
        .o(add_xy[0+:32]),
        .sub(0)
    );
    fp32_add adder_xyz (
        .a(probe_c),
        .b(multt_c[0+:32]),
        .o(temp_out[0+:32]),
        .sub(0)
    );
    
    assign cIndex[0+:32] = probe_a%3 + (probe_b%3)*3+ (probe_c%3)*9;
    assign cIndex[32] = pi[96] | vi[96];
    assign shifted_mantissa = {1'b1, temp_out[22:0]} << (temp_out[30:23] - 127);
    //assign cIndex = {{24{1'b0}},shifted_mantissa[30:23]};
    assign newp[0+:32] = mod_a[0+:32]; 
    assign newp[32+:32] = mod_b[0+:32];
    assign newp[64+:32] = mod_c[0+:32];
    assign newp[96] = pi[96] | vi[96];
    // NEWCELL = ((pi[7:0]+ vi) % L)/CUTOFF)%UNIVERSE_SIZE) + ((pi[15:8]+ vi) % L)/CUTOFF)%UNIVERSE_SIZE)*UNIVERSE_SIZE + ((pi[23:16]+ vi) % L)/CUTOFF)%UNIVERSE_SIZE) * UNIVERSE_SIZE * UNIVERSE_SIZE
endmodule
