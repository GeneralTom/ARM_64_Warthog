module LEGv8_ControlUnit_TS_testbench ();
	wire [39:0] ControlWord;
	reg [31:0] instruction;
	reg [4:0] status;
	reg reset, clock;

	LEGv8_ControlUnit_TS dut (ControlWord, instruction, status, reset, clock);

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
		instruction <= 32'b10001011000_11111_000000_00010_00000;

		#20
		instruction <= 32'b11001011000_00000_000000_11111_00000;

		#10
		$stop;
	end
endmodule