module ControlUnit_LEGv8(ControlWord, ControlWord1, ControlWord2, ControlWord3, ControlWord4, ControlWord5, ControlWord6, status, reset, clock);
	parameter CW_LENGTH = 40;
	output [CW_LENGTH-1:0] ControlWord;
	input [CW_LENGTH-1:0] ControlWord1, ControlWord2, ControlWord3, ControlWord4, ControlWord5, ControlWord6;
	input [4:0] status;
	input reset, clock;

	wire [2:0] state_in, previous_state;

	wire [39:0] ControlWord_IF = 40'b000_001_1_11_00_0_0_1_0_00000_0_11_0_0_00000_00000_00000;

	assign state_in = ControlWord [CW_LENGTH-4:CW_LENGTH-6];

	Mux8to1Nbit main_state_mux (ControlWord, previous_state, ControlWord_IF, ControlWord1, ControlWord2, ControlWord3, ControlWord4, ControlWord5, ControlWord6);
	defparam main_state_mux.N = CW_LENGTH;

	StateRegister stored_state (previous_state, state_in, reset, clock);
	defparam stored_state.N = 5;
endmodule
