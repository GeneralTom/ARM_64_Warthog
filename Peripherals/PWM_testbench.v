module PWM_testbench();
    reg clock, reset;
    wire [63:0] count;

    CounterNbit dut (count, clock, reset);
    defparam dut.N = 64;

    initial begin
        clock <= 1'b1;
        reset <= 1'b1;
        #5 reset <= 1'b0;
    end

    always
        #5 clock <= ~clock;

    always begin
        #100 $stop;
    end
endmodule
