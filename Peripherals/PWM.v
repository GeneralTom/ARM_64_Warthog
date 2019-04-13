module PWM (clock, reset);
    parameter base_address = 32'h80000000;
    parameter N = 64;

endmodule

/*module TimerNbit (clock, reset);
    parameter N = 64;

    CounterNbit counter (clock, reset);
    defparam counter.N = N;
endmodule*/

module CounterNbit (count, clock, rst);
    parameter N = 64;
    output [N-1:0] count;
    input clock, rst;

    always @(posedge clk or posedge rst) begin
        if (rst || count > { N{1'b1} }) begin
            // reset
            count <= { N{1'b0} };
        end
        else begin
            count <= count + { N{1'b0}, 1'b1 };
        end
    end
endmodule
