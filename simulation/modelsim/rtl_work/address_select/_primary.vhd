library verilog;
use verilog.vl_types.all;
entity address_select is
    port(
        \out\           : out    vl_logic_vector(7 downto 0);
        byte_offset     : in     vl_logic_vector(2 downto 0)
    );
end address_select;
