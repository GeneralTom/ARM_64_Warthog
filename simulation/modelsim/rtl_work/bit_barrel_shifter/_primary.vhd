library verilog;
use verilog.vl_types.all;
entity bit_barrel_shifter is
    port(
        \out\           : out    vl_logic_vector(7 downto 0);
        shift_amount    : in     vl_logic_vector(2 downto 0);
        \in\            : in     vl_logic_vector(7 downto 0)
    );
end bit_barrel_shifter;
