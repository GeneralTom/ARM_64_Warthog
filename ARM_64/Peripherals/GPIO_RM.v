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
  input [31:0] address;
  input mem_read, mem_write;
  input [1:0] size; //00 8-bit, 01 16-bit, 10 32-bit, 11 64-bit
  input clock, reset;
	input chip_select;

  wire [15:0] DIR_out, OUT_out, IN_out;
  wire [15:0] D_DIR, D_OUT, D_IN;
  wire load_DIR, load_OUT;

    //register IN tristate
    assign IO = OUT_out ? DIR_out : 16'bz;

    //data tristate
    assign data = (mem_read & ~mem_write & chip_select) ? {48'b0, IN_out} : 64'bz;

    // IN Register
                    //Q, D, L, reset, clock
    RegisterNbit IN (IN_out[15:0], IO[15:0], 1'b1, reset, clock);
    defparam IN.N = 16;


    // OUT Register
    RegisterNbit OUT (OUT_out[15:0], data[15:0], load_OUT, reset, clock);
    defparam OUT.N = 16;


    // DIR Register
    assign load_DIR = (address[4:3] == 2'b10 && chip_select && mem_write && ~mem_read) ? 1'b1 : 1'b0;
    RegisterNbit DIR (DIR_out[15:0], data[15:0], load_DIR, reset, clock);
    defparam DIR.N = 16;

endmodule

module GPIO_RM(data, address, mem_write, mem_read, size, clock);
	parameter BASE_ADDR = 32'h00000000;
	localparam ADDR_WIDTH = 8;

	inout [63:0] data;
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
