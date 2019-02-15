module byte_barrel_shifter(out, shift_amount, in);
	// barrel shifts 64-bit input right by 8 x shift_amount
	// in other words barrel shifts right by shift_amount bytes
	input [63:0] in;
	input [2:0] shift_amount;
	output [63:0] out;
	
	wire [63:0] shift32, shift16;
	
	// shift 4 bytes or not
	assign shift32 = shift_amount[2] ? {in[31:0], in[63:32]} : in;
	// shift 2 more bytes or not
	assign shift16 = shift_amount[1] ? {shift32[15:0], shift32[63:16]} : shift32;
	// shift 1 more byte or not
	assign out = shift_amount[0] ? {shift16[7:0], shift16[63:8]} : shift16;
endmodule

module bit_barrel_shifter(out, shift_amount, in);
	// barrel shifts 8-bit input right by shift_amount bits
	input [7:0] in;
	input [2:0] shift_amount;
	output [7:0] out;
	
	wire [7:0] shift4, shift2;
	
	// shift 4 bits or not
	assign shift4 = shift_amount[2] ? {in[3:0], in[7:4]} : in;
	// shift 2 more bits or not
	assign shift2 = shift_amount[1] ? {shift4[1:0], shift4[7:2]} : shift4;
	// shift 1 more bit or not
	assign out = shift_amount[0] ? {shift2[0], shift2[7:1]} : shift2;
endmodule

module address_select(out, byte_offset);
	// based on byte offset determines which address each 8-bit memory should use
	// this will be connected to a 2:1 mux selecting between address and address+1
	input [2:0] byte_offset;
	output reg [7:0] out;
	
	always @(byte_offset)
		case(byte_offset)
			3'h0: out <= 8'b00000000; // if no offset then use address for all 64-bits
			3'h1: out <= 8'b00000001; // if 1 byte offset then use address+1 for lowest byte and address for the rest
			3'h2: out <= 8'b00000011; // ...
			3'h3: out <= 8'b00000111;
			3'h4: out <= 8'b00001111;
			3'h5: out <= 8'b00011111;
			3'h6: out <= 8'b00111111;
			3'h7: out <= 8'b01111111; // if 7 byte offset then use address for highest byte and address+1 for the rest
		endcase
endmodule

module mask_generate(mask, size);
	// generate a bit mask to determine which 8-bit memory chips should be active
	// given the desired size of the memory transfer
	input [1:0] size; // 00 8-bit, 01 16-bit, 10 32-bit, 11 64-bit
	output [7:0] mask;
	
	// desired masks:
	// 00 - 00000001
	// 01 - 00000011
	// 10 - 00001111
	// 11 - 11111111
	
	assign mask[0] = 1'b1;
	assign mask[1] = size[0] | size[1];
	assign mask[3:2] = size[1] ? 2'b11 : 2'b00;
	assign mask[7:4] = (size[1] & size[0]) ? 4'b1111 : 4'b0000;
endmodule

module RAM_8bit(out, clock, address, in, chip_select, write_enable);
	// when chip_select is on read otherwise out need to be 0 for the 64-bit design
	// to work when reading less than 64-bits
	parameter ADDR_WIDTH = 8;
	parameter RAM_DEPTH = 1 << ADDR_WIDTH; // RAM_DEPTH is in bytes
	input clock, chip_select, write_enable;
	input [ADDR_WIDTH-1:0] address;
	input [7:0] in;
	output [7:0] out;
	
	// register to store the output of memory during read
	reg [7:0] mem_out;
	// describe memory as a 8-bit array of registers
	reg [7:0] mem [0:RAM_DEPTH-1];
	
	// note if this logic is inside of the following always block as as "else out = 8'b0;"
	// quartus will not be able to implement it with the megafunction M9K blocks
	assign out = chip_select ? mem_out : 8'b0;
	
	// read description
	always @(posedge clock) begin
		mem_out = mem[address];
	end
	
	// write description
	always @(posedge clock) begin
		if(chip_select && write_enable)
			mem[address] = in;
	end
endmodule

