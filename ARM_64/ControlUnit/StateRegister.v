module StateRegister (Q, D, R, clock);
	parameter N = 8; // number of bits
	output reg [N-1:0]Q; // registered output
	input [N-1:0]D; // data input
	input R; // positive logic asynchronous reset
	input clock; // positive edge clock
	
	always @(posedge clock or posedge R) begin
		if(R)
			Q <= 0;
		else
			Q <= D;
	end
endmodule