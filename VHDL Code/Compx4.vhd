library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------------------------------------------
-- 				A four bit comparator
--					Takes in two 4 bit vectors and outputs a 3 bit vector
--

entity Compx4 is port	(
	INPUTA			: 	in std_logic_vector(3 downto 0);					-- Input vector A
	INPUTB			: 	in std_logic_vector(3 downto 0);					-- Input vector B
	RESULT 			: 	out std_logic_vector(2 downto 0)					-- BIT 0 is 1 when A < B
																						-- BIT 1 is 1 when A = B
																						-- BIT 2 is 1 when A > B
);
end Compx4;

architecture comparator of Compx4 is 

	component Compx1 is port	(												-- Includes the one bit comparator as a component
	
		A 			:	in std_logic;												-- Input bit A								
		B 			:	in std_logic;												-- Input bit B
		RESULT	: 	out std_logic_vector(2 downto 0)						-- BIT 0 is 1 when A < B
																						-- BIT 1 is 1 when A = B
																						-- BIT 2 is 1 when A > B
	);
	end component;
	
	signal COMP0	: 	std_logic_vector(2 downto 0);						-- The output of the comparision of the 0th bits
	signal COMP1	: 	std_logic_vector(2 downto 0);						-- The output of the comparision of the 1st bits
	signal COMP2	: 	std_logic_vector(2 downto 0);						-- The output of the comparision of the 2nd bits
	signal COMP3	: 	std_logic_vector(2 downto 0);						-- The output of the comparision of the 3rd bits

begin
	
	RESULT(0) <= COMP3(0) OR (COMP2(0) AND COMP3(1)) OR (COMP1(0) AND COMP3(1) AND COMP2(1)) OR (COMP0(0) AND COMP3(1) AND COMP2(1) AND COMP1(1));
	RESULT(1) <= COMP3(1) AND COMP2(1) AND COMP1(1) AND COMP0(1);
	RESULT(2) <= COMP3(2) OR (COMP2(2) AND COMP3(1)) OR (COMP1(2) AND COMP3(1) AND COMP2(1)) OR (COMP0(2) AND COMP3(1) AND COMP2(1) AND COMP1(1));
	
																						-- The boolean expressions required to evaluate the comparision

	INST1:	Compx1 port map(INPUTA(0), INPUTB(0), COMP0);			-- The one bit comparator for the 0th bits
	INST2:	Compx1 port map(INPUTA(1), INPUTB(1), COMP1);			-- The one bit comparator for the 1st bits
	INST3:	Compx1 port map(INPUTA(2), INPUTB(2), COMP2);			-- The one bit comparator for the 2nd bits
	INST4:	Compx1 port map(INPUTA(3), INPUTB(3), COMP3);			-- The one bit comparator for the 3rd bits
	
end comparator;