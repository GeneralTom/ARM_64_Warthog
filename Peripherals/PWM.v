module PWM (address, mem_read, clock, reset);
    parameter base_address = 32'h9000000;
    parameter address_width = 8;

    input [31:0] address;
    input mem_read, clock, reset;

    wire chip_select;

    AddressDetect detect_pwm (address, chip_select);
    defparam detect_pwm.base_address = base_address;
    defparam detect_pwm.address_mask = 32'hFFFFFFFF << address_width;
endmodule

module PWM_LEGv8 (out, clock, reset);
    parameter base_address = 32'h80000000;
    parameter N = 64;

    input clock, reset;
    output out;

    reg duty_cycle;

    assign out = clock;
endmodule

module TimerNbit (out, in, clock, reset);
    parameter N = 64;
    inout [N-1:0] data;
    input [N-1:0] in;
    input clock, reset;

                       // Q, D, L, R, clock
    RegisterNbit PERIODX ();
    defparam PERIODX.N = N;

    RegisterNbit TCONX ();
    defparam TCONX.N = N;

    CounterNbit TMRX (count, in, clock, reset);
    defparam TMRX.N = N;
endmodule

module CounterNbit (count, in, set, clk, rst);
    parameter N = 64;
    output reg [N-1:0] count;
    //input mode; // 1 - count up, 0 - count down
    input [N-1:0] in;
    /**
     * For RW:
     * 0 - Don't change count to the input value
     * 1 - Change count to the input value
     */
    input set, clk, rst;

    initial begin
        count <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            count <= 0;
        end
        else if (set) begin
            count <= in;
        end
        else begin
            count <= count + 1;
        end
        // else if (mode) begin
        //     count <= count + 1;
        // end
        // else if (!mode) begin
        //     count <= count - 1;
        // end
    end
endmodule
