module ControlUnit();
	output [33:0] control_word; // not using our cw
	output [63:0] constant;

	input clock, reset;
	input [31:0] instruction;
	input [4:0] status;

	wire [38:0] full_control_word;

	assign control_word = full_control_word[33:0]

	wire [2:0] CGS;
	assign CGS = full_control_word [38:36];

	ConstantGenerator CG_inst (constant, CGS, instruction);

	wire [1:0] NS;
	wire [1:0] state;
	assign NS = full_control_word [35:34];
	RegisterNbit state_reg (state, NS, 1'b1, reset, clock);
	defparam state_reg.N = 2;

	// create al intermediate control words
	wire [38:0] IF_CW, EX0_CW, EX1_CW, EX2_CW;
	Mux4to1Nbit state_mux (
		.F(full_control_word),
		.S(state),
		.I0(IF_CW),
		.I1(EX0_CW),
		.I2(EX1_CW),
		.I3(EX2_CW)
	);
	defparam state_mux.N = 39;

	wire [1:0] ex0_mux_select;
	wire [38:0] DataImm_CW, Branch_CW, Mem_CW, DataReg_CW;
	encoder_ex0 e1_inst (ex0_mux_select, instruction[28:25]);
	Mux4to1Nbit ex0_mux (
		.F(EX0_CW),
		.S(ex0_mux_select),
		.I0(DataImm_CW),
		.I1(Branch_CW),
		.I2(Mem_CW),
		.I3(DataReg_CW)
	);
	defparam ex0_mux.N = 39;

	wire [38:0] ArithImm_CW, LogicImm_CW, MOV_CW, BitField_CW, EXTR_CW;
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
	defparam data_imm_mux.N = 39;

	wire [1:0] branch_mux_sel;
	wire [38:0] B_BL_CW, CBZ_CBNZ_CW, B_cond_CW, BR_CW;
	encoder_branch e2_inst (branch_mux_sel, {instruction[30:29], instruction[25]});
	Mux4to1Nbit branch_mux (
		.F(Branch_CW),
		.S(branch_mux_sel),
		.I0(B_BL_CW),
		.I1(CBZ_CBNZ_CW),
		.I2(B_cond_CW),
		.I3(BR_CW) // also BLR and RET
	);
	defparam branch_mux.N = 39;

	wire mem_mux_sel;
	wire [5:0] mem_encoder_in;
	wire [38:0] LDUR_STUR_CW, MemOther_CW;

	assign mem_encoder_in = {instruction[29:28], instruction[24], instruction[21], instruction[11:10]}

	encoder_mem e3_inst (mem_mux_sel, mem_encoder_in); // need to implement

	assign Mem_CW = mem_mux_sel ? MemOther_CW, LDUR_STUR_CW;

	wire [38:0] LogicReg_CW, ArithReg_CW, AllKindsOfCrazyStuff_CW, MUL_CW;
	Mux4to1Nbit data_reg_mux (
		.F(DataReg_CW),
		.S(instruction[28:24]),
		.I0(LogicReg_CW),
		.I1(ArithReg_CW),
		.I2(AllKindsOfCrazyStuff_CW), // optional
		.I3(MUL_CW) // optional
	);
	defparam data_reg_mux.N = 39;

	// implement all optional control words as 0
	assign EX2_CW = 39'b0;
	assign BitField_CW = 39'b0;
	assign EXTR_CW = 39'b0;
	assign MemOther_CW = 39'b0;
	assign AllKindsOfCrazyStuff_CW = 39'b0;
	assign MUL_CW = 39'b0;

	wire [1:0] CB_PS; // PS bits
	assign CB_PS[1] = CB_PS[0];

	// I24 is 0 for CBZ and 1 for CBNZ
	assign CB_PS[0] = instruction[24] ^ status[0]; // zero status bit

						// CGS, NS,   SL,   IL,   DS,    AS,   PCsel, Bsel, mem_write, size,  RegWrite, PS,    FS,   SB,   SA,   DA
	assign CBZ_CBNZ_CW = {3'd5, 2'b0, 1'b0, 1'b0, 2'bxx, 1'bx, 1'b1,  1'bz, 1'b0,      2'bxx, 1'b0,     CB_PS, 5'bx, 5'bx, 5'bx, 5'bx}
	/* TODO: implement all of the partial control words
	IF_CW, EX1_CW
	ArithImm_CW, LogicImm_CW, MOV_CW
	B_BL_CW, B_cond_CW, BR_CW
	LDUR_STUR_CW
	LogicReg_CW, ArithReg_CW
	*/

endmodule
