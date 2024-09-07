library ieee;
use ieee.std_logic_1164.all;

entity test_pattern_tb is
end entity;

architecture test_bench of test_pattern_tb is

signal clk, rstn, d_val, f_val	: std_logic := '0';
signal v_data			: std_logic_vector(7 downto 0) := (others => '0');

begin

rstn		<= '0', '1' after 10us;

P_CLK : process
begin
	clk		<= not clk;
	wait for 5ns;
end process;

duv : entity work.test_pattern_top
port map(
	clk		=> clk,
	rstn	=> rstn,
	
	d_val	=> d_val,
	f_val	=> f_val,
	v_data	=> v_data
);

end architecture;


