module LEGv8_ControlUnit_RM_testbench ();
	wire [39:0] ControlWord;
	wire [63:0] constant;
	reg [31:0] instruction;
	reg [4:0] status;
	reg reset, clock;
						// control_word, constant, I, status, clock, reset
	ControlUnit_LEGv8 dut (ControlWord, constant, instruction, status, reset, clock);

	initial begin
		instruction <= 32'b0;
		status <= 5'b0;
		reset <= 1'b1;
		clock <= 1'b1;
	end

	always
		#5 clock <= ~clock;

	always begin
		#5
		reset <= 1'b0;
		#5
//BEGIN ARITHMETIC --------------------------------------------
		//ADD
		instruction <= 32'b10001011000_11111_000000_00010_00000;
		#10

		//SUB
		instruction <= 32'b11001011000_00000_000000_11111_00000;
		#10

		//ADDI
		instruction <= 32'b1001000100_000000000000_00000_00000;
		#10

		//SUBI
		instruction <= 32'b1101000100_000000000000_00000_00000;
		#10

		//ADDS
		instruction <= 32'b10101011000_00000_000000_00000_00000;
		#10

		//SUBS
		instruction <= 32'b11101011000_00000_000000_00000_00000;
		#10

		//ADDIS
		instruction <= 32'b1011000100_000000000000_00000_00000;
		#10

		//SUBIS
		instruction <= 32'b1111000100_000000000000_00000_00000;
		#10
//END ARITHMETIC ----------------------------------------------

//BEGIN DATA TRANSFER -----------------------------------------
		//STUR
		instruction <= 32'b11111000000_000000000_00_00000_00000;
		#10

		//LDUR
		instruction <= 32'b11111000010_000000000_00_00000_00000;
		#10

		//MOVZ
		instruction <= 32'b110100101_00_0000000000000000_00000;
		#10

		//MOVK
		instruction <= 32'b111100101_00_0000000000000000_00000;
		#10
//END DATA TRANSFER -------------------------------------------

//BEGIN LOGIC -------------------------------------------------
		//AND
		instruction <= 32'b10001010000_00000_000000_00000_00000;
		#10

		//ORR
		instruction <= 32'b10101010000_00000_000000_00000_00000;
		#10

		//EOR
		instruction <= 32'b11001010000_00000_000000_00000_00000;
		#10

		//ANDI
		instruction <= 32'b1001001000_000000000000_00000_00000;
		#10
		//ORRI
		instruction <= 32'b1011001000_000000000000_00000_00000;
		#10
		//EORI
		instruction <= 32'b1101001000_000000000000_00000_00000;
		#10
		//ANDS
		instruction <= 32'b11101010000_00000_000000_00000_00000;
		#10
		//ANDIS
		instruction <= 32'b1111001000_000000000000_00000_00000;
		#10
		//LSR
		instruction <= 32'b11010011010_00000_000000_00000_00000;
		#10
		//LSL
		instruction <= 32'b11010011011_00000_000000_00000_00000;
		#10
//END LOGIC ---------------------------------------------------

//BEGIN CONDITIONAL BRANCH ------------------------------------
		//CBZ
		instruction <= 32'b10110100_0000000000000000000_00000;
		#10

		//CBNZ
		instruction <= 32'b10110101_0000000000000000000_00000;
		#10

		//B.cond
		instruction <= 32'b01010100_0000000000000000000_00000;
		#10
//END CONDITIONAL BRANCH --------------------------------------

//BEGIN UNCONDITIONAL JUMP ------------------------------------
		//B
		instruction <= 32'b000101_00000000000000000000000000;
		#10

		//BR
		instruction <= 32'b11010110000_00000_000000_00000_00000;
		#10

		//BL
		instruction <= 32'b100101_00000000000000000000000000;
		#10
//END UNCONDITIONAL JUMP --------------------------------------

		$stop;
	end
endmodule
