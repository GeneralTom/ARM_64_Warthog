//64-bit bi-directional databus
//32-bit address input
//1-bit mem_read
//1-bit mem_write
//2-bit size (00 8bit, 01 16bit, 10 32bit, 11 64bit)
// 3 Registers: DUR, IN, OUT

module GPIO_PORT_A_16bit (data, address, mem_read, mem_write, size, clock, reset, chip_select, IO);
  parameter ADDR_WIDTH = 8;
  inout [63:0] data;
  inout [15:0] IO;
  input [ADDR_WIDTH-1:0] address;
  input mem_read, mem_write;
  input [1:0] size; //00 8-bit, 01 16-bit, 10 32-bit, 11 64-bit
  input clock, reset;
	input chip_select;

  // IN Register
  wire [15:0] IN_out;
  RegisterNbit IN (IN_out, IO, 1'b1, reset, clock);
  defparam IN.N = 16;

  // OUT Register
  wire [15:0] OUT_out;
  wire load_OUT;
  assign load_OUT = (address[4:3] == 2'b01 && mem_write && ~mem_read && chip_select) ? 1'b1 : 1'b0;
  RegisterNbit OUT (OUT_out, data[15:0], load_OUT, reset, clock);
  defparam OUT.N = 16;

  // DIR Register
  wire [15:0] DIR_out;
  wire load_DIR;
  assign load_DIR = (address[4:3] == 2'b10 && chip_select && mem_write && ~mem_read) ? 1'b1 : 1'b0;
  RegisterNbit DIR (DIR_out, data[15:0], load_DIR, reset, clock);
  defparam DIR.N = 16;

  //register IN tristate
  assign IO = (DIR_out == 16'b1 ) ? OUT_out : 16'bz;

  //data tristate
  assign data = (address[4:3] == 2'b00 && mem_read & ~mem_write & chip_select) ? {48'b0, IN_out} : 64'bz;
endmodule

module GPIO_RM(data, IO, address, mem_write, mem_read, size, clock);
	parameter BASE_ADDR = 32'h00000000;
	localparam ADDR_WIDTH = 8;

	inout [63:0] data;
  inout [15:0] IO;
	input [31:0] address;
	input mem_write, mem_read;
	input [1:0] size; // 00 - 8-bit, 01 - 16-bit, 10 - 32-bit, 11 - 64-bit
	input clock;

	wire chip_select;

	AddressDetect detGPIO (address, chip_select);
	defparam detGPIO.base_address = BASE_ADDR;
	defparam detGPIO.address_mask = 32'hFFFFFFFF << ADDR_WIDTH;

                              //data, address, mem_read, mem_write, size, clock, reset, IO
	GPIO_PORT_A_16bit gpio (data, address[ADDR_WIDTH-1:0], mem_read, mem_write, size, clock, reset, chip_select, IO );
	defparam gpio.ADDR_WIDTH = ADDR_WIDTH;
endmodule
