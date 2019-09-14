library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--					A FOUR BIT COUNTER
entity biCounter4 is port	(
	clk				: in std_logic := '0';						-- The input clock
	resetN			: in std_logic := '0';						-- The reset for the counter
	clkEn				: in std_logic := '0';						-- The enable for the counter 
	up1Down0			: in std_logic := '0';						-- The direction the counter should count, '1' is up, '0' is down 
	counterBits 	: out std_logic_vector(3 downto 0)		-- The output of the counter
);
end entity;

architecture one of biCounter4 is
	signal UDBinCounter 	: unsigned(3 downto 0);
	
begin
	process (clk, resetN) is
	begin
		if (resetN = '0') then
				UDBinCounter <= "0000";
				
		elsif (rising_edge(clk)) then
			if((up1Down0 = '1') AND (clkEn = '1')) then
				UDBinCounter <= (UDBinCounter + 1);
				
			elsif((up1Down0 = '0') AND (clkEn = '1')) then
				UDBinCounter <= (UDBinCounter - 1);
				
			end if;
		end if;
		
		counterBits <= std_logic_vector(UDBinCounter);
	
	end process;
end;