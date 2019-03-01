//AddressDetect thing thing
module AddressDetect(address, out);
	input [31:0] address;
	output out;

	parameter base_address = 32'h00000000;
	parameter address_mask = 32'hFFFFFFFF;

	assign out = ((address & address_mask) == base_address);

endmodule