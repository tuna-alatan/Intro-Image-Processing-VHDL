library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram is
	generic(
		width_bits	: integer := 8;
		depth_bits	: integer := 8
	);

	port (
		clk		: in std_logic;
		rstn	: in std_logic;
		
		rd_en	: in std_logic;
		rd_add	: in std_logic_vector((depth_bits - 1) downto 0);
		rd_data	: out std_logic_vector((width_bits - 1) downto 0);
		
		wr_en	: in std_logic;
		wr_add	: in std_logic_vector((depth_bits - 1) downto 0);
		wr_data	: in std_logic_vector((width_bits - 1) downto 0)
	);
end bram;

architecture Behavioral of bram is 

type type_1Dx1D is array (natural range <>) of std_logic_vector;
signal s_bram : type_1Dx1D(0 to (2**depth_bits) - 1)((width_bits - 1) downto 0) := (others => (others => '0'));


begin

p_main : process (clk, rstn, rd_en, wr_en) begin
	if (rstn = '0') then
		s_bram		<=  (others => (others => '0'));
		rd_data		<= (others => '0');
	else
		if rising_edge(clk) then
			if (rd_en = '1') then
				rd_data <= s_bram(to_integer(unsigned(rd_add)));
			end if;
			
			if (wr_en = '1') then
				s_bram(to_integer(unsigned(wr_add))) <= wr_data;
			end if;
		end if;
	end if;
end process p_main;
end Behavioral;
