library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Moore_SM1 is port (
	clk		     	: in  std_logic := '0';
   resetN      	: in  std_logic := '0';
	extButton		: in  std_logic := '1';
	extEn				: in  std_logic := '0';
	extPos			: in  std_logic_vector(3 downto 0);
	clkEn				: out std_logic;
	extOut			: out std_logic;													-- When this is '0', it means the arm is retracted, '1' otherwise
	shiftDir 		: out std_logic;
	grplEn			: out std_logic													-- When this is '1', it means the arm is extended, '0' otherwise
	);
end entity;

architecture sm of Moore_SM1 is

-- list all the STATES  
   type states is (init, Retracted, Retracting, Extending, Extended);   

   signal currentState, nextState	:  states;       -- currentState, nextState signals are of type states

begin
	register_section: process(clk, resetN, nextState) -- creates sequential logic to store the state. The resetN is used to asynchronously clear the register
   begin
		if (resetN = '0') then
			currentState <= init;
		elsif (rising_edge(clk)) then
			currentState <= nextState; -- on the rising edge of clock the current state is updated with next state
		end if;
   end process;
	
	transition_logic: process(extEn, extButton, currentState, extPos) -- logic to determine next state. 
   begin
		case currentState is
			when init =>		
				nextState <= Retracted;
				
			when Retracting =>		
				if (extPos = "0000") then 
					nextState <= Retracted;
				else
					nextState <= Retracting;
				end if;

			when Extending =>	
				if (extPos = "1111") then 
               nextState <= Extended;
				else
					nextState <= Extending;
				end if;
			when Retracted =>
				if (extEn = '1' AND extButton = '0') then
					nextState <= Extending;
				else
					nextState <= Retracted;
				end if;	        
			when Extended =>
				if (extEn = '1' AND extButton = '0') then
					nextState <= Retracting;
				else
					nextState <= Extended;
				end if;
			when others =>
				nextState <= init;
					
 		end case;
 end process;

moore_decoder: process(currentState) 			-- logic to determine outputs from state machine states
   begin
		case currentState is
			when init =>		
				extOut 	<= '0';
				grplEn 	<= '0';
				clkEn 	<= '0';
				
			when Retracting =>		
				extOut 	<= '1';
				grplEn 	<= '0';
				clkEn  	<= '1';
				shiftDir <= '0';
				
			when Extending =>
				extOut 	<= '1';
				grplEn 	<= '0';
				clkEn 	<= '1';
				shiftDir <= '1';
							 
			when Retracted =>
				extOut 	<= '0';
				grplEn 	<= '0';
		
			when Extended =>
				extOut 	<= '1';
				grplEn 	<= '1';
				clkEn 	<= '0';
			 
			when others =>
				extOut 	<= '1';
				grplEn 	<= '0';
				clkEn 	<= '0';
			 
		end case;
	end process;
end sm;
