module Decoder5to32(m, S, en);
	input [4:0]S; // select
	input en; // enable (positive logic)
	output [31:0]m; // 32 minterms
	
	assign m[0] = ~S[4]&~S[3]&~S[2]&~S[1]&~S[0]&en;
	assign m[1] = ~S[4]&~S[3]&~S[2]&~S[1]& S[0]&en;
	assign m[2] = ~S[4]&~S[3]&~S[2]& S[1]&~S[0]&en;
	assign m[3] = ~S[4]&~S[3]&~S[2]& S[1]& S[0]&en;
	assign m[4] = ~S[4]&~S[3]& S[2]&~S[1]&~S[0]&en;
	assign m[5] = ~S[4]&~S[3]& S[2]&~S[1]& S[0]&en;
	assign m[6] = ~S[4]&~S[3]& S[2]& S[1]&~S[0]&en;
	assign m[7] = ~S[4]&~S[3]& S[2]& S[1]& S[0]&en;
	assign m[8] = ~S[4]& S[3]&~S[2]&~S[1]&~S[0]&en;
	assign m[9] = ~S[4]& S[3]&~S[2]&~S[1]& S[0]&en;
	assign m[10]= ~S[4]& S[3]&~S[2]& S[1]&~S[0]&en;
	assign m[11]= ~S[4]& S[3]&~S[2]& S[1]& S[0]&en;
	assign m[12]= ~S[4]& S[3]& S[2]&~S[1]&~S[0]&en;
	assign m[13]= ~S[4]& S[3]& S[2]&~S[1]& S[0]&en;
	assign m[14]= ~S[4]& S[3]& S[2]& S[1]&~S[0]&en;
	assign m[15]= ~S[4]& S[3]& S[2]& S[1]& S[0]&en;	
	assign m[16]=  S[4]&~S[3]&~S[2]&~S[1]&~S[0]&en;
	assign m[17]=  S[4]&~S[3]&~S[2]&~S[1]& S[0]&en;
	assign m[18]=  S[4]&~S[3]&~S[2]& S[1]&~S[0]&en;
	assign m[19]=  S[4]&~S[3]&~S[2]& S[1]& S[0]&en;
	assign m[20]=  S[4]&~S[3]& S[2]&~S[1]&~S[0]&en;
	assign m[21]=  S[4]&~S[3]& S[2]&~S[1]& S[0]&en;
	assign m[22]=  S[4]&~S[3]& S[2]& S[1]&~S[0]&en;
	assign m[23]=  S[4]&~S[3]& S[2]& S[1]& S[0]&en;
	assign m[24]=  S[4]& S[3]&~S[2]&~S[1]&~S[0]&en;
	assign m[25]=  S[4]& S[3]&~S[2]&~S[1]& S[0]&en;
	assign m[26]=  S[4]& S[3]&~S[2]& S[1]&~S[0]&en;
	assign m[27]=  S[4]& S[3]&~S[2]& S[1]& S[0]&en;
	assign m[28]=  S[4]& S[3]& S[2]&~S[1]&~S[0]&en;
	assign m[29]=  S[4]& S[3]& S[2]&~S[1]& S[0]&en;
	assign m[30]=  S[4]& S[3]& S[2]& S[1]&~S[0]&en;
	assign m[31]=  S[4]& S[3]& S[2]& S[1]& S[0]&en;
endmodule

module Decoder1to2(S, out);
	input S;
	output [1:0] out;

	always @ (S) begin
		case (S)
			1'b0: out = 2'b01;
			1'b1: out = 2'b10;
			default: out = 2'b00;
		endcase
	end
endmodule

module Decoder2to4(S, out);
	input [1:0] S;
	output [3:0] out;

	always @ (S) begin
		case (S)
			2'b00: out = 4'b0001;
			2'b01: out = 4'b0010;
			2'b10: out = 4'b0100;
			2'b11: out = 4'b1000;
			default: out = 4'b0000;
		endcase
	end
endmodule
