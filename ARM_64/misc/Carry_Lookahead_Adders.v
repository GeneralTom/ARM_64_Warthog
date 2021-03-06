module single_bit_carry_lookahead(S, g, p, A, B, Cin);
	input A, B, Cin;
	output S, g, p;
	
	assign S = A ^ B ^ Cin;
	assign g = A & B;
	assign p = A | B;
endmodule

module carry_lookahead_logic(c1, c2, c3, G, P, g, p, Cin);
	output G, P;
	output c1, c2, c3;
	input [3:0] g, p;
	input Cin;
	
	assign c1 = g[0] | p[0] & Cin;
	assign c2 = g[1] | p[1] & g[0] | p[1] & p[0] & Cin;
	assign c3 = g[2] | p[2] & g[1] | p[2] & p[1] & g[0] | p[2] & p[1] & p[0] & Cin;
	assign c4 = g[3] | p[3] & p[2] | p[3] & p[2] & g[1] | p[3] & p[2] & p[1] & g[0];
	assign P = p[3] & p[2] & p[1] & p[0];
endmodule

module four_bit_carry_lookahead_adder(S, G, P, A, B, Cin);
	input [3:0] A, B;
	input Cin;
	output [3:0] S;
	output G, P;
	
	wire [3:0] g, p;
	wire c1, c2, c3;
	
	//single_bit_carry_lookahead(S, g, p, A, B, Cin);
	single_bit_carry_lookahead adder0 (S[0], g[0], p[0], A[0], B[0], Cin);
	single_bit_carry_lookahead adder1 (S[1], g[1], p[1], A[1], B[1], Cin);
	single_bit_carry_lookahead adder2 (S[2], g[2], p[2], A[2], B[2], Cin);
	single_bit_carry_lookahead adder3 (S[3], g[3], p[3], A[3], B[3], Cin);
	
	//carry_lookahead_logic(c1, c2, c3, G, P, g, p, Cin)
	carry_lookahead_logic lookahead_inst (c1, c2, c3, G, P, g, p, Cin);
	
endmodule

module sixteen_bit_carry_lookahead_adder(S, G, P, A, B, Cin);
	input [15:0] A, B;
	input Cin;
	output [15:0] S;
	output G, P;
	
	wire [3:0] g, p;
	wire c1, c2, c3;
	
	//four_bit_carry_lookahead_adder(S, G, P, A, B, Cin);
	four_bit_carry_lookahead_adder adder0 (S[3:0], g[0], p[0], A[3:0], B[3:0], Cin);
	four_bit_carry_lookahead_adder adder1 (S[7:4], g[1], p[1], A[7:4], B[7:4], c1);
	four_bit_carry_lookahead_adder adder2 (S[11:8], g[2], p[2], A[11:8], B[11:8], c2);
	four_bit_carry_lookahead_adder adder3 (S[15:12], g[3], p[3], A[15:12], B[15:12], c3);
	
	//carry_lookahead_logic(c1, c2, c3, G, P, g, p, Cin)
	carry_lookahead_logic lookahead_inst (c1, c2, c3, G, P, g, p, Cin);
	
endmodule

module sixtyfour_bit_carry_lookahead_adder(S, Cout, A, B, Cin);
	input [63:0] A, B;
	input Cin;
	output [63:0] S;
	output Cout;
	
	wire [3:0] g, p;
	wire c1, c2, c3;
	
	//sixteen_bit_carry_lookahead_adder(S, G, P, A, B, Cin);
	sixteen_bit_carry_lookahead_adder adder0 (S[15:0],  g[0], p[0], A[15:0], B[15:0],   Cin);
	sixteen_bit_carry_lookahead_adder adder1 (S[31:16], g[1], p[1], A[31:16], B[31:16], c1);
	sixteen_bit_carry_lookahead_adder adder2 (S[47:32], g[2], p[2], A[47:32], B[47:32], c2);
	sixteen_bit_carry_lookahead_adder adder3 (S[63:48], g[3], p[3], A[63:48], B[63:48], c3);
	
	wire G, P;
	carry_lookahead_logic lookahead_inst (c1, c2, c3, G, P, g, p, Cin);
	assign Cout = G | P & Cin;
endmodule
