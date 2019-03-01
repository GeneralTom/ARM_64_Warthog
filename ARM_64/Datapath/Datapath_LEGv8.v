module Datapath_LEGv8 (data, addr, constant, status, DA, SA, SB, W, reset, clock, FS, C0, EN_ALU, EN_ADDR_ALU, EN_B, r0, r1, r2, r3, r4, r5, r6, r7);
	output tri [63:0] data;
	output reg [31:0] addr;

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

	// Constant input
	input [63:0] constant;

	// Tristate signals
	input EN_ALU;
	input EN_B;
	input EN_ADDR_ALU;

	// ALU Required
	wire [63:0] REG_A_bus, REG_B_bus, ALU_B_bus, F;

	// Data bus tristates
	assign data = EN_ALU ? F : 64'bz;
	assign data = EN_B ? REG_B_bus : 64'bz;

	// Address bus tristates
	assign addr = EN_ADDR_ALU ? F[31:0] : 32'bz;

	mux2to1_64bit b_select (ALU_B_bus, Fx, REG_B_bus, constant);

	RegisterFile32x64 leg_reg (REG_A_bus, REG_B_bus, SA, SB, D, DA, W, reset, clock);
	ALU_LEGv8 leg_alu (REG_A_bus, ALU_B_bus, FS, C0, F, status);

	assign r0 = leg_reg.r0 [15:0];
	assign r1 = leg_reg.r1 [15:0];
	assign r2 = leg_reg.r2 [15:0];
	assign r3 = leg_reg.r3 [15:0];
	assign r4 = leg_reg.r4 [15:0];
	assign r5 = leg_reg.r5 [15:0];
	assign r6 = leg_reg.r6 [15:0];
	assign r7 = leg_reg.r7 [15:0];

endmodule