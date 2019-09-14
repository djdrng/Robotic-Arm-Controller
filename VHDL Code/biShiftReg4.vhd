library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity biShiftReg4 is port	(
	clk 				: in std_logic := '0';
	resetN			: in std_logic := '0';
	clkEn				: in std_logic := '0';
	left0Right1		: in std_logic := '0';
	regBits			: out std_logic_vector(3 downto 0)
	);
end entity;

architecture one of biShiftReg4 is
	signal sreg		: std_logic_vector(3 downto 0);
	
begin
	process (clk, resetN) is
	begin 
		if (resetN = '0') then
			sreg <= "0000";
		
		elsif (rising_edge(clk) AND (clkEn = '1')) then 
		
			if(left0Right1 = '1') then
				sreg(3 downto 0) <= '1' & sreg(3 downto 1);
		
			elsif(left0Right1 = '0') then
				sreg(3 downto 0) <= sreg(2 downto 0) & '0';
			
			end if;	
		end if;
		regBits <= sreg;
	end process;
end one;