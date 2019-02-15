library verilog;
use verilog.vl_types.all;
entity RAM_8bit is
    generic(
        ADDR_WIDTH      : integer := 8;
        RAM_DEPTH       : vl_notype
    );
    port(
        \out\           : out    vl_logic_vector(7 downto 0);
        clock           : in     vl_logic;
        address         : in     vl_logic_vector;
        \in\            : in     vl_logic_vector(7 downto 0);
        chip_select     : in     vl_logic;
        write_enable    : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of RAM_DEPTH : constant is 3;
end RAM_8bit;
