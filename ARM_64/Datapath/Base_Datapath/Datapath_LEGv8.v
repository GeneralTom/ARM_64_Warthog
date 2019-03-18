module Datapath_LEGv8 (data, address, reset, clock, constant, DA, SA, SB, W, status, FS, C0, IR_out, IL, SR_out, SL, PS, PCsel, Bsel, EN_ALU, EN_B, EN_PC, EN_ADDR_ALU, EN_ADDR_PC, r0, r1, r2, r3, r4, r5, r6, r7);
	parameter PC_RESET_VALUE = 32'h00000000;

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

	// Arithmatic Logic Unit (ALU) Required IO
	output [3:0] status; // Signal outputs of the ALU
	input [4:0] FS;
	input C0;

	// Instruction Register (IR) Required IO
	output [31:0] IR_out;
	input IL;

	// Status Register (SR) Required IO
	output [3:0] SR_out;
	input SL;

	// PC Required Inputs
	input [1:0] PS;

	// For PC mux
	input PCsel; // 0 - A [31:0], 1 - Constant [31:0]

	// For B Bus mux
	input Bsel; // 0 - B, 1 - Constant

	// Tristate signals
	input EN_ALU;
	input EN_B;
	input EN_ADDR_ALU;
	input EN_PC;

	// Visualization outputs
	output [15:0] r0, r1, r2, r3, r4, r5, r6, r7;

	// ALU wires
	wire [63:0] REG_A_bus, REG_B_bus, ALU_B_bus, F;

	// Status Register Wires
	wire [3:0] SR_out;

	// Program Counter wires
	wire [31:0] PC_in, PC_out;

	// Data bus tristates
	assign data = EN_ALU ? F : 64'bz;
	assign data = EN_B ? REG_B_bus : 64'bz;
	assign data = EN_PC ? PC_out : 64'bz;

	// Address bus tristates
	assign address = EN_ADDR_ALU ? F[31:0] : 32'bz;
	assign address = EN_ADDR_PC

	// Instruction Register
	RegisterNbit IR (IR_out, data[31:0], IL, reset, clock);
	defparam IR.N = 32;

	// Status Register
	RegisterNbit SR (SR_out, status, SL, reset, clock);
	defparam SR.N = 4;

	// Program Counter input value
	mux2to1_32bit PC_select (PC_in, PCselect, A [31:0], constant [31:0])

	Program_Counter PC (PC_out, PC_in, PS, clock, reset);
	defparam PC.PC_RESET_ADDR = PC_RESET_VALUE;

	// ALU B input value
	mux2to1_64bit b_select (ALU_B_bus, Bsel, REG_B_bus, constant);

	RegisterFile32x64 leg_reg (REG_A_bus, REG_B_bus, SA, SB, data, DA, W, reset, clock, r0, r1, r2, r3, r4, r5, r6, r7);
	ALU_LEGv8 leg_alu (REG_A_bus, ALU_B_bus, FS, C0, F, status);

endmodule