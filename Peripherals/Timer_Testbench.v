module Timer_Testbench ();
    wire [63:0] data_out;
    wire [63:0] data_bi;
    reg [63:0] data_in;

    reg [31:0] address;
    reg [1:0] size;
    reg mem_read, mem_write;
    reg clock, reset;

    assign data_out = data_bi;
    assign data_bi = (mem_write == 1'b1) ? data_in : 64'bZ;

    Timer_TS dut (data_bi, address, mem_write, mem_read, size, clock, reset);
    defparam dut.BASE_ADDR = 32'h80000000;
    defparam dut.ADDR_WIDTH = 8;

    initial begin
        address <= 64'b0;
        size <= 2'b11;
        mem_write <= 1'b0;
        mem_read <= 1'b0;
        clock <= 1'b1;
        reset <= 1'b1;
        #5 reset <= 1'b0;
    end

    always
        #5 clock <= ~clock;

    always begin
        #10 // Sets period to 8'h20
        data_in <= 64'h0000000000000020;
        address <= 32'h80000002;
        mem_write <= 1'b1;
        mem_read <= 1'b0;
        #10 // Read period back
        mem_write <= 1'b0;
        mem_read <= 1'b1;
        #10 // Set the conditions register to start the timer and use period
        data_in <= 64'b0101;
        address <= 32'h80000001;
        mem_write <= 1'b1;
        mem_read <= 1'b0;
        #10 // Just view timer output
        address <= 32'h80000000;
        mem_write <= 1'b0;
        mem_read <= 1'b1;
        #500 // View the condition register
        address <= 32'h80000001;
        mem_write <= 1'b0;
        mem_read <= 1'b1;
        #10 // Set the condition register to not use the period
        data_in <= 64'b0001;
        address <= 32'h80000001;
        mem_write <= 1'b1;
        mem_read <= 1'b0;
        #10 // Watch output again
        address <= 32'h80000000;
        mem_write <= 1'b0;
        mem_read <= 1'b1;
        #480 // Change address to test if timer base address detect is working
        address <= 32'h70000000;
        #50
        $stop;
    end
endmodule
