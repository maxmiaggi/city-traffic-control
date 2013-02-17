library verilog;
use verilog.vl_types.all;
entity randomtest1 is
    port(
        Tin             : in     vl_logic_vector(3 downto 0);
        Tout            : out    vl_logic_vector(3 downto 0)
    );
end randomtest1;
