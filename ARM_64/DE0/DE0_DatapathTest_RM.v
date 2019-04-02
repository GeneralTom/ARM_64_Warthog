module DE0_DatapathTest_RM(CLOCK_50, LEDG, SW, BUTTON, GPIO0_D, GPIO1_D, HEX0, HEX1, HEX2, HEX3);
	// connection names for DE0 FPGA board - names must match pin assignment file
	input CLOCK_50;
	input [9:0] SW;
	input [2:0] BUTTON;
	inout [31:0] GPIO1_D;
	output [31:0] GPIO0_D;
	output [9:0] LEDG;
	output [6:0] HEX0, HEX1, HEX2, HEX3;

	// use button 0 for reset and 2 for clock
	wire clock, reset;
	// buttons are active low so invert them to get possitive logic
	assign clock = ~BUTTON[2];
	assign reset = ~BUTTON[0];

	// create wires for memory interface
	tri [63:0] data;
	wire [31:0] address;
	// wire mem_read, mem_write;
	// wire [1:0] size; 

	// create remaining wires for datapath inteface
	wire [63:0] constant;
	wire [4:0] status; // 5 bits: {V, C, N, Z, Znot_registered}
	wire [3:0] current_status;
	wire [31:0] instruction;
	//////////// CHANGE THE NUMBER OF BITS TO MATCH YOUR CONTROL WORD ///////////
	wire [39:0] ControlWord;
	//////////// OPTIONAL PROGRAM COUNTER OUTPUT - NOT USED FOR THIS TEST ///////
	//////////// REMOVE THIS IF YOUR DATAPATH DOESN'T HAVE THIS SIGNAL //////////
	// wire [15:0] PC_out;
	//////////// if your datapath has any other signals besides:
	// ControlWord (input)
	// constant (input)
	// status (output)
	// instruction (output)
	// data (inout)
	// address (output)
	// mem_write (output)
	// mem_read (output)
	// size (output)
	// clock (input)
	// reset (input)
	// PC_out (optional output)
	// r0, r1, r2, r3, r4, r5, r6, r7 (outputs)
	///////////// make sure to add them and connect them to whatever makes sense

	// wires of outputs for visualization on GPIO Board
	wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7;

	// DIP switch input from GPIO Board
	wire [31:0] DIP_SW;

	// wires for 7-segment decoder outputs
	wire [6:0] h0, h1, h2, h3, h4, h5, h6, h7, hex0, hex1, hex2, hex3;
	// create 7-segment decoders (4x at a time)
	// display upper 16 bits of address on hex 7:4 (on GPIO board)
	quad_7seg_decoder address_decoder_high (address[31:16], h7, h6, h5, h4);
	// display lower 16 bits of address on hex 3:0 (on GPIO board)
	quad_7seg_decoder address_decoder_low (address[15:0], h3, h2, h1, h0);
	// display lower 16 bits of data on HEX 3:0 (on DE0 itself)
	quad_7seg_decoder data_decoder (data[15:0], hex3, hex2, hex1, hex0);
	assign HEX0 = ~hex0; // each signal must be inverted because DE0 hex's are active low
	assign HEX1 = ~hex1;
	assign HEX2 = ~hex2;
	assign HEX3 = ~hex3;

	// instantiate GPIO_Board module
	GPIO_Board gpio_board (
		CLOCK_50, // connect to CLOCK_50 of the DE0
		r0, r1, r2, r3, r4, r5, r6, r7, // row display inputs
		h0, 1'b0, h1, 1'b0, // hex display inputs
		h2, 1'b0, h3, 1'b0, // 0 connected to decimal point inputs
		h4, 1'b0, h5, 1'b0,
		h6, 1'b0, h7, 1'b0,
		DIP_SW, // 32x DIP switch output
		instruction, // 32x LED input (show the IR output)
		GPIO0_D, // (output) connect to GPIO_0
		GPIO1_D // (input/output) connect to GPIO_1
	);

	// connect the lower 32-bits of the control word to the 32 DIP switches on the GPIO board
	assign ControlWord[39:0] = {SW[7:0], DIP_SW[31:0]};
	// if there are more than 32-bits to the control word connect them to SW[9:0]
	// in my case there was only one more bit so it is connected to SW[0]
	// if your control word is 32-bits or less remove the following line
	// assign ControlWord[39:32] = SW[7:0];
	// make the constant constant
	// alternatively some of the constant bits could be connected to switches (SW) to allow it to be changed
	assign constant = 64'h6000004A;
	// connect the status bits to the LEDs
	assign LEDG[4:0] = status;

	assign LEDG[8] = reset;
	assign LEDG[9] = clock;

	/////////// This line should be completely replaced with your datapath and the
	/////////// connection order appropriate using the names from this file
	// DatapathWithMem datapath (ControlWord, constant, status, instruction, data, address, mem_write, mem_read, size, clock, reset, PC_out, r0, r1, r2, r3, r4, r5, r6, r7);
							// ControlWord, data, address, reset, clock, constant, status, IR_out, current_status, r0, r1, r2, r3, r4, r5, r6, r7);
	LEGv8_Datapath_RM datapath (ControlWord, data, address, reset, clock, constant, status, instruction, current_status, r0, r1, r2, r3, r4, r5, r6, r7);
endmodule
