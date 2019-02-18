module ROM_64bit_testbench();
	wire [63:0] data;
	reg [7:0] address;
	reg [1:0] size;
	reg clock;
	
	ROM_64bit dut (data, address, clock, size);
	
	initial begin
		clock <= 1'b0;
		address <= 8'b0;
		size <= 2'b11; // Initially complete 8 byte memory reads
		#970 $stop;
	end
	
	always
		#5 clock <= ~clock;


	always begin
		repeat(32) begin
			// Read through the entire memory file 8 bytes (64-bit read) at a time
			#10 address <= address + 4'b1000;
		end

		#5
		size <= 2'b00; // 8-bit (1 byte) reads
		address <= 8'b00000000; // Start at line 0

		//#5
		repeat (7) begin
			// Read through the first 8 bytes of the file in 1 byte steps (8-bit read)
			#10 address <= address + 4'b0001;
		end

		//#10
		repeat(32) begin
			// Read the most significant 8-bites from each 8 byte set of data (8-bit read)
			#10 address <= address + 4'b1000;
		end

		//#5
		size <= 2'b01; // 16-bit (2 byte) reads
		address <= 8'b00000000; // Start at line 0

		//#5
		repeat (4) begin
			// Read through the first 8 bytes of the file in 2 byte steps (16-bit read)
			#10 address <= address + 4'b0001;
		end

		//#5
		size <= 2'b10; // 32-bit (4 byte) reads
		address <= 8'b00110000; // Start 6 lines down in the mem file

		//#5
		repeat (8) begin
			// Read lower 4 bytes and alternates to the upper 4 bytes of memory
			#10 address <= address + 4'b0100;
		end
		
		//#5
		size <= 2'b11;  // 64-bit (8 byte) reads
		address <= 8'b01101010; // Randomly typed in address

		//#5
		repeat (8) begin
			// Read 8 bytes of data 8 times with an address increase of 13
			// Clearly shows how the ROM can be read from two different lines at the same time
			#10 address <= address + 4'b1101;
		end
	end
endmodule
