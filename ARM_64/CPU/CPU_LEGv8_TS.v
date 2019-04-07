module CPU_LEGv8 (data, address, clock, reset, r0, r1, r2, r3, r4, r5, r6, r7);
    inout [63:0] data;
    output tri [31:0] address;
    input clock, reset;

    wire [33:0] control_word;
    wire [31:0] instruction;
    wire [63:0] constant;
    wire [4:0] status;
    wire [3:0] current_status;

    output [15:0] r0, r1, r2, r3, r4, r5, r6, r7;

    ControlUnit_LEGv8 control_unit (
        .control_word(control_word),
        .I(instruction),
        .constant(constant),
        .status(status),
        .clock(clock),
        .reset(reset)
    );
    defparam control_unit.FULL_CW_LEN = 40;

    LEGv8_Datapath_TS datapath (
        .ControlWord(control_word),
        .IR_out(instruction),
        .constant(constant),
        .status(status),
        .current_status(current_status),
        .clock(clock),
        .reset(reset),

        .data(data),
        .address(address), 
        .r0(r0), .r1(r1), .r2(r2), .r3(r3), .r4(r4), .r5(r5), .r6(r6), .r7(r7)
    );

endmodule
