module fp32_div (
    input wire [31:0] a, // FP32 input (numerator)
    input wire [31:0] b, // FP32 input (denominator)
    output wire [31:0] o // FP32 output (result)
);


wire [31:0] n1;
wire [31:0] n2;
wire [31:0] result;
wire out_valid;
			

floating_point_0 div(
  1'b1,
  a,
  1'b1,
 b,
  out_valid,
  o
);
endmodule