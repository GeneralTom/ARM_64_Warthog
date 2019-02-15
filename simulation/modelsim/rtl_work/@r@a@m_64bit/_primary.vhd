library verilog;
use verilog.vl_types.all;
entity RAM_64bit is
    generic(
        ADDR_WIDTH      : integer := 8
    );
    port(
        clock           : in     vl_logic;
        address         : in     vl_logic_vector;
        data            : inout  vl_logic_vector(63 downto 0);
        chip_select     : in     vl_logic;
        write_enable    : in     vl_logic;
        output_enable   : in     vl_logic;
        size            : in     vl_logic_vector(1 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
end RAM_64bit;
