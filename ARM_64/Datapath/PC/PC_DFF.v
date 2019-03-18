module PC_DFF(Q, D, clock, reset);
	output reg [31:0] Q;
	input [31:0] D;
	input clock, reset;
	parameter PC_RESET_VALUE = 32'h00000000;

	always @ (posedge clock or posedge reset) begin
		if (reset)
			Q <= PC_RESET_VALUE;
		else begin
			Q <= D;
		end
	end
endmodule
