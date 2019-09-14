library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- 2-Input Mux that controls whether the target position or the current position is shown on the displays
-- The selector is pb(3)

entity mux2 is port (
	Operand1					: in	std_logic_vector(3 downto 0);				-- The input, will be the target position
	Operand2					: in  std_logic_vector(3 downto 0);				-- The input, will be the current position
	selector					: in	std_logic;										-- The selector for the mux, will be either pb(2) or pb(3)				
	RESULT					: out std_logic_vector(3 downto 0)				-- The output of the mux							
); 
end mux2;

architecture mux of mux2 is
		
begin

	with selector select 
	RESULT <= Operand1 when '1',													-- Sends the target position when not pressed
				 Operand2 when '0';													-- Sends the current position when the button is pressed
			
end architecture mux; 
