library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------------------------------------------
-- 				A single bit comparator
--					Takes in 2 bits and outputs a 3 bit vector
--
entity Compx1 is port	(
	A 			:	in std_logic;												-- Input bit A
	B 			:	in std_logic;												-- Input bit B
	RESULT	: 	out std_logic_vector(2 downto 0)						-- BIT 0 is 1 when A < B
																					-- BIT 1 is 1 when A = B
																					-- BIT 2 is 1 when A > B
);
end Compx1;

architecture comparator of Compx1 is 

begin

	RESULT(0) <= (NOT A) AND B;											-- A is less than B when A'B
	RESULT(1) <= A XNOR B;													-- A is equal to B when AB + A'B' => A XNOR B
	RESULT(2) <= A AND (NOT B);											-- A is greater than B when AB'
	
end comparator;