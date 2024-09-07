library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity histogram is
	generic(
		x_res			: integer := 640;
		y_res			: integer := 480;
		
		max_count_bits	: integer := integer(ceil(log2(real(x_res * y_res))));
		
		bram_width_bits	: integer := max_count_bits;
		bram_depth_bits	: integer := 8
	);
	
	port(
		clk				: in std_logic;
		rstn			: in std_logic;
		
		f_val			: in std_logic;	
		d_val			: in std_logic;	
		v_data			: in std_logic_vector(7 downto 0);	
		
		hist_add		: out std_logic_vector(7 downto 0);
		hist_data		: out std_logic_vector((max_count_bits - 1) downto 0)
	);
end histogram;

architecture Behavioral of histogram is

component hist_bram_ctrl is
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

constant rd_count_max			: integer := 2**bram_depth_bits - 1;

signal s_rd_en, s_wr_en			: std_logic;
signal s_rd_add, s_wr_add		: std_logic_vector((bram_depth_bits - 1) downto 0);
signal s_rd_count_d1			: std_logic_vector((bram_depth_bits - 1) downto 0);
signal s_rd_count_d2			: std_logic_vector((bram_depth_bits - 1) downto 0);
signal s_rd_data, s_wr_data		: std_logic_vector((bram_width_bits - 1) downto 0);

signal s_rd_count				: std_logic_vector((bram_depth_bits - 1) downto 0);
signal rd_hist					: std_logic;
signal stop_rd					: std_logic;
signal s_hist_done				: std_logic;

begin

inst_hist_bram_ctrl : hist_bram_ctrl
generic map(
	x_res				=> x_res,			
	y_res			    => y_res,
	
	bram_depth_bits		=> bram_depth_bits
)
port map(
	clk					=> clk,		
	rstn				=> rstn,	
	
	rd_en				=> s_rd_en,	
	rd_add				=> s_rd_add,	
	rd_data				=> s_rd_data,	
	
	wr_en				=> s_wr_en,	
	wr_add				=> s_wr_add,	
	wr_data				=> s_wr_data,

	rd_count			=> s_rd_count,
	hist_done			=> s_hist_done,
	rd_hist				=> rd_hist,
	stop_rd				=> stop_rd,
	
	d_val				=> d_val,	
	v_data				=> v_data	
);

inst_bram : bram
generic map(
	width_bits		=> bram_width_bits,
	depth_bits		=> bram_depth_bits
)

port map (
	clk				=> clk,
	rstn			=> rstn,
	
	rd_en			=> s_rd_en,
	rd_add			=> s_rd_add,
	rd_data			=> s_rd_data,
	
	wr_en			=> s_wr_en,
	wr_add			=> s_wr_add,
	wr_data			=> s_wr_data
);


P_MAIN : process(clk, rstn)
begin
	if (rstn = '0') then
		hist_add		<= (others => '0');
		hist_data		<= (others => '0');
		rd_hist			<= '0';
		stop_rd			<= '0';
	elsif rising_edge(clk) then
		s_rd_count_d1		<= s_rd_count;
		s_rd_count_d2		<= s_rd_count_d1;
	
		if (s_hist_done = '1') then	
			rd_hist	<= '1';
			hist_add	<= s_rd_count_d2;
			hist_data	<= s_rd_data;
			
			if(to_integer(unsigned(s_rd_count)) = rd_count_max) then
				rd_hist	<= '0';
				stop_rd	<= '1';
			end if;
		end if;
	end if;
end process;

end architecture;

