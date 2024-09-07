library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram_ctrl is
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
end bram_ctrl;

architecture Behavioral of bram_ctrl is

signal s_wr_add		: integer range 0 to 256;
signal prev_add		: integer range 0 to 256; 
signal s_rd_add		: integer range 0 to 256;

signal s_counter		: integer range 0 to 256;

signal s_rd_en		: std_logic;
signal s_rd_en_d1	: std_logic;

type states is  (WR, RD, STOP);
signal state : states := WR;


begin 

rd_en		<= s_rd_en;
rd_add		<= std_logic_vector(to_unsigned(s_rd_add, 8));

P_CONTROL : process(rstn, clk)
begin

	if (rstn = '0') then 
	
		s_rd_en			<= '0';
		wr_en			<= '0';
		
		
		wr_add			<= (others => '0');
		wr_data			<= (others => '0');
		
		error			<= '0';
		
		prev_add		<= 0;
		s_rd_add		<= 0;
		s_counter		<= 0;
		
	else 
	
		if rising_edge(clk) then
			prev_add		<= s_rd_add;
			s_rd_en_d1		<= s_rd_en;
			
			if(s_rd_en_d1 = '1') then
				if(std_logic_vector(to_unsigned(prev_add, 8)) = rd_data) then
					error		<=	'0';
				else
					error		<=	'1';
				end if;
			end if;
			
			
			case state is
			
				when WR =>					
					wr_en		<=	'1';
					s_rd_en		<=	'0';
					
					wr_add		<=	std_logic_vector(to_unsigned(s_counter, 8));
					wr_data		<=	std_logic_vector(to_unsigned(s_counter, 8));
					
					
					if(s_counter = 255) then
						state		<=	RD;
						s_counter	<=	0;
					else
						s_counter	<=	s_counter + 1;
					end if;
					
				when RD =>
					s_rd_en		<=	'1';
					wr_en		<=	'0';
					
					
					s_rd_add	<=	s_counter;
					
					
					if(s_counter = 255) then
						state		<=	STOP;
						s_counter	<=	0;
					else
						s_counter	<=	s_counter + 1;
					end if;
				when STOP =>
					s_rd_en			<= '0';
					wr_en			<= '0';				
			end case;
		end if;
	end if;
	
end process;


end architecture;
