module CPU_LEGv8_TS_testbench ();
    tri [63:0] data;
    wire [31:0] address;
    wire [31:0] instruction;
    wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7;
    reg clocc, reset;

    CPU_LEGv8_TS donald_dut (data, address, instruction, clocc, reset, r0, r1, r2, r3, r4, r5, r6, r7);

    initial begin
        clocc <= 1'b1;
        reset <= 1'b1;
        #5 reset <= 1'b0;
    end

    always
    #5 clocc <= ~clocc;

    always begin
        #1000 $stop;
    end
endmodule
