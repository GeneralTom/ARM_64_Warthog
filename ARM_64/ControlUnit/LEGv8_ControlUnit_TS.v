module LEGv8_ControlUnit_TS(ControlWord, instruction, status, reset, clock);
	parameter CW_LENGTH = 40;
	output [CW_LENGTH-1:0] ControlWord;
	input [31:0] instruction;
	input [4:0] status;
	input reset, clock;

	wire [CW_LENGTH-1:0] ControlWord1, ControlWord2, ControlWord3, ControlWord4, ControlWord5, ControlWord6;

	assign ControlWord2 = 40'b0;
	assign ControlWord3 = 40'b0;
	assign ControlWord4 = 40'b0;
	assign ControlWord5 = 40'b0;
	assign ControlWord6 = 40'b0;

	assign ControlWord1 = {19'b000_000_0_00_00_0_0_0_0, instruction[30], instruction[30], 4'b11_0_1, instruction[4:0], instruction[20:16], instruction[9:5]};
	// mux2to1_Nbit mux1 (ControlWord1, instruction[30], );
	// defparam mux1.N = CW_LENGTH;

	ControlUnit_LEGv8 base_control_unit (ControlWord, ControlWord1, ControlWord2, ControlWord3, ControlWord4, ControlWord5, ControlWord6, status, reset, clock);
	defparam base_control_unit.CW_LENGTH = CW_LENGTH;
endmodule
