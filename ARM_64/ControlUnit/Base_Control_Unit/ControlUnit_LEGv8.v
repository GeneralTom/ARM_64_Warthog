module ControlUnit_LEGv8(ControlWord, EX0, EX1, EX2, EX3, EX4, EX5, status, reset, clock);
	parameter CW_LENGTH = 40;
	output [CW_LENGTH-1:0] ControlWord;
	input [CW_LENGTH-1:0] EX0, EX1, EX2, EX3, EX4, EX5;
	input [4:0] status;
	input reset, clock;

	wire [2:0] state_in, previous_state;

	wire [39:0] IF = 40'b000_001_1_11_00_0_0_1_0_00000_0_11_0_0_00000_00000_00000;

	assign state_in = ControlWord [CW_LENGTH-4:CW_LENGTH-6];

	Mux8to1Nbit main_state_mux (ControlWord, previous_state, IF, EX0, EX1, EX2, EX3, EX4, EX5);
	defparam main_state_mux.N = CW_LENGTH;

	StateRegister stored_state (previous_state, state_in, reset, clock);
	defparam stored_state.N = 5;
endmodule
