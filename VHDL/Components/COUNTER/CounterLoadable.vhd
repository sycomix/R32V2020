----------------------------------------------------
-- VHDL code for 19-bit counter
-- 50 MHz divided by 2^19 = 45 Hz (low end of the sound) 
----------------------------------------------------
	
library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

----------------------------------------------------

entity counterLoadable is

port(	
	clock		: in std_logic;
	clear		: in std_logic := '0';
	loadVal	: in std_logic_vector(19 downto 0) := x"00000";
	soundOut	: out std_logic
);
end counterLoadable;

architecture behv of counterLoadable is		 	  
	
    signal Pre_Q: std_logic_vector(19 downto 0);
	 signal sound:	std_logic;

begin

    -- behavior describe the counterLoadable

    process(clock, clear, loadVal, Pre_Q, sound)
    begin
		if rising_edge(clock) then
			if clear = '1' then
				sound <= '0';
				Pre_Q <= x"00000";
			elsif Pre_Q = x"FFFFF" then
				Pre_Q <= loadVal;
				sound <= not sound;
			else
				Pre_Q <= Pre_Q + 1;
			end if;
		end if;
    end process;	
	
    -- concurrent assignment statement
	 soundOut <= sound;

end behv;
