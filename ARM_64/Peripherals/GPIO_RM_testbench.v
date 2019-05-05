module GPIO_RM_testbench();
    wire [63:0] data_out;
    wire [63:0] data_bi;
    reg [63:0] data_in;

    reg [31:0] address;
    reg [1:0] size;
    reg mem_read, mem_write;
    reg clock, reset;

    assign data_out = data_bi;
    assign data_bi = (mem_write == 1'b1) ? data_in : 64'bZ;

    GPIO_RM dut(data_bi, address, mem_write, mem_read, size, clock);
    defparam dut.BASE_ADDR = 32'h00000000;

    initial begin
        address <= 64'b0;
        size <= 2'b01;
        mem_write <= 1'b0;
        mem_read <= 1'b0;
        clock <= 1'b1;
        reset <= 1'b1;
        #5 reset <= 1'b0;
    end

    always
        #5 clock <= ~clock;

    always begin
        data_in <= 64'h0000000000000030;
        address <= 32'h80000011;
        mem_write <= 1'b1;
        mem_read <= 1'b0;
        #20

        data_in <= 64'b0111;
        address <= 32'h80000008;
        mem_write <= 1'b1;
        mem_read <= 1'b0;
        #20

        address <= 32'h80000000;
        mem_write <= 1'b0;
        mem_read <= 1'b1;
        #20

        address <= 32'h80000008;
        mem_write <= 1'b0;
        mem_read <= 1'b1;
        #20

        data_in <= 64'b0001;
        address <= 32'h80000008;
        mem_write <= 1'b1;
        mem_read <= 1'b0;
        #20
        $stop;
    end
endmodule
