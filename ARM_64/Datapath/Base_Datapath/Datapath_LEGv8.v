module Datapath_LEGv8 (data, address, reset, clock, constant, DA, SA, SB, W, status, FS, C0, Bsel, EN_ALU, EN_B, EN_ADDR_ALU, r0, r1, r2, r3, r4, r5, r6, r7);
	// Main outputs
	output tri [63:0] data;
	output tri [31:0] address;

	// Basic control signals
	input reset, clock;

	// Constant input
	input [63:0] constant;

	// Register File Required Inputs
	input [4:0] DA, SA, SB;
	input W;

	// ALU Required Inputs
	output [3:0] status; // Signal outputs of the ALU
	input [4:0] FS;
	input C0;

	// For B Bus mux
	input Bsel; // 0 - B, 1 - Constant

	// Tristate signals
	input EN_ALU;
	input EN_B;
	input EN_ADDR_ALU;

	// Visualization outputs
	output [15:0] r0, r1, r2, r3, r4, r5, r6, r7;

	// ALU Required
	wire [63:0] REG_A_bus, REG_B_bus, ALU_B_bus, F;

	// Data bus tristates
	assign data = EN_ALU ? F : 64'bz;
	assign data = EN_B ? REG_B_bus : 64'bz;

	// Address bus tristates
	assign address = EN_ADDR_ALU ? F[31:0] : 32'bz;

	mux2to1_64bit b_select (ALU_B_bus, Bsel, REG_B_bus, constant);

	RegisterFile32x64 leg_reg (REG_A_bus, REG_B_bus, SA, SB, data, DA, W, reset, clock, r0, r1, r2, r3, r4, r5, r6, r7);
	ALU_LEGv8 leg_alu (REG_A_bus, ALU_B_bus, FS, C0, F, status);

endmodule