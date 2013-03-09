library verilog;
use verilog.vl_types.all;
entity level1 is
    port(
        T               : out    vl_logic_vector(3 downto 0);
        T1              : out    vl_logic_vector(1 downto 0);
        T2              : out    vl_logic_vector(1 downto 0);
        T3              : out    vl_logic_vector(1 downto 0);
        T4              : out    vl_logic_vector(1 downto 0);
        S1              : in     vl_logic_vector(2 downto 0);
        S2              : in     vl_logic_vector(2 downto 0);
        S3              : in     vl_logic_vector(2 downto 0);
        S4              : in     vl_logic_vector(2 downto 0);
        clock           : in     vl_logic;
        clear           : in     vl_logic
    );
end level1;
