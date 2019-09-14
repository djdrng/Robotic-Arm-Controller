library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity Moore_SM2 is port (
	clk		     		: in  std_logic := '0';
   resetN      		: in  std_logic := '0';
	grapButton			: in  std_logic := '0';
	grapEn				: in  std_logic := '0';
   grapOn		  		: out std_logic
	);
end entity;

architecture sm of Moore_SM2 is

-- list all the states  
   type states is (init, grapOpen, grapClosed);   

   signal currentState, nextState	:  states;       -- currentState, nextState signals are of type states

begin

	register_section: process(clk, resetN, nextState) -- creates sequential logic to store the state. The rst_n is used to asynchronously clear the register
	begin
		if (resetN = '0') then
			currentState <= init;
		elsif (rising_edge(clk)) then
			currentState <= nextState; -- on the rising edge of clock the current state is updated with next state
		end if;
	end process;
	

	transition_logic: process(grapEn, grapButton, currentState) -- logic to determine next state. 
   begin
		case currentState is
			when init =>		
            if (grapEn = '1') then 
               nextState <= grapOpen;
				else
               nextState <= init;
            end if;
			when grapOpen =>		
            if ((grapEn ='1') AND (grapButton = '0')) then 
               nextState <= grapClosed;
				else
               nextState <= grapOpen;
            end if;

         when grapClosed =>		
            if ((grapEn = '1') AND (grapButton ='0')) then 
               nextState <= grapOpen;
				else
               nextState <= grapClosed;
            end if;
				
			when others =>
				nextState <= init;
					
		end case;
	end process;

	moore_decoder: process(currentState) 			-- logic to determine outputs from state machine states
   begin
		case currentState is
			when init =>		
				grapOn	<= '0';

			when grapOpen =>		
				grapOn	<= '0';
			 			 
			when grapClosed =>
				grapOn	<= '1';
			 
			when others =>
				grapOn	<= '0';
			 
		end case;
	end process;
end sm;
