module ALU_LEGv8(A, B, FS, C0, F, status);
	input [63:0] A, B;
	input [4:0]FS;
	// FS0 - b invert
	// FS1 - a invert
	// FS4:2 - op. select
	//   000 - AND
	//   001 - OR
	//   010 - ADD
	//   011 - XOR
	//   100 - shift left
	//   101 - shift right
	//   110 - none / 0
	//   111 - none / 0
	input C0;
	output [63:0]F;
	output [3:0]status;
	
	wire Z, N, C, V;
	assign status = {V, C, N, Z};
	
	wire [63:0] A_Signal, B_Signal;
	// A Mux
	assign A_Signal = FS[1] ? ~A : A;
	// B Mux
	assign B_Signal = FS[0] ? ~B : B;
	
	assign N = F[63];
	
	assign Z = (F == 64'b0) ? 1'b1 : 1'b0;
	
	assign V = ~(A_Signal[63] ^ B_Signal[63]) &  (F[63] ^ A_Signal[63]);
	
	wire [63:0]and_output, or_output, xor_output, add_output, shift_left, shift_right;
	assign and_output = A_Signal & B_Signal;
	assign or_output = A_Signal | B_Signal;
	assign xor_output = A_Signal ^ B_Signal;
	//Adder adder_inst (.S(add_output), .Cout(C), .A(A_Signal), .B(B_Signal), .Cin(C0));
	Adder adder_inst (add_output, C, A_Signal, B_Signal, C0);
	Shifter shift_inst (shift_left, shift_right, A, B[5:0]);
	
	Mux8to1Nbit main_mux (F, FS[4:2], and_output, or_output, add_output, xor_output, shift_left, shift_right, 64'b0, 64'b0);
endmodule

module Shifter(left, right, A, shift_amount);
	input [63:0] A;
	input [5:0] shift_amount;
	output [63:0] left, right;
	
	assign left = A << shift_amount;
	assign right = A >> shift_amount;
endmodule

module Adder(S, Cout, A, B, Cin);
	parameter N = 64;
	input [N-1:0] A, B;
	input Cin;
	output [N-1:0] S;
	output Cout;
	
	wire [N-1:0]carry;
	assign carry[0] = Cin;
	assign Cout = carry[N-1];
	// use generate block to instantiate 64 full adders
	genvar i;
	generate
	for (i=0; i<N-1; i=i+1) begin: full_adders // blocks within a generate block need to be named
		FullAdder adder_inst (S[i], carry[i+1], A[i], B[i], carry[i]);	
	end
	endgenerate
	// this will generate the following code:
	// FullAdder full_adders[0].adder_inst (S[0], carry[1], A[0], B[0], carry[0]);
	// FullAdder full_adders[1].adder_inst (S[1], carry[2], A[1], B[1], carry[1]);
	// ...
	// FullAdder full_adders[63].adder_inst (S[63], carry[64], A[63], B[63], carry[63]);
endmodule

module FullAdder(S, Cout, A, B, Cin);
	input A, B, Cin;
	output S, Cout;
	
	assign S = A ^ B ^ Cin;
	assign Cout = A&B | A&Cin | B&Cin;
endmodule
