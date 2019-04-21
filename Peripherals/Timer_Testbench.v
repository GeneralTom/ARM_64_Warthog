module Timer_Testbench ();
    inout reg [] data;
    reg clock, reset;

    TimerNbit dut (clock, reset);

    initial begin
        clock <= 1'b1;
        reset <= 1'b1;
        #5 reset <= 1'b0;
    end

    always
        #5 clock <= ~clock;

    always begin
        
    end
endmodule
