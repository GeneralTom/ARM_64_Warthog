module ROM_Detect(data, address, clock, size);

parameter ADDR_WIDTH = 8;
output [63:0] data;
input [ADDR_WIDTH-1:0]address;
input clock;
input [1:0]size;

wire out;

AddressDetect detROM(address, out);
ROM_64bit det(data, address, clock, size);


endmodule
