module ControlUnit_LEGv8(control_word, constant, instruction, status, clock, reset);
	parameter FULL_CW_LEN = 40;
	output [33:0] control_word; // not using our cw
	output [63:0] constant;

	input clock, reset;
	input [31:0] instruction;
	input [4:0] status;

	wire [FULL_CW_LEN-1:0] full_control_word;

	assign control_word = full_control_word[33:0]

	wire [2:0] CGS;
	assign CGS = full_control_word [FULL_CW_LEN-1:37];

	ConstantGenerator CG_inst (constant, CGS, instruction);

	wire [2:0] NS;
	wire [1:0] state;
	assign NS = full_control_word [36:34];
	RegisterNbit state_reg (state, NS, 1'b1, reset, clock);
	defparam state_reg.N = 3;

	// create al intermediate control words
	wire [FULL_CW_LEN-1:0] IF_CW, EX0_CW, EX1_CW, EX2_CW;
	Mux4to1Nbit state_mux (
		.F(full_control_word),
		.S(state),
		.I0(IF_CW),
		.I1(EX0_CW),
		.I2(EX1_CW),
		.I3(EX2_CW)
	);
	defparam state_mux.N = FULL_CW_LEN;

	wire [1:0] ex0_mux_select;
	wire [FULL_CW_LEN-1:0] DataImm_CW, Branch_CW, Mem_CW, DataReg_CW;
	encoder_ex0 e1_inst (ex0_mux_select, instruction[28:25]);
	Mux4to1Nbit ex0_mux (
		.F(EX0_CW),
		.S(ex0_mux_select),
		.I0(DataImm_CW),
		.I1(Branch_CW),
		.I2(Mem_CW),
		.I3(DataReg_CW)
	);
	defparam ex0_mux.N = FULL_CW_LEN;

	wire [FULL_CW_LEN-1:0] ArithImm_CW, LogicImm_CW, MOV_CW, BitField_CW, EXTR_CW;
	Mux8to1Nbit data_imm_mux (
		.F(DataImm_CW),
		.S(instruction[25:23])
		.I0(64'b0), // not used
		.I1(64'b0), // not used
		.I2(ArithImm_CW),
		.I3(64'b0),
		.I4(LogicImm_CW),
		.I5(MOV_CW),
		.I6(BitField_CW), // optional
		.I7(EXTR_CW) //optional
	);
	defparam data_imm_mux.N = FULL_CW_LEN;

	wire [1:0] branch_mux_sel;
	wire [FULL_CW_LEN-1:0] B_BL_CW, CBZ_CBNZ_CW, B_cond_CW, BR_CW;
	encoder_branch e2_inst (branch_mux_sel, {instruction[30:29], instruction[25]});
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

	assign mem_encoder_in = {instruction[29:28], instruction[24], instruction[21], instruction[11:10]}

	encoder_mem e3_inst (mem_mux_sel, mem_encoder_in); // need to implement

	assign Mem_CW = mem_mux_sel ? MemOther_CW, LDUR_STUR_CW;

	wire [FULL_CW_LEN-1:0] LogicReg_CW, ArithReg_CW, AllKindsOfCrazyStuff_CW, MUL_CW;
	Mux4to1Nbit data_reg_mux (
		.F(DataReg_CW),
		.S(instruction[28:24]),
		.I0(LogicReg_CW),
		.I1(ArithReg_CW),
		.I2(AllKindsOfCrazyStuff_CW), // optional
		.I3(MUL_CW) // optional
	);
	defparam data_reg_mux.N = FULL_CW_LEN;

	// implement all optional control words as 0
	assign EX2_CW = 40'b0;
	assign BitField_CW = 40'b0;
	assign EXTR_CW = 40'b0;
	assign MemOther_CW = 40'b0;
	assign AllKindsOfCrazyStuff_CW = 40'b0;
	assign MUL_CW = 40'b0;

	////////////////////////// Main MUX //////////////////////////
	// Instruction Fetch
				//  CGS,    NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,   C0,   size,  MW,   RW,   DA,   SA,   SB 
	assign IF_CW = {3'bxxx, 3'b001, 1'b1, 2'b11, 2'b0,  1'b0,  1'b0, 1'b1, 1'b0, 5'bx, 1'bx, 2'b11, 1'b0, 1'b0, 5'bx, 5'bx, 5'bx};

	// EX1_CW
				//  CGS,    NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,   C0,   size,  MW,   RW,   DA,   SA,   SB 
	// assign EX1_CW = {};

	///////////////////////// Data Imm. /////////////////////////
	// Row 2 of TODO
	// Arithmetic Immediate Operators (ADDI, SUBI)
					   //  CGS,    NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,      FS,               C0,    size,          MW,   RW,   DA,     SA,     SB 
	assign ArithImm_CW = { 3'b000, 3'b000, 1'bx, 2'b00, 2'bxx, 1'bx,  1'b1, 1'b0, I[29], { 4'b0100, I[30] }, I[30], {1'b1, I[31]}, 1'b0, 1'b1, I[4:0], I[9:5], 5'bx };

	// Logical Immediate Operators (AND, OR, XOR)
	wire ANDS_Set_Flags;
	assign ANDS_Set_Flags = I[30] & I[29];
					   //  CGS,    NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,       FS,               C0,    size,          MW,   RW,   DA,     SA,     SB 
	assign LogicImm_CW = { 3'b000, 3'b000, 1'bx, 2'b00, 2'bxx, 1'bx,  1'b1, 1'b0, ANDS_Set_Flags, {  }, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b1, I[4:0], I[9:5], 5'bx };

	// MOVZ / MOVK
				  //  CGS,    NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,   C0,     size,          MW,   RW,   DA,     SA,   SB 
	assign MOV_CW = { 3'b011, 3'b010, 1'b1, 2'b00, 2'bxx, 1'bx,  1'b1, 1'b0, 1'b0, 5'bx, 1'b0, { 1'b1, I[31] }, 1'b0, 1'b1, I[4:0], 5'bx, 5'bx }
	////////////////////////// Branch //////////////////////////
	// B / BL
				   //  CGS,    NS,     AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,   C0,     size,          MW,   RW,   DA,     SA,   SB 
	assign B_BL_CW = { 3'b000, 3'b000, 1'b1, 2'b11, 2'b11,  }

	// CBZ & CBNZ
	wire [1:0] CB_PS; // PS bits
	assign CB_PS[1] = CB_PS[0];

	// I24 is 0 for CBZ and 1 for CBNZ
	assign CB_PS[0] = instruction[24] ^ status[0]; // zero status bit

						// CGS,   NS,   SL,   IL,   DS,    AS,   PCsel, Bsel, mem_write, size,  RegWrite, PS,    FS,   SB,   SA,   DA
	//assign CBZ_CBNZ_CW = {3'd5, 3'b0, 1'b0, 1'b0, 2'bxx, 1'bx, 1'b1,  1'bz, 1'b0,      2'bxx, 1'b0,     CB_PS, 5'bx, 5'bx, 5'bx, 5'bx}

	 				  //  CGS,  NS,   AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,   C0,   size,  MW,   RW,   DA,   SA,   SB 
	assign CBZ_CBNZ_CW = {3'd5, 3'b0, 1'bx, 2'bxx, CB_PS, 1'b1,  1'bz, 1'b0, 1'b0, 5'bx, 1'bx, 2'bxx, 1'b0, 1'b0, 5'bx, 5'bx, 5'bx};
	
	// B.cond
	
		 			 //  CGS,    NS,   AS,   DS,    PS,    PCsel, Bsel, IL,   SL,   FS,   C0,   size,  MW,   RW,   DA,   SA,   SB 
	assign B_cond_CW = { 3'b100, 3'b0,  }
	////////////////////////// Memory //////////////////////////
	// Row 4 of TODO

	///////////////////////// Data Reg. /////////////////////////
	// Row 5 of TODO

	//////////////////////////////////////////////////////////////

	/* TODO: implement all of the partial control words
	EX1_CW
	ArithImm_CW (Done), LogicImm_CW, MOV_CW
	B_BL_CW, B_cond_CW, BR_CW
	LDUR_STUR_CW
	LogicReg_CW, ArithReg_CW
	*/

endmodule

module ConstantGenerator(constant, select, instruction);
	output [63:0] constant;
  	input [2:0] select;
  	input [31:0] instruction;

	Mux8to1Nbit constant_mux (
  		.F(constant);
  		.S(select);
  		.I0({52'b0, I[21:10]}),     	// zf I[21:10]
  		.I1({52'b0, I[21:10]}),     	// Technically wrong
  		.I2({48'b0, I[20:5]}), 			// zf I[20:5]
  		.I3(64'hFFFFFFFFFFFF0000),		// needed for MOV
  		.I4({{38{I[25]}}, I[25:0]}),	// se I[25:0]
  		.I5({{45{I[23]}}, I[23:5]}),	// se I[23:5]
  		.I6({{55{I[20]}}, I[20:12]}),	// se I[20:12]
  		.I7(64'b0)						// Not used
  	);
	defparam constant_mux.N = 64;
endmodule

module encoder_ex0(select, I28_27_26_25);
	output [1:0] select;
	input [3:0] I28_27_26_25;

	wire I28, I27, I26, I25;
	assign {I28 ,I27, I26, I25} = I28_25;

	// equations derived in class from page 232 of datasheet
	assign S[0] = ~I27 & I26 | I27 & I25;
	assign S[1] = I27;
endmodule

module encoder_branch(select, I30_25);
	output [1:0] select;
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
endmodule

module encoder_mem (select, I29_10);
	output select;
	input [5:0] I29_28_24_21_11_10;

	wire I29, I28, I24, I21, I11, I10;
	assign (I29, I28, I24, I21, I11, I10) = I29_28_24_21_11_10;

	assign select = I29 & I28 & ~I24 & ~I21 & ~I11 & ~I10;
endmodule
