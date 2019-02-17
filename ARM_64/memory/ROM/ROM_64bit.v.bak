module ROM_64bit(data, address, clock, size);
	parameter ADDR_WIDTH = 8;
	parameter WORD_DEPTH = 1 << (ADDR_WIDTH-3); // words is 2**(ADDR_WIDTH - 3)
	output [63:0] data; 
	input [ADDR_WIDTH-1:0] address; // byte address input
	input clock; // need to syncronize ROM for Quartus to synthasize properly
	input [1:0] size; // 00 8-bit read, 01 16-bit read, 10 32-bit read, 11 64-bit read
	
	// create ROM memory model
	reg [63:0] rom_array [0:WORD_DEPTH-1];
	
	initial begin
		// use system level command to get data for initializing memory
		// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		// !!!!!!!!!!!!!                                            !!!!!!!!!!!!!!!!
		// !!!!!!!!!!!!! Change this to the path for your .mem file !!!!!!!!!!!!!!!!
		// !!!!!!!!!!!!!                                            !!!!!!!!!!!!!!!!
		// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		$readmemh("D:/Dropbox/RowanTeaching/CompArch/Quartus/LEGv8/test_memory_hex_file.mem", rom_array);
	end
	
	// model ROM as dual port memory where we read from the address and address + 1
	wire [ADDR_WIDTH-4:0] word_address0, word_address1;
	reg [63:0] data0, data1;
	assign word_address0 = address[ADDR_WIDTH-1:3];
	assign word_address1 = address[ADDR_WIDTH-1:3] + 3'd1;
	
	always @(posedge clock) begin
		data0 <= rom_array[word_address0];
		data1 <= rom_array[word_address1];
	end

	// mask the data based on the size input
	reg [63:0] mask;
	always @(*) begin
		case(size)
			2'b00: mask <= 64'h00000000000000FF;
			2'b01: mask <= 64'h000000000000FFFF;
			2'b10: mask <= 64'h00000000FFFFFFFF;
			2'b11: mask <= 64'hFFFFFFFFFFFFFFFF;
		endcase
	end
		
	// take the 128-bits of data read and shift it by 8 x address[2:0] then AND with MASK
	assign data = ({data1, data0} >> {address[2:0], 3'b000}) & mask;
endmodule