module RAM_64bit(clock, address, data, chip_select, write_enable, output_enable, size);
	// 64-bit memory with byte addressability and no address alignment limitations
	// can read or write any size (8, 16, 32, or 64 bit) data to any address
	
	// the lower three bits of address are the byte offset and the remaining address bits
	// are the 64-bit word address. When there is a byte offset the memory will automatically
	// read partially from the 64-bit word at the address and partially from the 64-bit word
	// at the address+1 and combine and shift the data as would be expected. For example a
	// 64-bit read from address 4 would read bytes 4,5,6,7 from the upper half of the first 
	// 64-bit word and bytes 8,9,10,11 from the lower half of the next 64-bit word, that is
	// if mem was a 64-bit memory register it would return the equivalent of:
	// {mem[1][31:0], mem[0][63:32]}
	
	// note reading or writing past the end of memory will result in reading or writing
	// to address 0+. For example a write to the last address (-1) with 64-bit data would
	// write to the last byte of the last 64-bit word and a write to the first 7 bytes of
	// the first word
	
	// the size of memory is determined by the address width where memory size = 2**ADDR_WIDTH bytes
	// each 8-bit memory block will have 2**(ADDR_WIDTH - 3) bytes
	parameter ADDR_WIDTH = 8;
	input clock;
	input [ADDR_WIDTH-1:0] address;
	inout [63:0] data;
	input chip_select, write_enable, output_enable;
	input [1:0] size; // transfer size: 00 8-bit, 01 16-bit, 10 32-bit, 11 64-bit
	
	wire [63:0] ram_out; // output from 8-bit RAM chips
	wire [63:0] data_out; // output of ram_out barrel shifter
	wire [63:0] ram_in; // input to ram / output of input barrel shifter
	
	// tri-state buffer
	assign data = (chip_select & output_enable & ~write_enable) ? data_out : 64'bz;
	
	// output barrel shifter - shift right by 8 x offset
	byte_barrel_shifter output_shifter (.out(data_out), .shift_amount(address[2:0]), .in(ram_out));
	// input barrel shifter - shift left by 8 x offset = shift right by 8 x (8 - offset)
	// build circuit to do the following:
	// address -> left
	//     000    000
	//     001    111
	//     010    110
	//     011    101
	//     100    100
	//     101    011
	//     110    010
	//     111    001
	wire [2:0]left;
	assign left[0] = address[0];
	assign left[1] = address[1] ^ address[0];
	assign left[2] = address[2] ^ (address[1] | address[0]);
	byte_barrel_shifter input_shifter (.out(ram_in), .shift_amount(left), .in(data));
	// calculate address plus one word (add 1 to the address less the lower three bits)
	wire [ADDR_WIDTH-4:0] a_plus_one;
	assign a_plus_one = address[ADDR_WIDTH-1:3] + 1'b1;
	
	wire [7:0] mask;
	mask_generate mask_inst (mask, size);
	wire [7:0] cs; // individual chip selects
	bit_barrel_shifter mask_shifter (.out(cs) , .shift_amount(left), .in(mask));
	wire [7:0] a_select; // address select bits - 0 use address, 1 use address + 1
	address_select a_select_inst (.out(a_select), .byte_offset(address[2:0]));
	wire [ADDR_WIDTH-4:0] ram0_address, ram1_address, ram2_address, ram3_address, ram4_address, ram5_address, ram6_address, ram7_address;
	// 2:1 mux for each RAM chip to select between address and address+1
	// note the lower 3 bits aren't used here since they are the byte offset
	assign ram0_address = a_select[0] ? a_plus_one : address[ADDR_WIDTH-1:3];
	assign ram1_address = a_select[1] ? a_plus_one : address[ADDR_WIDTH-1:3];
	assign ram2_address = a_select[2] ? a_plus_one : address[ADDR_WIDTH-1:3];
	assign ram3_address = a_select[3] ? a_plus_one : address[ADDR_WIDTH-1:3];
	assign ram4_address = a_select[4] ? a_plus_one : address[ADDR_WIDTH-1:3];
	assign ram5_address = a_select[5] ? a_plus_one : address[ADDR_WIDTH-1:3];
	assign ram6_address = a_select[6] ? a_plus_one : address[ADDR_WIDTH-1:3];
	assign ram7_address = a_select[7] ? a_plus_one : address[ADDR_WIDTH-1:3];
	// instantiate the eight 8-bit RAM blocks
	RAM_8bit ram0 (ram_out[ 7: 0], clock, ram0_address, ram_in[ 7: 0], cs[0] & chip_select, write_enable);
	RAM_8bit ram1 (ram_out[15: 8], clock, ram1_address, ram_in[15: 8], cs[1] & chip_select, write_enable);
	RAM_8bit ram2 (ram_out[23:16], clock, ram2_address, ram_in[23:16], cs[2] & chip_select, write_enable);
	RAM_8bit ram3 (ram_out[31:24], clock, ram3_address, ram_in[31:24], cs[3] & chip_select, write_enable);
	RAM_8bit ram4 (ram_out[39:32], clock, ram4_address, ram_in[39:32], cs[4] & chip_select, write_enable);
	RAM_8bit ram5 (ram_out[47:40], clock, ram5_address, ram_in[47:40], cs[5] & chip_select, write_enable);
	RAM_8bit ram6 (ram_out[55:48], clock, ram6_address, ram_in[55:48], cs[6] & chip_select, write_enable);
	RAM_8bit ram7 (ram_out[63:56], clock, ram7_address, ram_in[63:56], cs[7] & chip_select, write_enable);
	// set the size of each 8-bit RAM by setting the ADDR_WIDTH parameter
	defparam ram0.ADDR_WIDTH = ADDR_WIDTH - 3;
	defparam ram1.ADDR_WIDTH = ADDR_WIDTH - 3;
	defparam ram2.ADDR_WIDTH = ADDR_WIDTH - 3;
	defparam ram3.ADDR_WIDTH = ADDR_WIDTH - 3;
	defparam ram4.ADDR_WIDTH = ADDR_WIDTH - 3;
	defparam ram5.ADDR_WIDTH = ADDR_WIDTH - 3;
	defparam ram6.ADDR_WIDTH = ADDR_WIDTH - 3;
	defparam ram7.ADDR_WIDTH = ADDR_WIDTH - 3;
endmodule
