/////////////////////////////////////////////////////////
// This file contains a 4:1 mux that is responsible for
// the four different types of instructions.
//
// 1. Data Immediate
// 2. Branches
// 3. Memory
// 4. Data Registers
//
// It also contains the combinational logic for choosing
// the specific inputs from the mux.
/////////////////////////////////////////////////////////

module EX0_LEGv8 (ControlWord, instruction, data_imm, branch, mem, data_reg);
	parameter CONTROL_N = 40;
	parameter INSTRUCTION_N = 32;

	output [CONTROL_N-1:0] ControlWord;

	input [INSTRUCTION_N-1:0] instruction_bits;
	input [CONTROL_N-1:0] data_imm;
	input [CONTROL_N-1:0] branch;
	input [CONTROL_N-1:0] mem;
	input [CONTROL_N-1:0] data_reg;

	wire [1:0] select;

	E1 encoder1 (select, instruction);
	defparam encoder1.N = INSTRUCTION_N;

	// Mux4to1Nbit(F, S, I0, I1, I2, I3)
	Mux4to1Nbit EX0_Mux (ControlWord, select, data_imm, branch, mem, data_imm);
	defparam EX0_Mux.N = CONTROL_N;
endmodule

// E1 is the combinational logic that uses the bits
// from instruction_bits to create select bits for
// the 4:1 mux

module E1 (out, instruction);
	parameter N = 32;
	output [1:0] out;
	input [N-1:0] instruction;

	wire S0, S1;

	assign S0 = (I[27] & ~I[26] & I[25]) | (I[28] & ~I[27] & I[26]);
	assign S1 = I[27] & (~I[26] | I[25]);

	assign out = {S1, S0};
endmodule
