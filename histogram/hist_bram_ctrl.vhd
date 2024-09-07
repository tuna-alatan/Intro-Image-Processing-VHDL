library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity hist_bram_ctrl is
	generic(
		x_res			: integer := 640;
		y_res			: integer := 480;
		
		max_count_bits	: integer := integer(ceil(log2(real(x_res * y_res))));
		
		bram_width_bits	: integer := max_count_bits;
		bram_depth_bits	: integer := 8
	);
	
	port (
		clk				: in std_logic;
		rstn			: in std_logic;
		
		rd_en			: out std_logic;
		rd_add			: out std_logic_vector((bram_depth_bits - 1) downto 0);
		rd_data			: in std_logic_vector((bram_width_bits - 1) downto 0);
		
		wr_en			: out std_logic;
		wr_add			: out std_logic_vector((bram_depth_bits - 1) downto 0);
		wr_data			: out std_logic_vector((bram_width_bits - 1) downto 0);
		
		rd_count		: out std_logic_vector((bram_depth_bits - 1) downto 0);
		hist_done		: out std_logic;
		rd_hist			: in std_logic;
		stop_rd			: in std_logic;
		
		d_val			: in std_logic;
		v_data			: in std_logic_vector((bram_depth_bits - 1) downto 0)
	);
end hist_bram_ctrl;

architecture Behvaioral of hist_bram_ctrl is

type states is (IDLE, WR_P0, WR_PX, WR_PX_S, WR_P1, SKIP_1, SKIP_2_1, SKIP_2_2, HIST_RD, RD_STOP);
signal state : states;

constant count_max		: integer := (x_res * y_res) - 1;
constant rd_count_max	: integer := 2**bram_depth_bits - 1;

signal s_count			: integer range 0 to count_max;
signal s_rd_count		: integer range 0 to rd_count_max;
signal x_index			: integer range 0 to x_res;

signal rd_add_d1		: std_logic_vector((bram_depth_bits - 1) downto 0);
signal rd_add_d2		: std_logic_vector((bram_depth_bits - 1) downto 0);
signal rd_add_d3		: std_logic_vector((bram_depth_bits - 1) downto 0);
signal rd_add_d4		: std_logic_vector((bram_depth_bits - 1) downto 0);

signal d_val_d1			: std_logic;
signal d_val_d2			: std_logic;
signal d_val_d3			: std_logic;
signal d_val_d4			: std_logic;

signal v_data_d1		: std_logic_vector((bram_depth_bits - 1) downto 0);
signal v_data_d2		: std_logic_vector((bram_depth_bits - 1) downto 0);
signal v_data_d3		: std_logic_vector((bram_depth_bits - 1) downto 0);
signal v_data_d4		: std_logic_vector((bram_depth_bits - 1) downto 0);


begin

rd_count	<= std_logic_vector(to_unsigned(s_rd_count, bram_depth_bits));



