library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity wr_txt_tb is
end entity;

architecture test_bench of wr_txt_tb is

signal clk, rstn, d_val, f_val	: std_logic := '0';
signal v_data					: std_logic_vector(7 downto 0) := (others => '0');

file results_file				: text open write_mode is "results.txt"; 

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

P_WR : process
	variable current_line	: line; 
	constant str			: string := "FRAME_END";
begin
		if (f_val = '0') then
			write(current_line, str);
			writeline(results_file, current_line);
			wait until (f_val = '1');
		elsif (d_val = '1') then
			write(current_line, v_data);
			writeline(results_file, current_line);
		end if;
		wait for 10ns;
end process;


end architecture;



