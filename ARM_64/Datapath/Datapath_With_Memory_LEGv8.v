module Datapath_With_Memory_LEGv8(clock, address, data, chip_select, write_enable, output_enable, size, DA, SA, SB, W, reset, clock, FS, C0, EN_ALU, EN_ADDR_ALU, EN_B, r0, r1, r2, r3, r4, r5, r6, r7)
	inout [63:0] data;
	output reg [31:0] address;

	// Visualization outputs
	output [15:0] r0, r1, r2, r3, r4, r5, r6, r7;

	// Register File Required Inputs
	input [4:0] DA, SA, SB;
	input W;
	input reset;
	input clock;

	// ALU Required Inputs
	input [4:0] FS;
	input C0;

	//RAM
	input chip_select, write_enable, output_enable;
	input [1:0] size; // transfer size: 00 8-bit, 01 16-bit, 10 32-bit, 11 64-bit

	// Constant input
	input [63:0] constant;

	// Tristate signals
	input EN_ALU;
	input EN_B;
	input EN_ADDR_ALU;

	Datapath_With_Memory_LEGv8 base_datapath (.data(data), .addr(address), .constant(constant), .status(1'b0), .DA(DA), .SA(SA), .SB(SB), .W(W), .reset(reset), .clock(clock), .FS(FS), .C0(C0), .EN_ALU(EN_ALU), .EN_ADDR_ALU(EN_ADDR_ALU), .EN_B(EN_B), .r0(r0), .r1(r1), .r2(r2), .r3(r3), .r4(r4), .r5(r5), .r6(r6), .r7(r7));
	RAM_64bit ram (clock, address, data, chip_select, write_enable, output_enable, size);
	
endmodule