module PWM (data, address, mem_write, mem_read, size, clock, reset);
    parameter base_address = 32'h9000000;
    parameter address_width = 8;
    parameter N = 64;
    inout [N-1:0] data;
    input [31:0] address;
    input [1:0] size;
    input mem_read, mem_write, clock, reset;

    wire chip_select;

    AddressDetect detect_pwm (address, chip_select);
    defparam detect_pwm.base_address = base_address;
    defparam detect_pwm.address_mask = 32'hFFFFFFFF << address_width;

    PWM_LEGv8 pwm (data, mem_write, mem_read, size, clock, reset);
    defparam pwm.base_address = base_address;
    defparam pwm.N = N;
endmodule

module PWM_LEGv8 (data, mem_write, mem_read, size, clock, reset);
    parameter base_address = 32'h80000000;
    parameter N = 64;

    inout [N-1:0] data;
    input [1:0] size;
    input mem_write, mem_read, clock, reset;

    RegisterNbit DUTYX ();
    defparam DUTYX.N = N;

    /**
     * Data bit breakdown:
     * 
     */

endmodule

module TimerNbit (out, in, clock, reset);
    parameter N = 64;
    inout [N-1:0] data;
    input [N-1:0] in;
    input clock, reset;

    wire [N-1:0] period;
    wire [1:0] conditions;

    /**
     * List of different conditions:
     * 
     */
                       // Q, D, L, R, clock
    RegisterNbit PERIODX (period, );
    defparam PERIODX.N = N;

    RegisterNbit TCONX (conditions, data[1:0], 1'b1, reset, clock);
    defparam TCONX.N = 2;

    CounterNbit TMRX (count, period, in, conditions, clock, reset);
    defparam TMRX.N = N;
endmodule

module CounterNbit (count, period, in, conditions, clk, rst);
    parameter N = 64;
    output reg [N-1:0] count;
    //input mode; // 1 - count up, 0 - count down
    input [N-1:0] period;
    input [N-1:0] in;
    /**
     * For RW:
     * 0 - Don't change count to the input value
     * 1 - Change count to the input value
     */
    input [1:0] conditions;
    input clk, rst;

    initial begin
        count <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst || count >= period) begin
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
