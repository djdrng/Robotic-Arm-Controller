library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--					THIS IS A PROJECT INTENDED TO ACT AS A ROBOTIC ARM CONTROLLER WITH MOTOR CONTROL, A CONTROLLER FOR AN EXTENDING ARM, AND A GRAPPLER
--					CREATED BY DEVINN DOERING AND NATHAN HARTMAN FOR ECE124
entity LogicalStep_Lab4_top is port	(							
   clkin_50			: in 	std_logic;											-- The 50Mhz clock built into the FPGA
	rst_n				: in  std_logic;											-- The reset button on the FPGA
	pb					: in  std_logic_vector(3 downto 0);					-- The 4 push buttons on the FPGA
 	sw   				: in 	std_logic_vector(7 downto 0); 				-- The switch inputs
   leds				: out std_logic_vector(7 downto 0);					-- For displaying the switch content
   seg7_data 		: out std_logic_vector(6 downto 0); 				-- 7-bit outputs to a 7-segment
	seg7_char1  	: out std_logic;											-- Seg7 digit selectors
	seg7_char2  	: out std_logic											-- Seg7 digit selectors
);
end LogicalStep_Lab4_top;


architecture simplecircuit of LogicalStep_Lab4_top is
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--					COMPONENTS FOR MEALY (MOVEMENT) PORTION

component Mealy_SM0 is port (												-- Mealy State Machince controlling the movement of the robotic arm in the x and y directions
	clk		     	: in  std_logic := '0';								-- The clock input to the state machine
	resetN			: in  std_logic := '0';								-- Resets the state machine to initial state
	xMotion			: in  std_logic := '0';								-- Allows the arm to move in the x direction, will be connected to pb(3)
	yMotion			: in  std_logic := '0';								-- Allows the arm to move in the x direction, will be connected to pb(2)
 	xCompx			: in  std_logic_vector(2 downto 0);				-- Compares the current x position with the target x position
	yCompx			: in  std_logic_vector(2 downto 0);				-- Compares the current y position with the target y position
	extOut			: in  std_logic := '0';								-- Lets the state machine know when the extender is out
	
	err				: out std_logic := '0';								-- The error signal
	xclockEn			: out	std_logic := '0';								-- Enables the x motor to "move"
	yClockEn			: out	std_logic := '0';								-- Enables the y motor to "move"
	xDir				: out std_logic := '0';								-- The direction of x movement, '1' is increasing, '0' is decreasing
	yDir				: out std_logic := '0';								-- The direction of y movement, '1' is increasing, '0' is decreasing
	extEn				: out std_logic := '0' 								-- Enables the extender
);
end component;

component Compx4 is port	(												-- A simple four bit comparator
	inputA			: in 	std_logic_vector(3 downto 0);				-- InputA, will be the current position
	inputB			: in 	std_logic_vector(3 downto 0);				-- InputB, will be the target position
	RESULT 			: out std_logic_vector(2 downto 0)				-- Bit 0 is 1 when a < b
																					-- Bit 1 is 1 when a = b
																					-- Bit 2 is 1 when a > b
);
end component;

component biCounter4 is port	(											-- A simple four bit counter
	clk				: in 	std_logic := '0';								-- The input clock
	resetN			: in 	std_logic := '0';								-- Resets the counter
	clkEn				: in 	std_logic := '0';								-- Enables the counter
	up1Down0			: in 	std_logic := '0';								-- The direction the counter counts, '1' is up, '0' is down
	counterBits 	: out std_logic_vector(3 downto 0)				-- The output of the counter
);
end component;

component mux2 is port (													-- A simple mux2, used to determine whether to display the current position or the target position on the displays
	operand1			: in	std_logic_vector(3 downto 0);				-- The first input, will be the target position		
	operand2			: in  std_logic_vector(3 downto 0);				-- The second input, will be the current position
	selector			: in	std_logic;										-- The selector for the mux, will be either pb(3) for x or pb(2) for y								
	RESULT			: out std_logic_vector(3 downto 0)				-- The output of the mux
);
end component;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 				COMPONENTS FOR MOORE (EXTENDER & GRAPPLER) PORTION

