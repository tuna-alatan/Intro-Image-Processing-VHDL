library ieee;
use ieee.std_logic_1164.all;

entity test_pattern_top is
	generic(
		clk_freq	: real		:= 100_000_000.0;
		x_res		: integer	:= 640;
		y_res		: integer	:= 480;
		l2l_w_ns	: real		:= 62800.0
	);
	port(
		clk			: in std_logic;
		rstn		: in std_logic;
		
		d_val		: out std_logic;
		f_val		: out std_logic;
		v_data		: out std_logic_vector(7 downto 0)
	);
end test_pattern_top;

architecture Behavioral of test_pattern_top is

component frame_valid is
generic(
	clk_freq	: real := 100_000_000.0;
	x_res		: integer := 640;
	y_res		: integer := 480;
	l2l_w_ns	: real := 62800.0
);
port (
	clk		: in std_logic;
	rstn	: in std_logic;

	f_val	: out std_logic;
	d_val	: out std_logic
);
end component;

component test_pattern_gen is
	port(
		clk			: in std_logic;
		rstn		: in std_logic;
							 
		f_val		: in std_logic;
		d_val		: in std_logic;
		
		d_val_d		: out std_logic;
		f_val_d		: out std_logic;
		v_data		: out std_logic_vector(7 downto 0)
	);
end component;

signal s_d_val, s_f_val			: std_logic;
signal s_d_val_d, s_f_val_d 	: std_logic;
signal s_v_data					: std_logic_vector(7 downto 0);

begin 

inst_frame_valid : frame_valid
generic map(
	clk_freq		=> clk_freq,				
	x_res			=> x_res,				
	y_res			=> y_res,				
	l2l_w_ns		=> l2l_w_ns			
)
port map(
	clk				=> clk,
	rstn			=> rstn,

	f_val			=> s_f_val,
	d_val			=> s_d_val
);


inst_test_pattern_gen : test_pattern_gen
port map(
		clk			=> clk,
		rstn		=> rstn,
							 
		f_val		=> s_f_val,
		d_val		=> s_d_val,
		
		d_val_d		=> d_val,
		f_val_d		=> f_val,
		v_data		=> v_data
	);
	
end architecture;
