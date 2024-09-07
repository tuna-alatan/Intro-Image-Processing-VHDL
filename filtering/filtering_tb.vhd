library ieee;
use ieee.std_logic_1164.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity filtering_tb is
end entity;

architecture test_bench of filtering_tb is

constant x_res					: integer := 640;
constant y_res					: integer := 480;
constant clk_freq				: real := 100_000_000.0;
constant l2l_w_ns				: real := 62800.0;

constant bram_width_bits		: integer := 8;
constant bram_depth_bits		: integer := 10;

signal clk, rstn				: std_logic := '0';
signal d_val_out, f_val_out		: std_logic := '0';
signal v_data_out				: std_logic_vector(7 downto 0) := (others => '0');

signal s_d_val, s_d_val_d1		: std_logic := '0';
signal s_f_val, s_f_val_d1		: std_logic := '0';
signal s_v_data					: std_logic_vector(7 downto 0) := (others => '0');

file results_file				: text open write_mode is "filtering_results.txt"; 

begin

inst_frame_valid : entity work.frame_valid
generic map(
	clk_freq				=> clk_freq,
	x_res					=> x_res,
	y_res					=> y_res + 1,
	l2l_w_ns				=> l2l_w_ns
)
port map(
	clk						=> clk,
	rstn					=> rstn,
	
	f_val					=> s_f_val,
	d_val					=> s_d_val
);

inst_diag_test_pattern : entity work.diag_test_pattern_gen
port map(
	clk						=> clk,
	rstn					=> rstn,

	f_val					=> s_f_val,
	d_val					=> s_d_val,

	d_val_d					=> s_d_val_d1,
	f_val_d					=> s_f_val_d1,
	v_data					=> s_v_data
);

duv : entity work.filtering
generic map(
	x_res				=> x_res,
	y_res				=> y_res,
	
	bram_width_bits		=> bram_width_bits,
	bram_depth_bits		=> bram_depth_bits
)

port map(
	clk					=> clk,
	rstn				=> rstn,
	
	v_data_in			=> s_v_data,
	v_data_out			=> v_data_out,
	
	d_val_in			=> s_d_val_d1,
	f_val_in			=> s_f_val_d1,
	
	d_val_out			=> d_val_out,
	f_val_out			=> f_val_out
);

rstn		<= '0', '1' after 10us;

P_CLK : process
begin
	clk		<= not clk;
	wait for 5ns;
end process;

P_WR : process
	variable current_line	: line; 
begin
	if (d_val_out = '1') then
		write(current_line, v_data_out);
		writeline(results_file, current_line);
	end if;
	wait for 10ns;
		
end process;

end architecture;



