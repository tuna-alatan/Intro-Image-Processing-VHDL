library ieee;
use ieee.std_logic_1164.all;

entity block_ram_tb is
end entity;

architecture test_bench of block_ram_tb is
	signal error_out		: std_logic := '0';
	signal clk_out		: std_logic := '0';
	signal rstn_out		: std_logic := '0';

	signal rd_en_out	: std_logic := '0';
	signal rd_add_out	: std_logic_vector(7 downto 0) := (others => '0');
	signal rd_data_out	: std_logic_vector(7 downto 0);
	 
	signal wr_en_out	: std_logic := '0';
	signal wr_add_out	: std_logic_vector(7 downto 0) := (others => '0');
	signal wr_data_out	: std_logic_vector(7 downto 0) := (others => '0');	
	
begin
	duv : entity work.block_ram_top
	port map (
		clk_out		=> clk_out,	
	    rstn_out	=> rstn_out,	
	    			
	    rd_en_out	=> rd_en_out,
	    rd_add_out	=> rd_add_out,
	    rd_data_out	=> rd_data_out,
	    			
	    wr_en_out	=> wr_en_out,
	    wr_add_out	=> wr_add_out,
	    wr_data_out	=> wr_data_out,
		error_out	=> error_out
	);
	
end architecture;
