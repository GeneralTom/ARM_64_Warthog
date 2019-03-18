module Program_Counter(out, in, PS, clock, reset);
	parameter PC_RESET_ADDR = 32'h80000000;
	output [31:0] out;
	input [31:0] in;
	input [1:0] PS;
	input clock, reset;

	wire [31:0] mux1out, mux2out, mux3out, adder_out;
	wire cout;

	mux2to1_32bit mux1 (mux1out, PS[1], out, in);

	mux2to1_32bit mux2 (mux2out, PS[1], 32'd4, {in[29:0], 2'b00});

	mux2to1_32bit mux3 (mux3out, PS[0], mux1out, adder_out);

	Adder adder_32 (adder_out, cout, out, mux2out, 0);
	defparam adder_32.N = 32;
	
	PC_DFF pc_dff (mux3out, out, clock, reset);
	defparam pc_dff.PC_RESET_VALUE = PC_RESET_ADDR;
endmodule
