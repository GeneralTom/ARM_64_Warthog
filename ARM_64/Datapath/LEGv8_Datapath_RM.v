module LEGv8_Datapath_RM(ControlWord, data, address, reset, clock, constant, status, IR_out, current_status, r0, r1, r2, r3, r4, r5, r6, r7); // before r0 -> write_enable, read_enable, size,
	//                         Datapath_LEGv8 (data, address, reset, clock, constant, status, FS, C0, Bsel, EN_ALU, EN_B, EN_ADDR_ALU, r0, r1, r2, r3, r4, r5, r6, r7);

	input [33:0] ControlWord; // Combination of control signals

	// Main Outputs
	inout [63:0] data; // Set to inout because read/write from memory
	output tri [31:0] address;

	// Basic control signals
	input reset, clock;

	// Constant input
	input [63:0] constant;

	// ALU
	output [4:0] status; // V - Overflow detection 1 (yes) / 0 (no), C - carry bit, N - Sign bit, Z - 1 (ALU output is zero) / 0 (ALU output isn't zero)
	output [3:0] current_status;
	// Register Outputs
	output [31:0] IR_out;

	// Visualization outputs
	output [15:0] r0, r1, r2, r3, r4, r5, r6, r7;

	// Register File Required Inputs
	wire [4:0] DA, SA, SB;
	wire RW;

	// ALU Required Inputs
	wire Bsel;
	wire [4:0] FS;
	wire C0;
	wire SL; // Status Register Load

	wire [3:0] ALU_status, SR_out;

	// Memory
	wire MW;
	wire [1:0] size;

	// Instruction Register Load
	wire IL;

	// Program Counter
	wire [1:0] PS;
	wire PCsel;

	// Tristate signals
	wire AS; // 0 - Enable ALU on address bus, 1 - Enable Program Counter on address bus
	wire [1:0] addr_signals;

	wire [1:0] DS; // 00 - Enable ALU on data bus, 01 - Enable B on data bus, 10 - Enable PC on data bus, 11 - Enable memory read on data bus
	wire [3:0] data_signals;

	// Assign Values from ControlWord
	assign { AS, DS, PS, PCsel, Bsel, IL, SL, FS, C0, size, MW, RW, DA, SA, SB } = ControlWord;

	Decoder1to2 addr_enable (AS, addr_signals);

	Decoder2to4 data_enable (DS, data_signals);

	assign status = {SR_out, data_signals[0]};

	//            Datapath_LEGv8 (data, address, reset, clock, constant, DA, SA, SB, W, status, FS, C0, IR_out, IL, SR_out, SL, PS, PCsel, Bsel, EN_ALU, EN_B, EN_PC, EN_ADDR_ALU, EN_ADDR_PC, r0, r1, r2, r3, r4, r5, r6, r7);
	Datapath_LEGv8 base_datapath (data, address, reset, clock, constant, DA, SA, SB, RW, current_status, FS, C0, IR_out, IL, SR_out, SL, PS, PCsel, Bsel, data_signals[0], data_signals[1], data_signals[2], addr_signals[0], addr_signals[1], r0, r1, r2, r3, r4, r5, r6, r7);
	defparam base_datapath.PC_RESET_VALUE = 32'h40000000;

	//   RAM_64bit(clock, address, data, chip_select, write_enable, output_enable, size);
	RAM_Detect ram (data, address, MW, data_signals[3], size, clock);
	defparam ram.BASE_ADDR = 32'h60000000;
	defparam ram.ADDR_WIDTH = 12;

	ROM_Detect rom (data, address, data_signals[3], size, clock);
	defparam rom.BASE_ADDR = 32'h40000000;
	defparam rom.ADDR_WIDTH = 10;
endmodule
