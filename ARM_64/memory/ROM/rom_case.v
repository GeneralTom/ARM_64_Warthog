module rom_case(out, address);
	output reg[15:0] out;
	input [7:0] address;
	
	always @(address)
	begin
		case (address)
			8'h00: out = 16'b1100000000000000; //should be 64 bits long
			8'h01: out = 16'b1100000000000000;
			8'h02: out = 16'b1100000000000000;
			8'h03: out = 16'b1100000000000000;
			8'h04: out = 16'b1100000000000000;
			8'h05: out = 16'b1100000000000000;
			8'h06: out = 16'b1100000000000000;
			8'h07: out = 16'b1100000000000000;
			8'h08: out = 16'b1100000000000000;
			8'h09: out = 16'b1100000000000000;
			8'h0A: out = 16'b1100000000000000;
			8'h0B: out = 16'b1100000000000000;
			8'h0C: out = 16'b1100000000000000;
			8'h0D: out = 16'b1100000000000000;
			8'h0E: out = 16'b1100000000000000;
			8'h0F: out = 16'b1100000000000000;
			default:out = 16'b0000000000000000;
		endcase
	end
endmodule
