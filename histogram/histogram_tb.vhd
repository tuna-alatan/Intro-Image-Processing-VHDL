library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity histogram_tb is
end entity;

architecture test_bench of histogram_tb is

constant x_res					: integer := 640;
constant y_res					: integer := 480;

constant clk_freq				: real := 100_000_000.0;
constant l2l_w_ns				: real := 62800.0;

constant max_count_bits			: integer := integer(ceil(log2(real(x_res * y_res))));	
constant bram_width_bits		: integer := max_count_bits;
constant bram_depth_bits		: integer := 8;

signal clk, rstn				: std_logic := '0';
signal s_f_val, s_d_val			: std_logic;
signal s_f_val_d1, s_d_val_d1	: std_logic;

signal hist_add					: std_logic_vector((bram_depth_bits - 1) downto 0);
signal hist_data				: std_logic_vector((bram_width_bits - 1) downto 0);

signal v_data					: std_logic_vector((bram_depth_bits - 1) downto 0) := (others => '0');

file results_file				: text open write_mode is "histogram_results.txt"; 
file image_file					: text open read_mode is "test_image.txt"; 

begin

duv: entity work.histogram
generic map(
	x_res					=> x_res,
	y_res					=> y_res,
		
	bram_depth_bits			=> bram_depth_bits
)
port map(
	clk						=> clk,			
	rstn	            	=> rstn,

	f_val	            	=> s_f_val_d1,
	d_val	            	=> s_d_val_d1,
	v_data	            	=> v_data,

	hist_add            	=> hist_add,
	hist_data           	=> hist_data
);

inst_frame_valid : entity work.frame_valid
generic map(
	clk_freq				=> clk_freq,
	x_res					=> x_res,
	y_res					=> y_res,
	l2l_w_ns				=> l2l_w_ns
)
port map(
	clk						=> clk,
	rstn					=> rstn,
	
	f_val					=> s_f_val,
	d_val					=> s_d_val
);

--inst_diag_test_pattern : entity work.horiz_test_pattern_gen
--port map(
--	clk						=> clk,
--	rstn					=> rstn,
--
--	f_val					=> s_f_val,
--	d_val					=> s_d_val,
--
--	d_val_d					=> s_d_val_d1,
--	f_val_d					=> s_f_val_d1,
--	v_data					=> v_data
--);

rstn	<= '0', '1' after 10us;

P_CLK : process
begin
	clk		<= not clk;
	wait for 5ns;
end process;

P_WR : process (clk)
	variable current_line_out	: line; 
begin
	if rising_edge(clk) then
		if (s_d_val_d1 = '1') then
			write(current_line_out, v_data);
			writeline(results_file, current_line_out);
		end if;
	end if;	
end process;

P_RD : process (clk)
	variable current_line_in	: line;
	variable v_v_data			: std_logic_vector((bram_depth_bits - 1) downto 0) := (others => '0');
begin
	if rising_edge(clk) then
		if (s_d_val = '1') then
			readline(image_file, current_line_in);
			read(current_line_in, v_v_data);
			v_data		<= v_v_data;
		else
			v_data		<= (others	=> '0');
		end if;
	end if;
end process;

P_DELAY : process (clk)
begin
	if rising_edge(clk) then
		s_d_val_d1	<= s_d_val;
		s_f_val_d1	<= s_f_val;
	end if;
end process;


end architecture;
