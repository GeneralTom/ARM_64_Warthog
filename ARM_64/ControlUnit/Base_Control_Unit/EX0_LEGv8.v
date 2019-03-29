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

// TODO: Finish Add combinational logic to convert 
//       instruction_bits to select bits

module EX0_LEGv8 (ControlWord, instruction_bits, data_imm, branch, mem, data_reg);
	output [39:0] ControlWord;

	input [3:0] instruction_bits;
	input [39:0] data_imm;
	input [39:0] branch;
	input [39:0] mem;
	input [39:0] data_reg;

	// Mux4to1Nbit(F, S, I0, I1, I2, I3)
	Mux4to1Nbit EX0_Mux (ControlWord, , data_imm, branch, mem, data_imm);
endmodule

// E1 is the combinational logic that uses the bits
// from instruction_bits to create select bits for
// the 4:1 mux

module E1 ();

endmodule