P_MAIN : process(clk, rstn)
begin
	if (rstn = '0') then			
		rd_en			<= '0';	
		rd_add			<= (others => '0');	
		
		wr_en			<= '0';
		wr_add			<= (others => '0');
		wr_data			<= (others => '0');
		
		rd_add_d1		<= (others => '0');
		rd_add_d2		<= (others => '0');
		rd_add_d3		<= (others => '0');
		rd_add_d4		<= (others => '0');
		
		d_val_d1		<= '0';
		d_val_d2		<= '0';
		d_val_d3		<= '0';
		d_val_d4		<= '0';
		
		v_data_d1		<= (others => '0');
		v_data_d2		<= (others => '0');
		v_data_d3		<= (others => '0');
		v_data_d4		<= (others => '0');
		
		s_rd_count		<= 0;
		
		state			<= IDLE;
		
	elsif rising_edge(clk) then
	
		d_val_d1	<= d_val;
		d_val_d2	<= d_val_d1;
		d_val_d3	<= d_val_d2;
		d_val_d4	<= d_val_d3;
	
	
		v_data_d1	<= v_data;
		v_data_d2	<= v_data_d1;
		v_data_d3	<= v_data_d2;
		v_data_d4	<= v_data_d3;
		
		rd_add_d1	<= rd_add;
		rd_add_d2	<= rd_add_d1;
		rd_add_d3	<= rd_add_d2;
		rd_add_d4	<= rd_add_d3;
		
		case state is
			when IDLE		=>
				rd_en			<= '0';	
				wr_en			<= '0';
		
				if (d_val_d1 = '1') then
					state			<= WR_P0;
				end if;
			
			when WR_P0		=>
				rd_en				<= d_val_d2;
				rd_add				<= v_data_d2;
				state				<= WR_P1;
			
			when WR_P1		=>
				rd_en				<= d_val_d2;
				rd_add				<= v_data_d2;
				state				<= WR_PX;			
			
				
			when WR_PX		=>
				rd_en				<= d_val_d2;
				rd_add				<= v_data_d2;
				
				wr_en				<= d_val_d4;
				wr_add				<= rd_add_d1;
			
				if (rd_add_d1 = v_data_d2) and (rd_add_d1 = v_data_d3) and (d_val_d2 = '1') then
					wr_data			<= std_logic_vector(unsigned(rd_data) + to_unsigned(3, bram_width_bits));
					state			<= SKIP_2_1;
				elsif (rd_add_d1 /= v_data_d2) and (rd_add_d1 = v_data_d3) and (d_val_d3 = '1') then
					wr_data			<= std_logic_vector(unsigned(rd_data) + to_unsigned(2, bram_width_bits));
					state			<= SKIP_1;
				elsif (rd_add_d1 = v_data_d2) and (rd_add_d1 /= v_data_d3) and (d_val_d2 = '1') then
					wr_data			<= std_logic_vector(unsigned(rd_data) + to_unsigned(2, bram_width_bits));
					state			<= WR_PX_S;
				else
					wr_data			<= std_logic_vector(unsigned(rd_data) + to_unsigned(1, bram_width_bits));
				end if;
				
				if (s_count = count_max) then
					state			<= HIST_RD;
				end if;
				
				if (x_index = 0) and (d_val_d2 = '1') then
					state			<= WR_P1;
				end if;
			
			when WR_PX_S		=>
				rd_en				<= d_val_d2;
				rd_add				<= v_data_d2;
				
				wr_en				<= d_val_d4;
				wr_add				<= rd_add_d1;
				
				
				if (rd_add_d1 = v_data_d2) and (rd_add_d1 /= v_data_d3) and (d_val_d2 = '1') then
					wr_data				<= std_logic_vector(unsigned(rd_data) + to_unsigned(2, bram_width_bits));
					state				<= SKIP_2_1;
				else 
					wr_data				<= std_logic_vector(unsigned(rd_data) + to_unsigned(1, bram_width_bits));
					state				<= SKIP_1;
				end if;
			
			when SKIP_1			=>
				rd_en				<= d_val_d2;
				rd_add				<= v_data_d2;

				wr_en				<= '0';
				state				<= WR_PX;
			
			when SKIP_2_1		=>
				rd_en				<= d_val_d2;
				rd_add				<= v_data_d2;
			
				wr_en				<= '0';
				state				<= SKIP_2_2;
				
				
			when SKIP_2_2		=>
				rd_en				<= d_val_d2;
				rd_add				<= v_data_d2;

				state				<= WR_PX;
				
			when HIST_RD	=>
				wr_en				<= '0';
				rd_en				<= '1';
				rd_add				<= std_logic_vector(to_unsigned(s_rd_count, bram_depth_bits));
				
				if (s_rd_count = rd_count_max) then
					s_rd_count		<= 0;
					state			<= RD_STOP;
				else
					s_rd_count		<= s_rd_count + 1;
				end if;
			
			when RD_STOP	=>
				rd_en				<= '0';
				rd_add				<= (others => '0');
				
		end case;
	end if;
end process;

P_COUNT : process(clk, rstn)
begin
	if (rstn = '0') then
		s_count		<= 0;
		hist_done	<= '0';
	elsif rising_edge(clk) then
		if (d_val_d2 = '1') then
			
			if (x_index = x_res - 1) then
				x_index			<= 0;
			else
				x_index			<= x_index + 1;
			end if;
			
			if (s_count = count_max) then
				hist_done		<= '1';
				s_count			<= 0;			
			else 
				s_count			<= s_count + 1;
			end if;
		end if;
	end if;
end process;

end architecture;