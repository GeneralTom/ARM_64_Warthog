library verilog;
use verilog.vl_types.all;
entity byte_barrel_shifter is
    port(
        \out\           : out    vl_logic_vector(63 downto 0);
        shift_amount    : in     vl_logic_vector(2 downto 0);
        \in\            : in     vl_logic_vector(63 downto 0)
    );
end byte_barrel_shifter;
