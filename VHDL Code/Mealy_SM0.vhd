library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--					A MOORE STATE MACHINE THAT CONTROLS THE EXTENDER OF A ROBOTIC ARM
entity Mealy_SM0 is port (
	clk		     	: in  	std_logic := '0';							-- The input clock
	resetN			: in  	std_logic := '0';							-- Will reset the state machine to its intial state
	xMotion			: in  	std_logic := '0';							-- Allows the arm to move in the x direction, will be connected to pb(3)
	yMotion			: in  	std_logic := '0';							-- Allows the arm to move in the y direction, will be connected to pb(2)
	xCompX			: in  	std_logic_vector(2 downto 0);			-- Compares the current x position with the target x position
	yCompX			: in  	std_logic_vector(2 downto 0);			-- Compares the current y position with the target y position
	extOut			: in  	std_logic := '0';							-- Lets the state machine know when the extender is out
	 
	err				: out 	std_logic := '0';									-- The error signal
	xClockEn			: out		std_logic := '0';									-- Enables the x motor to "move"
	yClockEn			: out		std_logic := '0';									-- Enables the y motor to "move"
	xDir				: out 	std_logic := '0';									-- The direction of x movement, '1' is increasing, '0' is decreasing
	yDir				: out 	std_logic := '0';									-- The direction of y movement, '1' is increasing, '0' is decreasing
	extEn				: out 	std_logic := '0'									-- Enables the extender
			 
);
end entity;

architecture SM of Mealy_SM0 is

-- list all the STATES  
   type states is (atTarget, offTarget, errorState);   

   signal currentState, nextState	: states;       				-- CurrentState, nextState signals are of type states

