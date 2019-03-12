module RAM_Detect(clock, address, data, chip_select, write_enable, output_enable, size);

	parameter ADDR_WIDTH = 8;
	input clock;
	input [ADDR_WIDTH-1:0] address;
	inout [63:0] data;
	input chip_select, write_enable, output_enable;
	input [1:0] size;

	wire out;

	AddressDetect detRAM(address, out);
	RAM_64bit detRAM(clock, address, data, out, write_enable, output_enable, size);

endmodule

