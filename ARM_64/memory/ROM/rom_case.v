module rom_case(out, address);
	output reg[15:0] out;
	input [7:0] address;
	
	always @(address)
	begin
		case (address)
			8'h00: out = 64'b1100000000000000; //should be 64 bits long
			8'h01: out = 64'b1100100000000001;
			8'h02: out = 64'b1101000000000010;
			8'h03: out = 64'b1101100000000011;
			8'h04: out = 64'b1110000000000100;
			8'h05: out = 64'b1110100000000101;
			8'h06: out = 64'b1111000000000110;
			8'h07: out = 64'b1111100000000111;
			8'h08: out = 64'b0010100100001000;
			8'h09: out = 64'b0110100010011100;
			8'h0A: out = 64'b1100000000000000;
			8'h0B: out = 64'b1100000000000000;
			8'h0C: out = 64'b1100000000000000;
			8'h0D: out = 64'b1100000000000000;
			8'h0E: out = 64'b1100000000000000;
			8'h0F: out = 64'b1100000000000000;
			//more here
			8'hFF: out = 64'b1001100000000000;
			default:out = 64'b0000000000000000;

		endcase
	end
endmodule