component Moore_SM1 is port (												-- Moore state machine controlling the extending arm
  	clk		     	: in  std_logic := '0';								-- The input clock
   resetN      	: in  std_logic := '0';								-- Will reset the state machine to inital state
	extButton		: in  std_logic := '0';								-- The button the controls the extender
	extEn				: in  std_logic := '0';								-- Whether or not the extender is enabled
	extPos			: in  std_logic_vector(3 downto 0);				-- The current position of the extender
	clkEn				: out std_logic := '0';								-- Enables the extender to move
	extOut			: out std_logic := '0';								-- Whether or not the extender is currently out
	shiftDir 		: out std_logic := '0';								-- Which direction the extender should move			
	grplEn			: out std_logic := '0'								-- The enable for the grappler, only a '1' when the extender is fully extended
);
end component;

component biShiftReg4 is port (											-- A simple bidirectional four bit shift register
	clk				: in 	std_logic := '0';								-- The input clock
	resetN			: in 	std_logic := '0';								-- Will reset the shift register
	clkEn				: in 	std_logic := '0';								-- Enables the register to shift
	left0Right1		: in 	std_logic := '0';								-- Controls the direction the register shifts, '1' is left, '0' is right
	regBits			: out std_logic_vector(3 downto 0)				-- The output of the register
);
end component;

component Moore_SM2 is port (												-- Moore state machine controlling the grappler
   clk		     	: in  std_logic := '0';								-- The input clock
   resetN      	: in 	std_logic := '0';								-- Will reset the state machine to inital state
	grapButton		: in  std_logic := '0';								-- The button controlling the grappler
	grapEn			: in  std_logic := '0';								-- Whether or not the grappler is allowed to grapple
   grapOn			: out std_logic										-- The current state of the grappler
);
end component;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 				COMPONENTS FOR DISPLAY PORTION

component sevenSegment is port ( 
   hex	   		: in  std_logic_vector(3 downto 0);   			-- The 4 bit data to be displayed
   sevenSeg 		: out std_logic_vector(6 downto 0)    			-- 7-bit outputs to a 7-segment
); 
end component;

component errorProc is port 	(											-- Processes how the displays should act when there is an error
	clk				: in 	std_logic := '0';								-- The input clock
	Operand1			: in 	std_logic_vector(6 downto 0);				-- Input1, will be the intended signal for display 1
	Operand2			: in 	std_logic_vector(6 downto 0);				-- Input2, will be the intended signal for display 2
	err				: in 	std_logic;										-- Whether or not there is an error
	RESULT1			: out std_logic_vector(6 downto 0);				-- The output for display 1
	RESULT2			: out std_logic_vector(6 downto 0)				-- The output for display 2
);
end component;

component segment7_mux is port (											-- The mux controlling the seven segment displays
   clk        		: in  std_logic := '0';								-- The input clock (will be 50 Mhz)
	din2 				: in  std_logic_vector(6 downto 0);				-- The data in for display 2
	din1 				: in  std_logic_vector(6 downto 0);				-- The data in for display 1
	dout				: out	std_logic_vector(6 downto 0);				-- The data out
	dig2				: out	std_logic;										-- Display selector
	dig1				: out	std_logic										-- Display selector
);
end component;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 			SIGNALS FOR CLOCK CONTROL (GIVEN)

	constant sim						:  boolean := false; 						-- set to true for simulation runs otherwise keep at 0.
	constant clkDivSize				: 	integer := 26;    							-- size of vectors for the counters

	signal 	MainClk					:  std_logic; 									-- main clock to drive sequencing of state machine

	signal 	binCounter				:  unsigned(clkDivSize-1 downto 0); 	-- := to_unsigned(0,clk_div_size); -- reset binary counter to zero
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--				SIGNALS FOR MEALY (MOVEMENT) PORTION
	
	signal 	xCompare					:  std_logic_vector(2 downto 0);					-- The result of the of comparator for the x-coordinates
	signal 	yCompare					: 	std_logic_vector(2 downto 0);					-- The result of the of comparator for the x-coordinates
	signal 	xCurrentPos 			: 	std_logic_vector(3 downto 0) := "0000";	-- The current X Position, taken from the counter
	signal 	yCurrentPos 			: 	std_logic_vector(3 downto 0) := "0000";	-- The current Y Position, taken from the counter
	signal	err 						: 	std_logic;											-- The signal that will indicate when there is an error
	signal 	xClkEn					:  std_logic;											-- The enable for the x motor
	signal 	yClkEn					:  std_logic;											-- The enable for the y motor
	signal	xClkDir					:  std_logic;											-- The direction the x motor moves
	signal	yClkDir					:  std_logic;											-- The direction the y motor moves
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--				SIGNALS FOR MOORE (EXTENDER & GRAPPLER) PORTION
	
	signal 	extEn						:  std_logic;									-- The enable for the extender
	signal 	extPos					:  std_logic_vector(3 downto 0);			-- The current position of the extender
	signal 	extOut					: 	std_logic;									-- Whether or not the extender is out
	signal 	extClkEn					:  std_logic;									-- The enable for the extender to move
	signal	extDir					: 	std_logic;									-- The direction the extender should move

	signal 	grplEn					:  std_logic;									-- The enable for the grappler				
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
-- 			SIGNALS FOR THE SEVEN SEGMENT DISPLAYS

	signal 	segData1					: 	std_logic_vector(3 downto 0);			-- The raw data for display 1 (in hex)
	signal 	segData2					: 	std_logic_vector(3 downto 0);			-- The raw data for display 2 (in hex)
	signal 	seg7A						: 	std_logic_vector(6 downto 0);			-- The data for display 1 
	signal 	seg7B						: 	std_logic_vector(6 downto 0);			-- The data for display 2
	signal 	segErrorA				: 	std_logic_vector(6 downto 0);			-- The data for display 1 with error accounted for
	signal 	segErrorB				: 	std_logic_vector(6 downto 0);			-- The data for display 2 with error accounted for
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
begin

