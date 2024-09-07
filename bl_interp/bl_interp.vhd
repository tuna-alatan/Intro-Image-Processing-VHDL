library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.fixed_pkg.all;

entity bl_interp is
	generic(
		y_res		: integer;
		x_res		: integer;
		
		new_w		: integer;
		new_h		: integer;
		
		x_bits		: integer := integer(ceil(log2(real(x_res))));
		y_bits		: integer := integer(ceil(log2(real(y_res))));
		
		bram_width	: integer;
		bram_depth	: integer;
		
		fixed_pres	: integer
	);
	
	port(
		clk			: in std_logic;
		rstn		: in std_logic;
		
		d_val		: in std_logic;
		f_val		: in std_logic;
		v_data		: in std_logic_vector;
		
		d_val_out	: out std_logic;
		f_val_out	: out std_logic;
		v_data_out	: out std_logic_vector((bram_width - 1) downto 0) 
	);
end entity;

architecture Behvaioral of bl_interp is

component bl_bram_ctrl is
	generic (
		x_res			: integer;
		y_res			: integer;
		
		new_w			: integer;
		new_h			: integer;
		
		x_bits			: integer := integer(ceil(log2(real(x_res))));
		y_bits			: integer := integer(ceil(log2(real(y_res))));
		
		bram_width		: integer;
		bram_depth		: integer;
		
		fixed_pres		: integer
	);
	port (
		clk				: in std_logic;
		rstn			: in std_logic;
		
		f_val			: in std_logic;
		d_val			: in std_logic;
		v_data			: in std_logic_vector((bram_width - 1) downto 0);
		
		f_val_out		: out std_logic;
		d_val_out		: out std_logic;
		
		wr_en			: out std_logic;
		wr_add			: out std_logic_vector((bram_depth - 1) downto 0);
		wr_data			: out std_logic_vector((bram_width - 1) downto 0);
		
		rd_en			: out std_logic;
		rd_add			: out std_logic_vector((bram_depth - 1) downto 0);
		rd_data			: in std_logic_vector((bram_width - 1) downto 0);
		
		y_l				: out std_logic_vector((y_bits - 1) downto 0);
		
		c 				: out std_logic_vector((bram_width - 1) downto 0);
		d 				: out std_logic_vector((bram_width - 1) downto 0);
		
		mapped_y_out	: out ufixed((x_bits - 1) downto -fixed_pres)
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

type states is (IDLE, H_PX);
signal state		: states;

signal s_d_val, s_f_val				: std_logic;
signal s_d_val_d1, s_f_val_d1		: std_logic;

signal a							: std_logic_vector((bram_width - 1) downto 0);
signal b							: std_logic_vector((bram_width - 1) downto 0);
signal c							: std_logic_vector((bram_width - 1) downto 0);
signal d							: std_logic_vector((bram_width - 1) downto 0);

signal mapped_x_out					: ufixed((x_bits - 1) downto -fixed_pres);
signal mapped_y_out					: ufixed((x_bits - 1) downto -fixed_pres);

signal x_l 							: std_logic_vector((x_bits - 1) downto 0);
signal y_l 							: std_logic_vector((y_bits - 1) downto 0);

signal x_weight						: ufixed((bram_width - 1) downto -fixed_pres);
signal y_weight						: ufixed((bram_width - 1) downto -fixed_pres);

signal mapped_x						: real;
				
signal h_v_data						: std_logic_vector((bram_width - 1) downto 0); 
signal v_data_d1					: std_logic_vector((bram_width - 1) downto 0); 
signal v_data_d2					: std_logic_vector((bram_width - 1) downto 0);  
				
signal new_x_index					: integer range 0 to new_w;
signal x_index						: integer range 0 to x_res;
				
signal d_val_d1						: std_logic;

signal wr_en, rd_en					: std_logic;
signal wr_add, rd_add				: std_logic_vector((bram_depth - 1) downto 0);
signal wr_data, rd_data				: std_logic_vector((bram_width - 1) downto 0);

begin


d_val_out		<= s_d_val_d1;
f_val_out		<= s_f_val_d1;

v_data_out		<= h_v_data;

x_weight		<= resize(mapped_x_out - to_ufixed(unsigned(x_l), x_bits - 1, -fixed_pres), bram_width - 1, -fixed_pres);
mapped_x_out	<= to_ufixed(((real((new_x_index - 1)) * real((x_res - 1))) / real((new_w - 1))), x_bits - 1, -fixed_pres);



P_MAIN : process(clk, rstn)
begin
	if (rstn = '0') then
		s_d_val_d1		<= '0';
		s_f_val_d1		<= '0';
	elsif rising_edge(clk) then
		s_d_val_d1		<= s_d_val;
		s_f_val_d1		<= s_f_val;
		
	end if;
end process;

P_HORIZ : process(clk, rstn)
begin
	if (rstn = '0') then
		s_f_val				<= '0';
		s_d_val				<= '0';
		
		h_v_data			<= (others => '0');
		
		a					<= (others => '0');
		b					<= (others => '0');
		
		x_l					<= (others => '0');
		
		v_data_d1			<= (others => '0');
		v_data_d2			<= (others => '0');
		
		mapped_x			<= 0.0;
		new_x_index			<= 0;
		
	elsif rising_edge(clk) then
		v_data_d1		<= v_data;		
		v_data_d2		<= v_data_d1;
		
		d_val_d1		<= d_val;	

		h_v_data		<= std_logic_vector(resize(to_ufixed(unsigned(a), bram_width - 1, -fixed_pres) * (to_ufixed(1, bram_width - 1, -fixed_pres) - x_weight)
													+ to_ufixed(unsigned(b), bram_width -1, -fixed_pres) * x_weight, bram_width - 1, 0));
		
		case state is
			when IDLE		=>
				s_d_val			<= '0';
				mapped_x		<= 0.0;
				if (d_val = '1') then
					state		<= H_PX;
				end if;

			when H_PX		=>
				if (integer(floor(mapped_x)) = x_index) then
					s_d_val			<= '1';
					
					a				<= v_data_d1;
					b				<= v_data_d1 when (x_index = 0) or (x_index = x_res - 1) else
										v_data;
										
					mapped_x		<= (real((new_x_index + 1)) * real((x_res - 1))) / real((new_w - 1));
					x_l				<= std_logic_vector(to_unsigned((x_index ), x_bits));
					new_x_index		<= 0 when (new_x_index = new_w - 1) else
										new_x_index + 1;
				else
					s_d_val			<= '0';
				end if;
				
				state			<= IDLE when (x_index = x_res - 1) else
									H_PX;
									
		end case;
	end if;
end process;

P_COUNT : process(clk, rstn)
begin
	if (rstn = '0') then
		x_index		<= 0;
	elsif rising_edge(clk) then
		if (d_val_d1 = '1') then
			if (x_index = x_res - 1) then
				x_index		<= 0;
			else
				x_index		<= x_index + 1;
			end if;
		end if;
	end if;
end process;



end architecture;