begin
-- STATE MACHINE: MOORE Type

	register_section: process(clk, resetN, nextState) 				-- Creates sequential logic to store the state. The resetN is used to asynchronously clear the register
   		begin
			if (resetN = '0') then
	         	currentState <= offTarget;
			elsif (falling_edge(clk)) then								-- On the falling edge of clock the current state is updated with next state
				currentState <= nextState; 								-- We changed it to falling edge to fix certain timing issues
			end if;
   		end process;
	
	transition_logic: process(currentState, xCompX, yCompX, xMotion, yMotion, extOut) -- Logic to determine next state. 
	begin
		case currentState is
			when atTarget =>
				if((xCompx(1) = '0' OR yCompx(1) = '0') AND extOut = '0') then
						nextState <= offTarget;
				
				elsif(extOut = '1' AND ((xCompx(1) = '0' AND xMotion = '0') OR (yCompx(1) = '0' AND yMotion = '0'))) then 
					nextState <= errorState;
					
				else 
					nextState <= atTarget;
					
				end if;
				
			when offTarget =>
				
				if(xCompX(1) = '1' AND yCompX(1) = '1') then												-- If both x and y positions are on target, nextState is atTarget
					nextState <= atTarget;
						
				else
					nextState <= offTarget;
					
				end if;
			
			when errorState =>
				if(extOut = '0') then
					nextState <= offTarget;
				
				else 
					nextState <= errorState;
				
				end if;
				
			when others =>
				nextState <= offTarget;
		 
 		end case;
	end process;

	mealy_decoder: process(currentState, xMotion, yMotion, xCompx, yCompx, extOut) 			-- Logic to determine outputs from state machine states and inputs
   	begin
		case currentState IS	
			when atTarget =>
				if(extOut = '1' AND ((xCompx(1) = '0' AND xMotion = '0') OR (yCompx(1) = '0' AND yMotion = '0'))) then 
					err		<= '1';
					xClockEn	<= '0';																				-- This is when there is an error
					yClockEn <= '0';
					extEn 	<= '1';
					
				else
					err 		<= '0';
					xClockEn <= '0';
					yClockEn <= '0';
					extEn 	<= '1';
					
				end if;	
		
			when offTarget =>
				if(xMotion = '0' AND yMotion = '0') then 													-- If both buttons are pressed
					if(xCompX(0) = '1' AND yCompX(0) = '1') then
						xClockEn <= '1';
						yClockEn <= '1';
						xDir 		<= '1';
						yDir 		<= '1';
						err		<= '0';
						extEn		<= '0';

					elsif(xCompX(0) = '1' AND yCompX(2) = '1') then
						xClockEn <= '1';
						yClockEn <= '1';
						xDir 		<= '1';
						yDir 		<= '0';
						err		<= '0';
						extEn		<= '0';

					elsif(xCompX(2) = '1' AND yCompX(0) = '1') then
						xClockEn <= '1';
						yClockEn <= '1';
						xDir 		<= '0';
						yDir 		<= '1';
						err		<= '0';
						extEn		<= '0';

					elsif(xCompX(2) = '1' AND yCompX(2) = '1') then
						xClockEn <= '1';
						yClockEn <= '1';
						xDir 		<= '1';
						yDir 		<= '1';
						err		<= '0';
						extEn		<= '0';
						
					elsif(xCompX(1) = '1' AND yCompX(0) = '1') then
						xClockEn <= '0';
						yClockEn <= '1';
						yDir 		<= '1';
						err		<= '0';
						extEn		<= '0';
						
					elsif(xCompX(1) = '1' AND yCompX(2) = '1') then
						xClockEn <= '0';
						yClockEn <= '1';
						yDir 		<= '0';
						err		<= '0';
						extEn		<= '0';
						
					elsif(xCompX(0) = '1' AND yCompX(1) = '1') then
						xClockEn <= '1';
						yClockEn <= '0';
						xDir 		<= '1';
						err		<= '0';
						extEn		<= '0';
						
					elsif(xCompX(2) = '1' AND yCompX(1) = '1') then
						xClockEn <= '1';
						yClockEn <= '0';
						xDir 		<= '1';
						err		<= '0';
						extEn		<= '0';
						
					else
						err 		<= '0';
						extEn 	<= '0';
						xClockEn <= '0';
						yClockEn <= '0';
					
					end if;
					
				elsif(xMotion = '0') then																	-- If only the x button is pressed
					if(xCompX(0) = '1') then
						xClockEn <= '1';
						yClockEn <= '0';
						xDir 		<= '1';
						err		<= '0';
						extEn		<= '0';

					elsif(xCompX(2) = '1') then
						xClockEn <= '1';
						yClockEn <= '0';
						xDir 		<= '0';
						err		<= '0';
						extEn		<= '0';
					
					elsif(xCompx(1) = '1') then
						xClockEn <= '0';
						yClockEn <= '0';
						err		<= '0';
						extEn		<= '0';

					end if;
				
				elsif(yMotion = '0') then																	-- If only the y button is pressed
					if(yCompX(0) = '1') then
						xClockEn <= '0';
						yClockEn <= '1';
						yDir 		<= '1';
						err		<= '0';
						extEn		<= '0';

					elsif(yCompX(2) = '1') then
						xClockEn <= '0';
						yClockEn <= '1';
						yDir 		<= '0';
						err		<= '0';
						extEn		<= '0';
						
					elsif(yCompx(1) = '1') then
						xClockEn <= '0';
						yClockEn <= '0';
						err		<= '0';
						extEn		<= '0';

				
				else																								-- If neither button is pressed
					err 		<= '0';
					extEn 	<= '0';
					xClockEn <= '0';
					yClockEn <= '0';

					end if;			
				end if;
				
			when errorState => 	
				if(extOut = '0') then 
					err 		<= '0';
					xClockEn <= '0';
					yClockEn <= '0';
					extEn 	<= '1';
					
				else
					err 		<= '1';
					xClockEn <= '0';
					yClockEn <= '0';
					extEn 	<= '1';
					
				end if;					
			
			when others => 
				err 		<= '0';
				extEn 	<= '0';
				xClockEn <= '0';
				yClockEn <= '0';
				
		end case;
	end process;
end SM;