-- Clocking generator which divides the input clock down to a lower frequency

	binclk: process(clkin_50, rst_n) is
	begin
		if (falling_edge(clkin_50)) then 											-- Binary counter increments on rising clock edge
         	binCounter <= binCounter + 1;
      	end if;
   	end process;

	clock_source:
		MainClk <= 
			clkin_50 when sim = true else												-- For simulations only
			std_logic(binCounter(23));													-- For real fpga operation
					
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 			SIGNAL ASSIGNMENT
											
	leds(7 downto 4) 	<= extPos;														-- Assign the 4th through 7th leds to the extender position
	leds(1) 				<= extEn;														-- Assigned to the extender's enable when on target. Not specified in the project description.
	leds(2) 				<= grplEn;
	leds(0) 				<= err;															-- Assign the 0th led to the error
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 			INSTANCES FOR MEALY (MOVEMENT) PORTION
																								
	INST00: Mealy_SM0  		port map(MainClk, rst_n, pb(3), pb(2), xCompare, yCompare, extOut, err, xClkEn, yClkEn, xClkDir, yClkDir, extEn);		-- Mealy SM controlling motor functions																		
	INST01: biCounter4 		port map(MainClk, rst_n, xClkEn, xClkDir, xCurrentPos);						-- The "motor" or counter for x-movement
	INST02: Compx4				port map(xCurrentPos, sw(7 downto 4), xCompare);								-- Compares the current x position with the desired, controlling movement direction
	INST03: mux2 				port map(sw(7 downto 4), xCurrentPos, pb(3), segData1);						-- Controls whether the current or desired x position is displayed
	INST04: biCounter4 		port map(MainClk, rst_n, yClkEn, yClkDir, yCurrentPos);						-- The "motor" or counter for y-movement			
	INST05: Compx4				port map(yCurrentPos, sw(3 downto 0), yCompare);								-- Compares the current y position with the desired, controlling movement direction
	INST06: mux2 				port map(sw(3 downto 0), yCurrentPos, pb(2), segData2);						-- Controls whether the current or desired y position is displayed
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 			INSTANCES FOR MOORE (EXTENDER & GRAPPLER) PORTION

	INST10: Moore_SM1 		port map(MainClk, rst_n, pb(1), extEn, extPos, extClkEn, extOut, extDir, grplEn); 	-- The Moore SM controlling the extender
	INST11: biShiftReg4 		port map(MainClk, rst_n, extClkEn, extDir, extPos);											-- The "motor" for the extender

	INST20: Moore_SM2 		port map(MainClk, rst_n, pb(0), grplEn, leds(3));												-- The Moore SM controlling the grappler

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 			INSTANCES FOR DISPLAY PORTION	
	
	INST30: sevenSegment 	port map(segData1, seg7A);																				-- Seven segment decoder 1
	INST31: sevenSegment 	port map(segData2, seg7B);																				-- Seven segment decoder 2
	INST32: errorProc 		port map(MainClk, seg7A, seg7B, err, segErrorA, segErrorB);									-- The error processor, flashes displays during an error
	INST33: segment7_mux 	port map(clkin_50, segErrorA, segErrorB, seg7_data, seg7_char1, seg7_char2);			-- The mux for the seven segment displays

end simplecircuit;