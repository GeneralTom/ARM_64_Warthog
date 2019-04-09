/*module ControlUnit(control_word,constant,clock,reset);
  output [33:0] control_word;
  output [63:0] constant;
  input clock, reset;
  input [31:0] instruction;
  input [4:0] status;

  wire full_control_word;
  wire [2:0] CGS;
  assign CGS = full_control_word[38:36];

  ConstantGenerator CG_inst(constant,CGS, instruction);

  wire [1:0] NS;
  wire [1:0] state;
  assign NS = full_control_word[35:34];
  RegisterNbit_state_reg (state, NS, 1'b1, reset, clock);
  defparam state_reg.N = 2;

  wire[38:0] IF_CW, EX0_CW, EX1_CW, EX2_CW;
  Mux4to1Nbit state_mux(
    .F(full_control_word),
    .S(state),
    I0(IF_CW),
    I1(EX0_CW),
    I2(EX1_CW),
    I3(EX2_CW)
    );
    defparam state_mux.N = 39;

    wire [1:0] ex0_mux_sel;
    wire[38:0] DataImm_CW, Branch_CW, Mem_CW, DataReg_CW;
    encoder_ex0_e1_inst (ex0_mux_sel, instruction[28:25]);
  Mux4to1Nbit ex0_mux(
    .F(EX0_CW),
    .S(ex0_mux_sel),
    I0(DataImm_CW),
    I1(Branch_CW),
    I2(Mem_CW),
    I3(DataReg_CW)
    );
    defparam ex0_mux.N = 39;

    wire [38:0] ArithImm_CW, LogicImm_CW, MOV_CW, BitField_CW, EXTR_CW;
  Mux8to1Nbit data_imm_mux(
    .F(DataImm_CW),
    .S(instruction[25:23]),
    .I0(64'b0),
    .I1(64'b0),
    .I2(ArithImm_CW),
    .I3(64'b0),
    .I4(LogicImm_CW),
    .I5(MOV_CW),
    .I6(BitField_CW),
    .I7(EXTR_CW)
    );
  defparam data_imm_mux.N = 39;

  wire [1:0] branch_mux_sel;
  wire [38:0] B_BL_CW, CBZ_CBNZ_CW, B_cond_CW, BR_CW;
  encoder_branch_e2_inst(branch_mux_sel,(instruction[30:29], instruction[25]))

  Mux4to1Nbit branch_mux(
    .F(Branch_CW),
    .S(branch_mux_sel),
    I0(B_BL_CW),
    I1(CBZ_CBNZ_CW),
    I2(B_cond_CW),
    I3(BR_CW)
    );
  defparam branch_mux.N = 39;

  wire mem_mux_sel;
  wire [5:0] mem_encoder_in;
  wire [38:0] LDUR_STUR_CW, MemOther_CW;
  assign mem_encoder_in = {instruction[29:28], instruction[25], instruction[21], instruction[11:10]}

  encoder_mem_e3_inst (mem_mux_sel,mem_encoder_in);

  assign Mem_CW = mem_mux_sel

endmodule


module ConstantGenerator(constant, select, instruction);
  output [63:0]constant;
  input [2:0]select;
  input[31:0]instruction;
Mux8to1Nbit_constant_mux (

  .F(constant);
  .S(select);
  .I0((52'b0, I[21:10])),
  .I1((52'b0, I[21:10])),

  )


endmodule

module encoder_ex0(select, I28_27_26_25);
  output [1:0] select;
  input [3:0] I28_27_26_25;
  wire I28, I27, I26, I25;
  assign {I28 ,I27, I26, I25}= I28_25;
  //equations derived in class from page 232 of datasheet
  assign S[0] = ~I27 & I26 | I27 & I25;
  assing S[1] = I27;
endmodule //

module encoder_branch(select, I30_29_25);
  output [1:0] select;
  input [5:0] I30_29_25;
  //map the instruction bits to single wires for readability
  //only I30, I29, and I25 are needed
  assign I30 = I30_25[5];
  assign I29 = I30_25[4];
  assign I25 = I30_25[0];

  wire I30, I29, I25;
  assign (I30, I29, I25) = I30_29_25
  assign S[0] = ;
  assign S[1] = ;
endmodule //

module encoder_mem (select, I29_10);
  output select;
  input [5:0] I29_28_24_21_11_10;
  wire I29, I28, I24, I21, I11, I10;
  assign (I29, I28, I24, I21, I11, I10) = I29_28_24_21_11_10;
  assign select = ;
endmodule // 
*/