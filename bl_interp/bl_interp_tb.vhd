library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.fixed_pkg.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity bl_interp_tb is
end entity;

architecture test_bench of bl_interp_tb is

constant x_res					: integer := 640;
constant y_res					: integer := 480;

constant new_w					: integer := 300;
constant new_h					: integer := 480;

constant bram_width				: integer := 8;
constant bram_depth				: integer := 10;

constant fixed_pres				: integer := 4;

signal clk						: std_logic := '0';
signal rstn						: std_logic := '0';

signal s_d_val_d1				: std_logic;
signal s_f_val_d1				: std_logic;

signal d_val, f_val				: std_logic;
signal d_val_out, f_val_out		: std_logic;

signal v_data					: std_logic_vector((bram_width - 1) downto 0);
signal v_data_out				: std_logic_vector((bram_width - 1) downto 0);

file results_file				: text open write_mode is "bl_interp_results.txt"; 
file image_file					: text open read_mode is "output_image.txt"; 

begin

duv : entity work.bl_interp
generic map(
	x_res			=> x_res,	
	y_res			=> y_res,	
	
	new_w			=> new_w,	
	new_h			=> new_h,	

	bram_width		=> bram_width,
	bram_depth		=> bram_depth,
	
	fixed_pres		=> fixed_pres
)
port map(
	clk			=> clk,		
	rstn		=> rstn,	
	
	d_val		=> s_d_val_d1,	
	f_val		=> s_f_val_d1,	
	v_data		=> v_data,	
	
	d_val_out	=> d_val_out,
	f_val_out	=> f_val_out,
	v_data_out	=> v_data_out	
);

inst_frame_valid : entity work.frame_valid
generic map(
	clk_freq	=> 100_000_000.0,
	x_res		=> x_res,
	y_res		=> y_res,
	l2l_w_ns	=> 62800.0
)
port map(
	clk		=> clk,
	rstn	=> rstn,

	f_val	=> f_val,
	d_val	=> d_val
);

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
		if (d_val_out = '1') then
			write(current_line_out, v_data);
			writeline(results_file, current_line_out);
		end if;
	end if;	
end process;

P_RD : process (clk)
	variable current_line_in	: line;
	variable v_v_data			: std_logic_vector((bram_width - 1) downto 0) := (others => '0');
begin
	if rising_edge(clk) then
		s_d_val_d1	<= d_val;
		s_f_val_d1	<= f_val;
		
		if (d_val = '1') then
			readline(image_file, current_line_in);
			read(current_line_in, v_v_data);
			v_data		<= v_v_data;
		else
			v_data		<= (others	=> '0');
		end if;
	end if;
end process;

end architecture;
