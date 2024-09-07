library ieee;
use ieee.std_logic_1164.all;

entity frame_valid_tb is
end entity;

architecture test_bench of frame_valid_tb is

signal clk		: std_logic := '0';
signal rstn		: std_logic := '0';
signal f_val	: std_logic := '0';
signal d_val	: std_logic := '0';

begin


rstn		<= '1' after 10us;

process
begin
	clk		<= not clk;
	wait for 5ns;
end process;


duv : entity work.frame_valid
generic map(
	clk_freq	=> 100_000_000.0,
	x_res		=> 640,
	y_res		=> 480,
	l2l_w_ns	=> 62800.0
)

port map(
	clk		=> clk,
	rstn	=> rstn,

	f_val	=> f_val,
	d_val	=> d_val
);


end architecture;
