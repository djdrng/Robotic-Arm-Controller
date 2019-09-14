library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 				THIS IS A COMPONENT THAT PROCESSES ERRORS. IT BLINKS THE SEVEN SEGMENT DISPLAYS WHENEVER THERE IS AN ERROR
entity errorProc is port 	(
	clk				: in std_logic := '0';						-- The input clock
	Operand1			: in std_logic_vector(6 downto 0);		
	Operand2			: in std_logic_vector(6 downto 0);
	err				: in std_logic;
	RESULT1			: out std_logic_vector(6 downto 0);
	RESULT2			: out std_logic_vector(6 downto 0)
	);
end errorProc;

architecture proc of errorProc is
	begin
	process(clk, err) is
	begin
		if(err = '1' AND clk = '0') then
			RESULT1 <= "0000000";
			RESULT2 <= "0000000";
		elsif(err = '1' AND clk = '1') then
			RESULT1 <= "1111111";
			RESULT2 <= "1111111";
		else
			RESULT1 <= Operand1;
			RESULT2 <= Operand2;
		end if;		
		
	end process;
end proc;
	