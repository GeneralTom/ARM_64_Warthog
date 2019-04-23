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
