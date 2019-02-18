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
		#1280 $stop;
	end
	
	always
		#5 clock <= ~clock;


	always begin
		repeat(32) begin
			#10 address <= address + 4'b1000;
		end

		#5
		size <= 2'b00;
		address <= 8'b00000000;

		#5
		repeat (7) begin
			#10 address <= address + 4'b0001;
		end

		#10
		repeat(32) begin
			#10 address <= address + 4'b1000;
		end

		#5
		size <= 2'b01;
		address <= 8'b00000000;

		#5
		repeat (4) begin
			#10 address <= address + 4'b0001;
		end

		#5
		size <= 2'b10;
		address <= 8'b00110000;

		#5
		repeat (8) begin
			#10 address <= address + 4'b0100;
		end
		
	end


	// always begin
		
	// end

	// always 
	// 	#160 size <= size + 1'b1;
	
endmodule
