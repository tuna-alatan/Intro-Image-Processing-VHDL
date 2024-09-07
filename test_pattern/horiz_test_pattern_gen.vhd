library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity horiz_test_pattern_gen is
	port(
		clk			: in std_logic;
		rstn		: in std_logic;
							 
		f_val		: in std_logic;
		d_val		: in std_logic;
		
		d_val_d		: out std_logic;
		f_val_d		: out std_logic;
		v_data		: out std_logic_vector(7 downto 0)
	);
end entity;

architecture Behavioral of horiz_test_pattern_gen is

type states is (F_LOW, D_LOW, D_HIGH);

signal state : states;

signal counter				: integer range 0 to 255;
signal l_counter			: integer range 0 to 255;

signal d_val_d1, f_val_d1	: std_logic;
signal d_val_d2, f_val_d2	: std_logic;

begin

d_val_d		<= d_val_d2;
f_val_d		<= f_val_d2;

P_MAIN : process (clk, rstn) 
begin
	if (rstn = '0') then
		d_val_d1		<= '0';
		f_val_d1		<= '0';
		
		d_val_d2		<= '0';
		f_val_d2		<= '0';
		
		v_data			<= (others => '0');
		state			<= F_LOW;
		counter			<= 0;
	else
		if rising_edge(clk) then
			f_val_d1				<= f_val;
			d_val_d1				<= d_val;
			
			f_val_d2				<= f_val_d1;
			d_val_d2				<= d_val_d1;
			
			
			v_data			<= std_logic_vector(to_unsigned(l_counter, 8));
			
			
			case state is
				when F_LOW =>
					v_data			<= (others => '0');
					
					if (f_val = '1') then
						state		<= D_LOW;
					end if;
					
				when D_LOW =>
					v_data			<= (others => '0');
					
					if (d_val = '1') then
						counter		<= l_counter;
						state		<= D_HIGH;
					elsif (f_val = '0') then
						state		<= F_LOW;
					end if;
					
				when D_HIGH =>
							
					if (d_val = '0') then
						counter		<= 0;
						state		<= D_LOW;
					end if;
					
			end case;
		end if;
	end if;
end process;

P_LINE : process(d_val_d2, rstn)
begin
	if (rstn = '0') then
		l_counter				<= 0;
	else
		if falling_edge(d_val_d2) then
			if(l_counter = 255) then
				l_counter		<= 0;
			else
				l_counter		<= l_counter + 1;
			end if;
		end if;
	end if;
end process;

end architecture;

