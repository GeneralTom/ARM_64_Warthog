library verilog;
use verilog.vl_types.all;
entity mask_generate is
    port(
        mask            : out    vl_logic_vector(7 downto 0);
        size            : in     vl_logic_vector(1 downto 0)
    );
end mask_generate;
