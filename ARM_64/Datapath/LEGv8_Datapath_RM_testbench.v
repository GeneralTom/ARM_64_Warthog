module LEGv8_Datapath_RM_testbench();
	reg [39:0] ControlWord;

	tri [63:0] data;
	wire [31:0] address;

	// ALU
	wire [4:0] status;

	reg [63:0] constant;
	reg clock, reset;

	wire [31:0] IR_out;
	wire [3:0] current_status;

	wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7;

	LEGv8_Datapath_RM dut (ControlWord, data, address, reset, clock, constant, status, IR_out, current_status, r0, r1, r2, r3, r4, r5, r6, r7);

	initial begin
		clock <= 1'b0;
		reset <= 1'b1;
		constant <= 64'd24;
		ControlWord <= 32'b0;
	end

	always
		#5 clock <= ~clock;

	always begin
		#5 reset <= 1'b0;

		// R0 <-- R31 | Constant (Working, don't touch!)
		#5
		ControlWord <= 40'b000_000_0_00_00_0_1_0_0_00100_0_11_0_1_00000_11111_00000;
		// ControlWord <= 32'b00000_0_0_1_0_0_00100_1_1_00001_11111_00000;
		#10

		constant <= 64'h60000018;
      	// R1 <-- R31 - R0 (Working, don't touch!)
		ControlWord <= 40'b000_000_0_00_00_0_0_0_0_01001_1_11_0_1_00001_11111_00000;
      	// ControlWord <= 32'b00000_0_0_1_0_1_01001_0_1_00000_11111_00001;
      	#10

      	// M[R31 + constant] <-- R1
		ControlWord <= 40'b000_000_0_01_00_0_1_0_0_01000_0_11_1_0_00000_11111_00001;
      	// ControlWord <= 32'b00111_1_1_0_1_0_01000_1_0_00001_11111_00000;
      	#10

      	// R1 <-- R0 & R1 (Working, don't touch!)
		ControlWord <= 40'b000_000_0_00_00_0_0_0_0_00000_0_11_0_1_00001_00000_00001;
      	// ControlWord <= 32'b00000_0_0_1_0_0_00000_0_1_00001_00000_00001;
      	#10

      	// R2 <-- M[R31 + constant]
		ControlWord <= 40'b000_000_0_11_00_0_1_0_0_01000_0_11_0_1_00010_11111_00000;
		// ControlWord <= 32'b01011_1_0_0_1_0_01000_1_1_00001_11111_00010;
		#20

		// IR
		ControlWord <= 40'b000_000_0_01_00_0_0_1_0_00000_0_11_0_0_00000_00000_00001;
		#10

		// PC <-- PC
		ControlWord <= 40'b000_000_1_00_00_1_0_0_0_00000_0_11_0_0_00000_00000_00000;
		#10

		// PC <-- PC + 4
		ControlWord <= 40'b000_000_1_00_01_1_0_0_0_00000_0_11_0_0_00000_00000_00000;
		#10

		// PC <-- input
		ControlWord <= 40'b000_000_1_00_10_1_0_0_0_00000_0_11_0_0_00010_00001_00000;
		#10

		// PC <-- PC + input
		ControlWord <= 40'b000_000_1_00_11_0_1_0_0_01000_0_11_0_0_00010_00001_00000;
		#10

		// PC <-- reset
		// ControlWord <= 40'b000_000_0_11_00_0_1_0_0_01000_0_11_0_1_00010_11111_00000;
		reset <= 1'b1;
		#10
		reset <= 1'b0;
		#5
		$stop;
	end

endmodule
