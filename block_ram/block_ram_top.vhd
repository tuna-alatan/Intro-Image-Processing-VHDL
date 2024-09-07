library ieee;
use ieee.std_logic_1164.all;

entity block_ram_top is
	Port (
		clk_out		: out std_logic;
		rstn_out	: out std_logic;
		
		rd_en_out	: out std_logic;
		rd_add_out	: out std_logic_vector(7 downto 0);
		rd_data_out	: out std_logic_vector(7 downto 0);
		
		wr_en_out	: out std_logic;
		wr_add_out	: out std_logic_vector(7 downto 0);
		wr_data_out	: out std_logic_vector(7 downto 0);	
		error_out	: out std_logic
	);
end block_ram_top;

architecture Behavioral of block_ram_top is

component rcg is
	Port (	
		clk :	out std_logic;
		rstn :	out std_logic
	);
end component;

component bram_ctrl is
	port (
		clk		: in std_logic;
		rstn	: in std_logic;
		
		rd_en	: out std_logic;
		rd_add	: out std_logic_vector(7 downto 0);
		rd_data	: in std_logic_vector(7 downto 0);
		
		wr_en	: out std_logic;
		wr_add	: out std_logic_vector(7 downto 0);
		wr_data	: out std_logic_vector(7 downto 0);
		
		error 	: out std_logic
	);
end component;

component bram is
	port (
		clk		: in std_logic;
		rstn	: in std_logic;
		
		rd_en	: in std_logic;
		rd_add	: in std_logic_vector(7 downto 0);
		rd_data	: out std_logic_vector(7 downto 0);
		
		wr_en	: in std_logic;
		wr_add	: in std_logic_vector(7 downto 0);
		wr_data	: in std_logic_vector(7 downto 0)
	);
end component;

signal s_rd_en, s_wr_en, s_clk, s_rstn : std_logic;
signal s_rd_add, s_rd_data, s_wr_add, s_wr_data : std_logic_vector(7 downto 0) := (others => '0');

begin

inst_rcg : rcg
port map (
	clk		=> s_clk,
	rstn	=> s_rstn
);

inst_bram_ctrl : bram_ctrl
port map(
		clk		=> s_clk,
		rstn	=> s_rstn,
				
		rd_en	=> s_rd_en,
		rd_add	=> s_rd_add,
		rd_data	=> s_rd_data,
			
		wr_en	=> s_wr_en,
		wr_add	=> s_wr_add,
		wr_data	=> s_wr_data,
				
		error 	=> error_out
	);
	
inst_bram : bram
port map(
		clk		=> s_clk,
		rstn	=> s_rstn,
				
		rd_en	=> s_rd_en,
		rd_add	=> s_rd_add,
		rd_data	=> s_rd_data,
				
		wr_en	=> s_wr_en,
		wr_add	=> s_wr_add,
		wr_data	=> s_wr_data

	);
	
clk_out		<= s_clk;	
rstn_out	<= s_rstn;	

rd_en_out	<= s_rd_en;
rd_add_out	<= s_rd_add;
rd_data_out	<= s_rd_data;

wr_en_out	<= s_wr_en;
wr_add_out	<= s_wr_add;
wr_data_out	<= s_wr_data;

end Behavioral;
