module RAM_Detect(data, address, mem_write, mem_read, size, clock);
	parameter BASE_ADDR = 32'h00000000;
	parameter ADDR_WIDTH = 8;

	inout [63:0] data;
	input [31:0] address;
	input mem_write, mem_read;
	input [1:0] size; // 00 - 8-bit, 01 - 16-bit, 10 - 32-bit, 11 - 64-bit
	input clock;

	wire chip_select;

	AddressDetect detRAM (address, chip_select);
	defparam detRAM.base_address = BASE_ADDR;
	defparam detRAM.address_mask = 32'hFFFFFFFF << ADDR_WIDTH;

	RAM_64bit RAM (clock, address[ADDR_WIDTH-1:0], data, chip_select, mem_write, mem_read, size);
	defparam RAM.ADDR_WIDTH = ADDR_WIDTH;
endmodule

