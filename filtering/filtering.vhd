library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity filtering is
	generic(
		x_res			: integer := 640;
		y_res			: integer := 480;
		
		bram_width_bits : integer := 8;
		bram_depth_bits : integer := 10;
		
		x_index_bits 	: integer := integer(ceil(log2(real(x_res))));
		y_index_bits 	: integer := integer(ceil(log2(real(y_res))))
	);
	
	port(
		clk				: in std_logic;
		rstn			: in std_logic;
		
		v_data_in		: in std_logic_vector(7 downto 0);
		v_data_out		: out std_logic_vector(7 downto 0);
		
		d_val_in		: in std_logic;
		f_val_in		: in std_logic;
		
		d_val_out		: out std_logic;
		f_val_out		: out std_logic
	);
end filtering;

architecture Behavioral of filtering is

component bram_controller is
	generic (
		x_res			: integer := 640;
		y_res			: integer := 480;
	
		width_bits		: integer := 8;
		depth_bits		: integer := 10;
		
		x_index_bits 	: integer := integer(ceil(log2(real(x_res))));
		y_index_bits 	: integer := integer(ceil(log2(real(y_res))))
	);

	port (
		clk			: in std_logic;
		rstn		: in std_logic;
		
		v_data		: in std_logic_vector(7 downto 0);
		d_val		: in std_logic;
		
		rd_en_1		: out std_logic;
		rd_add_1	: out std_logic_vector((depth_bits - 1) downto 0);
		rd_data_1	: in std_logic_vector((width_bits - 1) downto 0);
		
		rd_en_2		: out std_logic;
		rd_add_2	: out std_logic_vector((depth_bits - 1) downto 0);
		rd_data_2	: in std_logic_vector((width_bits - 1) downto 0);
		
		
		wr_en_1		: out std_logic;
		wr_add_1	: out std_logic_vector((depth_bits - 1) downto 0);
		wr_data_1	: out std_logic_vector((width_bits - 1) downto 0);
		
		wr_en_2		: out std_logic;
		wr_add_2	: out std_logic_vector((depth_bits - 1) downto 0);
		wr_data_2	: out std_logic_vector((width_bits - 1) downto 0);
		
		l_0_p_0		: out std_logic_vector((width_bits - 1) downto 0);
		l_0_p_1		: out std_logic_vector((width_bits - 1) downto 0);
		l_0_p_2		: out std_logic_vector((width_bits - 1) downto 0);
		
		l_1_p_0		: out std_logic_vector((width_bits - 1) downto 0);
		l_1_p_1		: out std_logic_vector((width_bits - 1) downto 0);
		l_1_p_2		: out std_logic_vector((width_bits - 1) downto 0);
		
		l_2_p_0		: out std_logic_vector((width_bits - 1) downto 0);
		l_2_p_1		: out std_logic_vector((width_bits - 1) downto 0);
		l_2_p_2		: out std_logic_vector((width_bits - 1) downto 0);
		
		d_val_out	: out std_logic;
		
		x_index		: out std_logic_vector((x_index_bits - 1) downto 0);
		y_index		: out std_logic_vector((y_index_bits - 1) downto 0)
	);
end component;

component bram is
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
end component;

type int_array is array (0 to 8) of integer range 0 to 3;
constant coef 								: int_array := (1, 1, 1, 1, 1, 1, 1, 1, 1);

signal s_rd_en_1, s_rd_en_2					: std_logic;
signal s_wr_en_1, s_wr_en_2					: std_logic;

signal s_rd_add_1, s_rd_add_2				: std_logic_vector((bram_depth_bits - 1) downto 0);
signal s_wr_add_1, s_wr_add_2				: std_logic_vector((bram_depth_bits - 1) downto 0);

signal s_rd_data_1, s_rd_data_2				: std_logic_vector((bram_width_bits - 1) downto 0);
signal s_wr_data_1, s_wr_data_2				: std_logic_vector((bram_width_bits - 1) downto 0);

signal s_l_0_p_0, s_l_0_p_1, s_l_0_p_2		: std_logic_vector((bram_width_bits - 1) downto 0);
signal s_l_1_p_0, s_l_1_p_1, s_l_1_p_2		: std_logic_vector((bram_width_bits - 1) downto 0);
signal s_l_2_p_0, s_l_2_p_1, s_l_2_p_2		: std_logic_vector((bram_width_bits - 1) downto 0);

signal s_x_index							: integer range 0 to x_res;
signal s_y_index							: integer range 0 to y_res;

signal x_index								: std_logic_vector((x_index_bits - 1) downto 0);
signal y_index								: std_logic_vector((y_index_bits - 1) downto 0);

signal s_v_data_out							: integer range 0 to 4095;
signal s_d_val_out							: std_logic;
signal s_d_val_out_d1						: std_logic := '0';

