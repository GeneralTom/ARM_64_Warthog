module Timer (data, address, mem_write, mem_read, size, clock, reset);
    parameter BASE_ADDR = 32'h80000000;
    parameter ADDR_WIDTH = 8;
    parameter TIMER_SIZE = 32;

    inout [63:0] data;
    input [31:0] address;
    input mem_write, mem_read;
    input [1:0] size; // 00 - 8-bit, 01 - 16-bit, 10 - 32-bit, 11 - 64-bit
    input clock, reset;

    wire chip_select;

    AddressDetect detect_timer (address, chip_select);
    defparam detect_timer.base_address = BASE_ADDR;
    defparam detect_timer.address_mask = 32'hFFFFFFFF << ADDR_WIDTH;

    TimerNbit timer (data[TIMER_SIZE-1:0], address[ADDR_WIDTH-1:0], chip_select, mem_read, mem_write, size, clock, reset);
    defparam timer.N = TIMER_SIZE;
    defparam timer.ADDR_WIDTH = ADDR_WIDTH;

endmodule

module TimerNbit (data, address, chip_select, mem_read, mem_write, size, clock, reset);
    parameter N = 32;
    parameter ADDR_WIDTH = 8;

    inout [N-1:0] data;
    input [ADDR_WIDTH-1:0] address;
    input chip_select, mem_write, mem_read;
    input [1:0] size; // 00 - 8-bit, 01 - 16-bit, 10 - 32-bit, 11 - 64-bit
    input clock, reset;

    wire [N-1:0] period;
    wire [N-1:0] count;
    
    wire condition;
    // assign condition = (chip_select & ~mem_read & mem_write) ? data[0] : 1'bz;

    assign data = (chip_select & mem_read & ~mem_write) ? count : { N{1'bz} };

    assign period = { N{1'b0} };
    /*output wire [N-1:0] period_in;
    assign period_in = (address == 1) ? data : { N{z} };*/
    /**
     * List of different conditions:
     * conditions[0] - TCONX.ON: Enable or disable the timer
     * conditions[1] - TCONX.FLAG: Flag to indicate that the timer rolled over
     * conditions[7] - TCONX.LDPERIOD: Load period signal
     */
                       // Q, D, L, R, clock
    /*RegisterNbit PERIODX (period, period_in, conditions[7], reset, clock);
    defparam PERIODX.N = N;*/

    RegisterNbit TCONX (condition, data[0], mem_write, reset, clock);
    defparam TCONX.N = 1;

    CounterNbit TMRX (count, period, data, condition, clock, reset);
    defparam TMRX.N = N;
endmodule

module CounterNbit (count, period, data, condition, clk, rst);
    parameter N = 32;
    output reg [N-1:0] count;
    //input mode; // 1 - count up, 0 - count down
    input [N-1:0] period;
    input [N-1:0] data;
    /**
     * For RW:
     * 0 - Don't change count to the input value
     * 1 - Change count to the input value
     */
    input condition;
    input clk, rst;

    initial begin
        count <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            count <= 0;
        end
        // else if (count >= period) begin
        //     // reset
        //     count <= 0;
        //     conditions[1] <= 1;
        // end
        // else if (set) begin
        //     count <= data;
        // end
        else begin
            if (condition) begin
                count <= count + 1;
            end
            else begin
                count <= count;
            end
        end
    end
endmodule
