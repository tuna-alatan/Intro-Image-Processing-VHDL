library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity frame_valid is
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
end entity;

architecture Behavioral of frame_valid is


constant l2l_lim : integer := integer(trunc((clk_freq / 1_000_000_000.0)* l2l_w_ns));

signal counter		: integer range 0 to l2l_lim;
signal d_counter	: integer range -1 to y_res;

signal s_d_val, s_f_val : std_logic;

type states is (F_LOW, D_HIGH, D_LOW, D_LOW_END);
signal state : states := F_LOW;

begin



d_val <= s_d_val;
f_val <= s_f_val;

P_MAIN : process(rstn, clk)
begin
	if (rstn = '0') then
		s_d_val			<= '0';
		s_f_val			<= '0';
		counter			<= 0;
	
	else 
		if rising_edge(clk) then
			case state is
				when F_LOW =>
				
					s_d_val				<= '0';
					s_f_val				<= '0';
				
					if (counter = l2l_lim - 1) then
						counter			<= 0;
						state			<= D_LOW;
					else
						counter			<= counter + 1;
					end if;
					
				when D_LOW =>
					
					s_d_val				<= '0';
					s_f_val				<= '1';
				
					if (counter = l2l_lim - 1) then
						counter			<= 0;
						state			<= D_HIGH;
					else
						counter			<= counter + 1;
					end if;
					
				when D_HIGH =>
				
					s_d_val				<= '1';
					s_f_val				<= '1';

					
					if (counter = x_res - 1) then
						if (d_counter = y_res - 1) then
							counter		<= 0;
							state		<= D_LOW_END;
						else
							counter		<= 0;
							state		<= D_LOW;
						end if;
					else
						counter		<= counter + 1;
					end if;
					
				when D_LOW_END =>
				
					s_d_val		<= '0';
					s_f_val		<= '1';
					
					if (counter = l2l_lim - 1) then
						counter		<= 0;
						state		<= F_LOW;
					else
						counter		<= counter + 1;
					end if;
					
			end case;
		end if;
	end if;
end process;



P_DATA : process(rstn, s_d_val)
begin
	if (rstn = '0') then
		d_counter		<= -1;
	elsif rising_edge(s_d_val) then
		if (d_counter = y_res - 1) then
			d_counter		<= 0;
		else
			d_counter		<= d_counter + 1;
		end if;
	end if;
	
end process;

end Behavioral;