signal s_f_val_d1							: std_logic;
signal s_f_val_d2							: std_logic;
signal s_f_val_d3							: std_logic;
signal s_f_val_d4							: std_logic;
signal s_f_val_d5							: std_logic;

begin

inst_bram_controller_1 : bram_controller
generic map(
	width_bits		=> bram_width_bits,
	depth_bits		=> bram_depth_bits
)
port map(
	clk				=> clk,
	rstn			=> rstn,
			
	v_data			=> v_data_in,
	d_val			=> d_val_in,
				
	rd_en_1			=> s_rd_en_1,
	rd_add_1		=> s_rd_add_1,
	rd_data_1		=> s_rd_data_1,
		
	rd_en_2			=> s_rd_en_2,
	rd_add_2		=> s_rd_add_2,
	rd_data_2		=> s_rd_data_2,
		
		
	wr_en_1			=> s_wr_en_1,
	wr_add_1		=> s_wr_add_1,
	wr_data_1		=> s_wr_data_1,
		
	wr_en_2			=> s_wr_en_2,
	wr_add_2		=> s_wr_add_2,
	wr_data_2		=> s_wr_data_2,
	
	l_0_p_0			=> s_l_0_p_0,
	l_0_p_1			=> s_l_0_p_1,
	l_0_p_2			=> s_l_0_p_2,
				    
	l_1_p_0			=> s_l_1_p_0,
	l_1_p_1			=> s_l_1_p_1,
	l_1_p_2			=> s_l_1_p_2,
				    
	l_2_p_0			=> s_l_2_p_0,
	l_2_p_1			=> s_l_2_p_1,
	l_2_p_2			=> s_l_2_p_2,
		
	d_val_out		=> s_d_val_out,
	
	x_index			=> x_index,
	y_index			=> y_index
);

inst_bram_1 : bram
generic map(
	width_bits		=> bram_width_bits,
	depth_bits		=> bram_depth_bits
)

port map (
	clk				=> clk,
	rstn			=> rstn,
	
	rd_en			=> s_rd_en_1,
	rd_add			=> s_rd_add_1,
	rd_data			=> s_rd_data_1,
	
	wr_en			=> s_wr_en_1,
	wr_add			=> s_wr_add_1,
	wr_data			=> s_wr_data_1
);
	
inst_bram_2 : bram
generic map(
	width_bits		=> bram_width_bits,
	depth_bits		=> bram_depth_bits
)

port map (
	clk				=> clk,
	rstn			=> rstn,
	
	rd_en			=> s_rd_en_2,
	rd_add			=> s_rd_add_2,
	rd_data			=> s_rd_data_2,
	
	wr_en			=> s_wr_en_2,
	wr_add			=> s_wr_add_2,
	wr_data			=> s_wr_data_2
);

v_data_out				<= std_logic_vector(to_unsigned(s_v_data_out, 8));
d_val_out				<= s_d_val_out_d1;
f_val_out				<= s_f_val_d5;

s_x_index				<= to_integer(unsigned(x_index));
s_y_index				<= to_integer(unsigned(y_index));

P_MAIN : process(rstn, clk) 
begin
	if (rstn = '0') then
		s_v_data_out		<= 0;
		
		s_f_val_d1			<= '0';
		s_f_val_d2			<= '0';
		s_f_val_d3			<= '0';
		s_f_val_d4			<= '0';
		s_f_val_d5			<= '0';
		
	elsif rising_edge(clk) then
		s_f_val_d1				<= f_val_in;
		s_f_val_d2				<= s_f_val_d1;
		s_f_val_d3				<= s_f_val_d2;
		s_f_val_d4				<= s_f_val_d3;
		s_f_val_d5				<= s_f_val_d4;
		
		s_d_val_out_d1			<= s_d_val_out;
		
		if (((s_x_index = 0) or (s_x_index = x_res - 1)) or ((s_y_index = 0) or (s_y_index = y_res - 1))) then
			s_v_data_out		<= 0;
		else	
			s_v_data_out	<= integer((real(to_integer(unsigned(s_l_0_p_0)) * coef(0) + to_integer(unsigned(s_l_0_p_1)) * coef(1) + 
											to_integer(unsigned(s_l_0_p_2)) * coef(2) +	to_integer(unsigned(s_l_1_p_0)) * coef(3) + 
											to_integer(unsigned(s_l_1_p_1)) * coef(4) + to_integer(unsigned(s_l_1_p_2)) * coef(5)+
											to_integer(unsigned(s_l_2_p_0)) * coef(6) + to_integer(unsigned(s_l_2_p_1)) * coef(7) + 
											to_integer(unsigned(s_l_2_p_2)) * coef(8)) * 1111.0) / 10000.0);
		end if;
	end if;
end process;

end architecture;