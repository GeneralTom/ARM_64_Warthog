module RAM_64bit_testbench();
	reg clock, chip_select, write_enable, output_enable;
	reg [1:0] size;
	reg [63:0] data_in;
	reg [11:0] address;
	tri [63:0] data;
	
	// my simulation determines data_in which should drive the data bus
	// via a tri-state buffer when chip_select and write_enable are on
	assign data = (chip_select & write_enable) ? data_in : 64'bz;
	
	RAM_64bit dut (clock, address, data, chip_select, write_enable, output_enable, size);
	// make the memory 4096 bytes which means 512 64-bit words
	defparam dut.ADDR_WIDTH = 12;
	
	// create wires connected to the memory in word1 (bytes 8 to 15) and word2 (bytes 16 to 23)
	wire [63:0] word1, word2, word3;
	// create wires connected to ram in (shifted data)
	wire [63:0] ram_in;
	// create wires to connect to the 8 chip select signals
	wire [7:0] ram_cs;
	// create wires for address_select bits (these are 0 for selecting current word, 1 for next word)
	wire [7:0] address_select;
	// because of how memory is organized we need to concatenate the 8 bytes together from the
	// eight memory chips to represent the 64-bit words
	// word1 is address 8 to 15
	assign word1 = {dut.ram7.mem[1], dut.ram6.mem[1], dut.ram5.mem[1], dut.ram4.mem[1], dut.ram3.mem[1], dut.ram2.mem[1], dut.ram1.mem[1], dut.ram0.mem[1]};
	// word2 is address 16 to 23
	assign word2 = {dut.ram7.mem[2], dut.ram6.mem[2], dut.ram5.mem[2], dut.ram4.mem[2], dut.ram3.mem[2], dut.ram2.mem[2], dut.ram1.mem[2], dut.ram0.mem[2]};
	// word3 is address 24 to 31
	assign word3 = {dut.ram7.mem[3], dut.ram6.mem[3], dut.ram5.mem[3], dut.ram4.mem[3], dut.ram3.mem[3], dut.ram2.mem[3], dut.ram1.mem[3], dut.ram0.mem[3]};
	// map the other internal control wires so we can see these signals on the wave view
	assign ram_in = dut.ram_in;
	assign ram_cs = dut.cs;
	assign address_select = dut.a_select;
	
	initial begin
		clock <= 1'b0;
	end
	
	always
		#5 clock <= ~clock;
		
	always begin
		// with this input timing the control signals will change halfway between
		// the clock so when reading the data will only be as expected for the first
		// half of the clock period after the rising edge.
		chip_select <= 1'b1;
		write_enable <= 1'b1;
		output_enable <= 1'b0;
		// write 07060504030201 to word1 (address 8)
		address <= 12'd8;
		data_in <= 64'h0706050403020100;
		size <= 2'b11; // 64-bit
		// write 0F to byte 23           (word2 should be 0Fxxxxxxxxxxxxxx)
		#10 address <= 12'd23;
		data_in <= 64'h000000000000000F;
		size <= 2'b00; // 8-bit
		// write 0E0D to bytes 22:21     (word2 should be 0F0E0Dxxxxxxxxxx)
		#10 address <= 12'd21;
		data_in <= 64'h0000000000000E0D;
		size <= 2'b01; // 16-bit
		// write 0C0B0A09 to bytes 20:17 (word2 should be 0F0E0D0C0B0A09xx)
		#10 address <= 12'd17;
		data_in <= 64'h000000000C0B0A09;
		size <= 2'b10; // 32-bit
		// write 08 to byte 16           (word2 should be 0F0E0D0C0B0A0908)
		#10 address <= 12'd16;
		data_in <= 64'h0000000000000008;
		size <= 2'b00; // 8-bit
		// read  8-bit words from address 8 through 15
		#10 write_enable <= 1'b0;
		output_enable <= 1'b1;
		address <= 12'd8;
		#10 address <= 12'd9;
		#10 address <= 12'd10;
		#10 address <= 12'd11;
		#10 address <= 12'd12;
		#10 address <= 12'd13;
		#10 address <= 12'd14;
		#10 address <= 12'd15;
		// read 16-bit words from address 8 through 15
		#10 size <= 2'b01; // 16-bit
		address <= 12'd8;
		#10 address <= 12'd9;
		#10 address <= 12'd10;
		#10 address <= 12'd11;
		#10 address <= 12'd12;
		#10 address <= 12'd13;
		#10 address <= 12'd14;
		#10 address <= 12'd15;
		// read 32-bit words from address 8 through 15
		#10 size <= 2'b10; // 32-bit
		address <= 12'd8;
		#10 address <= 12'd9;
		#10 address <= 12'd10;
		#10 address <= 12'd11;
		#10 address <= 12'd12;
		#10 address <= 12'd13;
		#10 address <= 12'd14;
		#10 address <= 12'd15;
		// read 64-bit words from address 8 through 15
		#10 size <= 2'b11; // 64-bit
		address <= 12'd8;
		#10 address <= 12'd9;
		#10 address <= 12'd10;
		#10 address <= 12'd11;
		#10 address <= 12'd12;
		#10 address <= 12'd13;
		#10 address <= 12'd14;
		#10 address <= 12'd15;
		#10 $stop;
	end
endmodule
