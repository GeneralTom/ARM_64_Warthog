module ROM_64bit_testbench();
	wire [63:0] data;
	reg [7:0] address;
	reg [1:0] size;
	reg clock;
	
	ROM_64bit dut (data, address, clock, size);
	
	initial begin
		clock <= 1'b0;
		address <= 8'b0;
		size <= 2'b00;
		#640 $stop;
	end
	
	always
		#5 clock <= ~clock;
	
	always
		#10 address <= address + 1'b1;

	always 
		#160 size <= size + 1'b1;
	
endmodule
