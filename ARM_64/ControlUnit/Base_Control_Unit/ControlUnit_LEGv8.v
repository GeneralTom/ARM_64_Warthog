module ControlUnit_LEGv8(control_word, constant, I, status, clock, reset);
	parameter FULL_CW_LEN = 41;
	output [33:0] control_word;
	output [63:0] constant;

	input clock, reset;
	input [31:0] I;
	input [4:0] status;

	wire [FULL_CW_LEN-1:0] full_control_word;

	assign control_word = full_control_word[33:0];

	wire [3:0] CGS;
	assign CGS = full_control_word [FULL_CW_LEN-1:37];

	ConstantGenerator CG_inst (constant, CGS, I);

	wire [2:0] NS;
	wire [2:0] state;
	// assign state [2] = 1'b0;
	assign NS = full_control_word [36:34];
	RegisterNbit state_reg (state, NS, 1'b1, reset, clock);
	defparam state_reg.N = 3;

	// create al intermediate control words
	wire [FULL_CW_LEN-1:0] IF_CW, EX0_CW, EX1_CW, EX2_CW, EX3_CW, EX4_CW, EX5_CW, EX6_CW;
	wire [FULL_CW_LEN-1:0] MOVK2_CW;
	Mux8to1Nbit state_mux (
		.F(full_control_word),
		.S(state),
		.I0(IF_CW),
		.I1(EX0_CW),
		.I2(EX1_CW),
		.I3(EX2_CW),
		.I4(EX3_CW),
		.I5(EX4_CW),
		.I6(EX5_CW),
		.I7(EX6_CW)
	);
	defparam state_mux.N = FULL_CW_LEN;

	wire [1:0] ex0_mux_select;
	wire [FULL_CW_LEN-1:0] DataImm_CW, Branch_CW, Mem_CW, DataReg_CW;
	encoder_ex0 e1_inst (ex0_mux_select, I[28:25]);
	Mux4to1Nbit ex0_mux (
		.F(EX0_CW),
		.S(ex0_mux_select),
		.I0(DataImm_CW),
		.I1(Branch_CW),
		.I2(Mem_CW),
		.I3(DataReg_CW)
	);
	defparam ex0_mux.N = FULL_CW_LEN;

	wire [FULL_CW_LEN-1:0] ArithImm_CW, LogicImm_CW, MOV_CW, EXTR_CW;
	Mux8to1Nbit data_imm_mux (
		.F(DataImm_CW),
		.S(I[25:23]),
		.I0(41'b0), // not used
		.I1(41'b0), // not used
		.I2(ArithImm_CW),
		.I3(41'b0),
		.I4(LogicImm_CW),
		.I5(MOV_CW),
		.I6(LogicImm_CW), // optional, originally BitField_CW
		.I7(EXTR_CW) //optional
	);
	defparam data_imm_mux.N = FULL_CW_LEN;

	wire [1:0] branch_mux_sel;
	wire [FULL_CW_LEN-1:0] B_BL_CW, CBZ_CBNZ_CW, B_cond_CW, BR_CW;
	encoder_branch e2_inst (branch_mux_sel, I[30:25]);
	Mux4to1Nbit branch_mux (
		.F(Branch_CW),
		.S(branch_mux_sel),
		.I0(B_BL_CW),
		.I1(CBZ_CBNZ_CW),
		.I2(B_cond_CW),
		.I3(BR_CW) // also BLR and RET
	);
	defparam branch_mux.N = FULL_CW_LEN;

	wire mem_mux_sel;
	wire [5:0] mem_encoder_in;
	wire [FULL_CW_LEN-1:0] LDUR_STUR_CW, MemOther_CW;

	assign mem_encoder_in = {I[29:28], I[24], I[21], I[11:10]};

	encoder_mem e3_inst (mem_mux_sel, mem_encoder_in); // need to implement

	assign Mem_CW = mem_mux_sel ? LDUR_STUR_CW : MemOther_CW;

	wire [FULL_CW_LEN-1:0] LogicReg_CW, ArithReg_CW, AllKindsOfCrazyStuff_CW;
	wire [FULL_CW_LEN-1:0] MUL_CW, MUL2_CW, MUL3_CW, MUL4_CW, MUL5_CW, MUL6_CW, MUL7_CW;
	Mux4to1Nbit data_reg_mux (
		.F(DataReg_CW),
		.S({I[28], I[24]}),
		.I0(LogicReg_CW),
		.I1(ArithReg_CW),
		.I2(AllKindsOfCrazyStuff_CW), // optional
		.I3(MUL_CW) // optional
	);
	defparam data_reg_mux.N = FULL_CW_LEN;

	// implement all optional control words as 0
	assign EXTR_CW = 41'b0;
	assign MemOther_CW = 41'b0;
	assign AllKindsOfCrazyStuff_CW = 41'b0;

	////////////////////////// Main MUX //////////////////////////
	// Instruction Fetch
				 //  CGS,  NS,     AS,   DS,    PS,     PCsel, Bsel, IL,   SL,   FS,   C0,   size,  MW,   RW,   DA,   SA,   SB
				 //	  x                                   x      x                 x    x                         x     x     x
	assign IF_CW = { 4'b0, 3'b001, 1'b1, 2'b11, 2'b01,  1'b0,  1'b0, 1'b1, 1'b0, 5'b0, 1'b0, 2'b10, 1'b0, 1'b0, 5'b0, 5'b0, 5'b0 };

	// EX1_CW
	mux2to1_Nbit EX1_MUX (
		.F(EX1_CW),
		.S(I[30]),
		.I0(MUL2_CW),
		.I1(MOVK2_CW)
	);
	defparam EX1_MUX.N = FULL_CW_LEN;

	assign EX2_CW = MUL3_CW;
	assign EX3_CW = MUL4_CW;
	assign EX4_CW = MUL5_CW;
	assign EX5_CW = MUL6_CW;
	assign EX6_CW = MUL7_CW;

	///////////////////////// Data Imm. /////////////////////////
	// Arithmetic Immediate Operators (ADDI, SUBI)
					   //  CGS,    NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,      FS,               C0,      size,          MW,   RW,   DA,     SA,     SB 
					   //                    x                  x                                                                                                  x
	assign ArithImm_CW = { 4'b0000, 3'b000, 1'b0, 2'b00, 2'b00, 1'b0,  1'b1, 1'b0, I[29], { 4'b0100, I[30] }, I[30], { 1'b1, I[31] }, 1'b0, 1'b1, I[4:0], I[9:5], 5'b0 };

	// Logical Immediate Operators (AND, OR, XOR)

	wire [1:0] Logic_FS_bits;
	wire [1:0] XOR_or_shift;
	
	Mux4to1Nbit Logic_mux (
		.F(Logic_FS_bits),
		.S(I[30:29]),
		.I0(2'b00),
		.I1(2'b01),
		.I2(XOR_or_shift),
		.I3(2'b00)
	);
	defparam Logic_mux.N = 2;

	mux2to1_Nbit XOR_shift (
		.F(XOR_or_shift),
		.S(I[22]),
		.I0(2'b11),
		.I1({ 1'b0, ~I[21] })
	);
	defparam XOR_shift.N = 2;

	wire ANDS_Set_Flags;
	assign ANDS_Set_Flags = (I[30] & I[29]) & (Logic_FS_bits === 2'b00);
					   //  CGS,    NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,               FS,                              C0,     size,          MW,   RW,   DA,     SA,     SB 
					   //                    x                   x                                                                                                                     x
	assign LogicImm_CW = { { 1'b0, { 3{I[22]} } } , 3'b000, 1'b0, 2'b00, 2'b00, 1'b0,  1'b1, 1'b0, ANDS_Set_Flags, { I[22], Logic_FS_bits, 2'b00 }, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b1, I[4:0], I[9:5], 5'b0 };

	// MOVZ / MOVK
	wire [4:0] MOV_REG_Val;
	assign MOV_REG_Val = I[29] ? I[4:0] : 5'b11111;
	
				  //  CGS,              NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,                        C0,     size,          MW,   RW,   DA,     SA,          SB 
				  //                              x                  x                                                                                                            x
	assign MOV_CW = { { 3'b001, I[29] }, { 1'b0, I[29], 1'b0 }, 1'b0, 2'b00, 2'b00, 1'b0,  1'b1, 1'b0, 1'b0, { 2'b00, ~I[29] , 2'b00 }, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b1, I[4:0], MOV_REG_Val, 5'b0 };

					//  CGS,    NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,       C0,     size,          MW,   RW,   DA,     SA,     SB 
				    //                    x                   x                                                                                     x
	assign MOVK2_CW = { 4'b0010, 3'b000, 1'b0, 2'b00, 2'b00, 1'b0,  1'b1, 1'b0, 1'b0, 5'b00100, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b1, I[4:0], I[4:0], 5'b0 };

	////////////////////////// Branch //////////////////////////
	// B / BL
				   //  CGS,    NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,   C0,   size, MW,   RW,    DA,       SA,   SB 
				   //                   x                           x                 x     x     x                            x     x
	assign B_BL_CW = { 4'b0100, 3'b000, 1'b0, 2'b10, 2'b11, 1'b1,  1'b0, 1'b0, 1'b0, 5'b0, 1'b0, 2'b0, 1'b0, I[31], 5'b11110, 5'b0, 5'b0 };

	// CBZ & CBNZ
	wire [1:0] CB_PS; // PS bits
	assign CB_PS[1] = CB_PS[0];

	// I24 is 0 for CBZ and 1 for CBNZ
	assign CB_PS[0] = I[24] ^ status[0]; // zero status bit

	 				   //  CGS,    NS,   AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,       C0,   size,  MW,   RW,   DA,   SA,   SB 
					   //                  x      x                   z                 x         x     x                  x     x     x
	assign CBZ_CBNZ_CW = { 4'b0101, 3'b0, 1'b0, 2'b00, CB_PS, 1'b1,  1'b0, 1'b0, 1'b0, 5'b01000, 1'b0, 2'b11, 1'b0, 1'b0, 5'b0, 5'b11111, I[4:0] };
	
	// B.cond
	wire [1:0] B_cond_PS;
	wire B_cond_result;
	assign B_cond_PS = { B_cond_result, B_cond_result };
						//   encoding, status, result
	B_Cond_Case help_me_plz (I[4:0], status, B_cond_result);

		 			 //  CGS,    NS,   AS,   DS,      PS,        PCsel, Bsel, IL,   SL,   FS,   C0,   size,  MW,   RW,   DA,   SA,   SB 
					 //                  x      x                       z                 x     x      x                 x     x     x
	assign B_cond_CW = { 4'b0101, 3'b0, 1'b0, 2'b00, B_cond_PS, 1'b1,  1'b0, 1'b0, 1'b1, 5'b0, 1'b0, 2'b00, 1'b0, 1'b0, 5'b0, 5'b0, 5'b0 };

	// BR
			 	 //  CGS,  NS,   AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,   C0,   size, MW,   RW,   DA,   SA,     SB 
				 //                x     x                    x                 x    x     x                 x              x
	assign BR_CW = { 4'b0, 3'b0, 1'b0, 2'b00, 2'b10, 1'b0,  1'b0, 1'b0, 1'b0, 5'b0, 1'b0, 2'b0, 1'b0, 1'b0, 5'b0, I[9:5], 5'b0 };

	////////////////////////// Memory //////////////////////////
	// LDUR / STUR
				 	    //  CGS,    NS,   AS,     DS,            PS,    PCsel, Bsel, IL,   SL,   FS,       C0,   size,     MW,     RW,    DA,     SA,     SB 
						//                                                x                                                                                 x
	assign LDUR_STUR_CW = { 4'b0110, 3'b0, 1'b0, { I[22], 1'b1 }, 2'b00, 1'b0,  1'b1, 1'b0, 1'b0, 5'b01000, 1'b0, I[31:30], ~I[22], I[22], I[4:0], I[9:5], I[4:0] };

	///////////////////////// Data Reg. /////////////////////////
	// Logical Register
				 	   //  CGS,  NS,   AS,   DS,    PS,    PCsel, Bsel, IL,   SL,               FS,                              C0,      size,          MW,   RW,   DA,     SA,     SB 
					   //                x                   x
	assign LogicReg_CW = { 4'b0, 3'b0, 1'b0, 2'b00, 2'b00, 1'b0,  1'b0, 1'b0, ANDS_Set_Flags, { 1'b0, Logic_FS_bits, 2'b00 }, 1'b0 , { 1'b1, I[31] }, 1'b0, 1'b1, I[4:0], I[9:5], I[20:16] };

	// Arithmetic Register
				 	   //  CGS,  NS,   AS,   DS,    PS,    PCsel, Bsel, IL,   SL,      FS,               C0,      size,          MW,   RW,   DA,     SA,     SB 
					   //                x                   x
	assign ArithReg_CW = { 4'b0, 3'b0, 1'b0, 2'b00, 2'b00, 1'b0,  1'b0, 1'b0, I[29], { 4'b0100, I[30] }, I[30], { 1'b1, I[31] }, 1'b0, 1'b1, I[4:0], I[9:5], I[20:16] };

	//////////////////////////////////////////////////////////////
	// Optional Instruction
	// MUL Step 1 - Rd <- 0
				  //  CGS,     NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,       C0,     size,          MW,   RW,   DA,     SA,       SB 
	assign MUL_CW = { 4'b0000, 3'b010, 1'b0, 2'b00, 2'b00, 1'b0,  1'b0, 1'b0, 1'b0, 5'b00000, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b1, I[4:0], 5'b11111, 5'b11111 };

	// MUL Step 2 - Rm <- Rm & 64'h00000000FFFFFFFF
				//     CGS,     NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,       C0,     size,          MW,   RW,   DA,       SA,       SB 
	assign MUL2_CW = { 4'b1000, 3'b011, 1'b0, 2'b00, 2'b00, 1'b0,  1'b1, 1'b0, 1'b0, 5'b00000, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b1, I[20:16], I[20:16], 5'b0 };

	// MUL Step 3 - Rn <- Rn & 64'h00000000FFFFFFFF
				//     CGS,     NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,       C0,     size,          MW,   RW,   DA,     SA,     SB 
	assign MUL3_CW = { 4'b1000, 3'b100, 1'b0, 2'b00, 2'b00, 1'b0,  1'b1, 1'b0, 1'b0, 5'b00000, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b1, I[9:5], I[9:5], 5'b0 };

	// MUL Step 4 - Rn & 1
				//     CGS,     NS,                              AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,       C0,     size,          MW,   RW,   DA,   SA,     SB 
	assign MUL4_CW = { 4'b1001, { 1'b1, status[0], ~status[0] }, 1'b0, 2'b00, 2'b00, 1'b0,  1'b1, 1'b0, 1'b0, 5'b00000, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b0, 5'b0, I[9:5], 5'b0 };

	// MUL Step 5 - Rd <- Rd + Rm
				//     CGS,     NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,       C0,     size,          MW,   RW,   DA,     SA,     SB 
	assign MUL5_CW = { 4'b0000, 3'b110, 1'b0, 2'b00, 2'b00, 1'b0,  1'b0, 1'b0, 1'b0, 5'b01000, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b1, I[4:0], I[4:0], I[20:16] };

	// MUL Step 6 - Rn <- Rn >> 1
				//     CGS,     NS,                    AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,       C0,     size,          MW,   RW,   DA,     SA,     SB 
	assign MUL6_CW = { 4'b1001, { { 3{~status[0]} } }, 1'b0, 2'b00, 2'b00, 1'b0,  1'b1, 1'b0, 1'b0, 5'b10100, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b1, I[9:5], I[9:5], 5'b0 };

	// MUL Step 7 - Rm <- Rm << 1
				//     CGS,     NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,       C0,     size,          MW,   RW,   DA,       SA,       SB 
	assign MUL7_CW = { 4'b1001, 3'b100, 1'b0, 2'b00, 2'b00, 1'b0,  1'b1, 1'b0, 1'b0, 5'b10000, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b1, I[20:16], I[20:16], 5'b0 };

endmodule

module ConstantGenerator(constant, select, I);
	output [63:0] constant;
  	input [3:0] select;
  	input [31:0] I;

	Mux16to1Nbit constant_mux (
  		.F(constant),
  		.S(select),
  		.I0({52'b0, I[21:10]}),     	// zf I[21:10]
  		.I1({52'b0, I[21:10]}),     	// Technically wrong
  		.I2({48'b0, I[20:5]}), 			// zf I[20:5]
  		.I3(64'hFFFFFFFFFFFF0000),		// needed for MOV
  		.I4({{38{I[25]}}, I[25:0]}),	// se I[25:0]
  		.I5({{45{I[23]}}, I[23:5]}),	// se I[23:5]
  		.I6({{55{I[20]}}, I[20:12]}),	// se I[20:12]
  		.I7({58'b0, I[15:10]}),			// Not used (I'm going to use for shift)
  		.I8(64'h00000000FFFFFFFF),
  		.I9(64'b1),
		.I10(64'b0),
		.I11(64'b0),
		.I12(64'b0),
		.I13(64'b0),
		.I14(64'b0),
		.I15(64'b0)
  	);
	defparam constant_mux.N = 64;
endmodule

module B_Cond_Case (encoding, status, result);
 /**
  * 4: V - Overflow detection 1 (yes) / 0 (no)
  * 3: C - carry bit
  * 2: N - Sign bit
  * 1: Z - 1 (ALU output is zero) / 0 (ALU output isn't zero)
  * 0: Z raw - 1 (ALU output is zero) / 0 (ALU output isn't zero)
  */
	input [4:0] encoding;
	input [4:0] status;
	output reg result;

	always @ (encoding or status) begin
		case (encoding)
			5'b00000: result <= status[1];
			5'b00001: result <= ~status[1];
			5'b00010: result <= status[3];
			5'b00011: result <= ~status[3];
			5'b00100: result <= status[2];
			5'b00101: result <= ~status[2];
			5'b00110: result <= status[4];
			5'b00111: result <= ~status[4];
			5'b01000: result <= status[3] & ~status[1];
			5'b01001: result <= ~status[3] | status[1];
			5'b01010: result <= ~(status[2] ^ status[4]);
			5'b01011: result <= status[2] ^ status[4];
			5'b01100: result <= ~status[1] & ~(status[2] ^ status[4]);
			5'b01101: result <= status[1] & (status[2] ^ status[4]);
			5'b01110: result <= 1'b1;
			5'b01111: result <= 1'b0;
			default: result = 1'b0;
		endcase
	end
endmodule

module encoder_ex0(S, I28_27_26_25);
	output [1:0] S;
	input [3:0] I28_27_26_25;

	wire I28, I27, I26, I25;
	assign {I28, I27, I26, I25} = I28_27_26_25;

	// equations derived in class from page 232 of datasheet
	assign S[0] = ~I27 & I26 | I27 & I25;
	assign S[1] = I27;
endmodule

module encoder_branch(S, I30_25);
	output [1:0] S;
	input [5:0] I30_25;

	// map the instruction bits to single wires for readability
	// only I30, I29, and I25 are needed
	wire I30, I29, I25;
	assign I30 = I30_25[5];
	assign I29 = I30_25[4];
	assign I25 = I30_25[0];

	// assign (I30, I29, I25) = I30_29_25

	assign S[0] = (I30 & ~I29 & I25) | (~I30 & I29 & ~I25);
	assign S[1] = I30 & ~I29;
	// assign S[0] = I29 | (I30 & I25);
	// assign S[1] = (~I30 & ~I29 & ~I25) | (I30 & I25);
endmodule

module encoder_mem (select, I29_28_24_21_11_10);
	output select;
	input [5:0] I29_28_24_21_11_10;

	wire I29, I28, I24, I21, I11, I10;
	assign {I29, I28, I24, I21, I11, I10} = I29_28_24_21_11_10;

	assign select = I29 & I28 & ~I24 & ~I21 & ~I11 & ~I10;
endmodule
