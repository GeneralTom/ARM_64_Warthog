module ROM_Detect(data, address, mem_read, size, clock);
	parameter BASE_ADDR = 32'h00000000;
	parameter ADDR_WIDTH = 8;

	output [63:0] data;
	input [31:0] address;
	input [1:0] size;
	input clock;

	wire [63:0] data_rom;
	wire chip_select;

	AddressDetect detROM (address, chip_select);
	defparam detROM.base_address = BASE_ADDR;
	defparam detROM.address_mask = 32'hFFFFFFFF << ADDR_WIDTH;

	ROM_64bit ROM (data_rom, address, clock, size);
	defparam ROM.ADDR_WIDTH = ADDR_WIDTH;

	// Add tristate buffer to allow for chip_select, since it is not built into ROM_64bit.v
	assign data = (chip_select & mem_read) ? data_rom : 64'bz;
endmodule
