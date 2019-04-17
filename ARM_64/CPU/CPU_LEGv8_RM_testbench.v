module CPU_LEGv8_RM_testbench ();
    tri [63:0] data;
    wire [31:0] address;
    wire [31:0] instruction;
    wire [15:0] r0, r1, r2, r3, r4, r5, r6, r7;
    reg clock, reset;

    CPU_LEGv8_RM dut (data, address, instruction, clock, reset, r0, r1, r2, r3, r4, r5, r6, r7);

    initial begin
        clock <= 1'b1;
        reset <= 1'b1;
        #5 reset <= 1'b0;
    end

    always
    #5 clock <= ~clock;

    always begin
        #1000 $stop;
    end
endmodule
