module DataImm_ControlUnit (ControlWord, instruction);
	parameter CONTROL_N = 40;
	parameter INSTRUCTION_N = 32;

	output [CONTROL_N-1:0] ControlWord;
	input [INSTRUCTION_N-1:0] instruction;

	Mux8to1Nbit Data_Imm_Mux (ControlWord, instruction[25:23], 40'b0, 40'b0, , 40'b0, , , 40'b0, 40'b0);
	defparam Data_Imm_Mux.N = CONTROL_N;	
endmodule
