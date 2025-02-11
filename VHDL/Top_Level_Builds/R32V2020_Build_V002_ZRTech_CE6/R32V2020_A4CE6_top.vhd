-- Top Level Entity for top of R32V2020 RISC CPU design
-- Build_V002 switches out memory mapped XVGA for ANSI compatible VGA
-- There is a level above this in most cases which connects to the specific FPGA board

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.R32V2020_Pkg.all;

entity R32V2020_A4CE6_top is
	port(
		n_reset				: in std_logic := '1';
		i_CLOCK_50			: in std_logic;
		-- Switches, LEDs, Buzzer pins
		i_switch				: in std_logic_vector(2 downto 0) := "111";
--		i_dipSwitch			: in std_logic_vector(7 downto 0) := x"00";
		--o_LED				: out std_logic_vector(3 downto 0);
		o_BUZZER				: out std_logic := '0';
		-- Serial port pins
		i_SerRxd				: in std_logic := '1';
		o_SerTxd				: out std_logic := '1';
		--o_SerRts				: out std_logic;
		-- VGA pins
		o_Video_Red			: out std_logic_vector(4 downto 0) := "00000";
		o_Video_Grn			: out std_logic_vector(5 downto 0) := "000000";
		o_Video_Blu			: out std_logic_vector(4 downto 0) := "00000";
		o_hSync				: out std_logic := '1';
		o_vSync				: out std_logic := '1';
		-- Seven Segment LED pins
		o_Anode			 	: out std_logic_vector(3 downto 0) := x"0";
		o_LED7Seg_out		: out std_logic_vector(7 downto 0) := x"00";
		-- LED Ring
--		o_LEDRing_out		: out std_logic_vector(3 downto 0) := x"0";
		-- 8 bit I/O Latch
--		o_LatchIO			: out std_logic_vector(7 downto 0) := x"00";
		-- I2C Clock and Data
--		io_I2C_SCL			: inout std_logic := '1';
--		io_I2C_SDA			: inout std_logic := '1';
--		i_I2C_INT			: in std_logic := '0';
		-- SPIbus
--		spi_sclk				: out std_logic := '1';
--     spi_csN				: out std_logic := '1';
--    spi_mosi				: out std_logic := '1';
--    spi_miso				: in std_logic := '1';
--	o_testPoint			: out std_logic := '1';
		-- Music generator
		o_Note				: out std_logic := '0';
		-- PS/2 Keyboard pins
		i_ps2Clk				: in std_logic := '1';
		i_ps2Data			: in std_logic := '1'		
		);
end R32V2020_A4CE6_top;

architecture struct of R32V2020_A4CE6_top is

--attribute syn_keep: boolean;
--attribute syn_keep of w_Switch: signal is true;
--signal	w_RingLED			: std_logic_vector(11 downto 0);
signal	w_Anode_Activate	: std_logic_vector(7 downto 0);
signal	w_LED7Seg_out		: std_logic_vector(7 downto 0);
signal	w_RedHi				: std_logic;
signal	w_RedLo				: std_logic;
signal	w_GrnHi				: std_logic;
signal	w_GrnLo				: std_logic;
signal	w_BluHi				: std_logic;
signal	w_BluLo				: std_logic;

begin

--	o_LEDRing_out <= w_RingLED(3 downto 0);
	o_Anode <= w_Anode_Activate(3 downto 0);
	o_LED7Seg_out <= not w_LED7Seg_out;
	o_Video_Red <= w_RedHi & w_RedHi & w_RedLo & w_RedLo & w_RedLo;
	o_Video_Grn <= w_GrnHi & w_GrnHi & w_GrnLo & w_GrnLo & w_GrnLo & w_GrnLo;
	o_Video_Blu <= w_BluHi & w_BluHi & w_BluLo & w_BluLo & w_BluLo;

	middle : entity work.R32V2020_top
		port map (
		n_reset		=> n_reset,
		i_CLOCK_50	=> i_CLOCK_50,
		-- Switches, LEDs, Buzzer pins
		i_switch		=> i_switch,
--		i_dipSwitch	=> i_dipSwitch,
		--o_LED		=> ,
		o_BUZZER		=> o_BUZZER,
		-- Serial port pins
		i_SerRxd		=> i_SerRxd,
		o_SerTxd		=> o_SerTxd,
		--o_SerRts				: out std_logic;
		-- VGA pins
		o_vid_Red_Hi	=> w_RedHi,
		o_vid_Red_Lo	=> w_RedLo,
		o_vid_Grn_Hi	=> w_GrnHi,
		o_vid_Grn_Lo	=> w_GrnLo,
		o_vid_Blu_Hi	=> w_BluHi,
		o_vid_Blu_Lo	=> w_BluLo,
		o_hSync			=> o_hSync,
		o_vSync			=> o_vSync,
		-- Seven Segment LED pins
		o_Anode_Activate	=> w_Anode_Activate,
		o_LED7Seg_out		=> w_LED7Seg_out,
		-- LED Ring
--		o_LEDRing_out		=> w_RingLED,
		-- 8 bit I/O Latch
--		o_LatchIO			=> o_LatchIO,
		-- I2C Clock and Data
--		io_I2C_SCL			=> io_I2C_SCL,
--		io_I2C_SDA			=> io_I2C_SDA,
--		i_I2C_INT			=> i_I2C_INT,
		-- SPIbus
--		spi_sclk				=> spi_sclk,
--      spi_csN				=> spi_csN,
--      spi_mosi				=> spi_mosi,
--      spi_miso				=> spi_miso,
		-- Music generator
		o_Note				=> o_Note,
		-- PS/2 Keyboard pins
		i_ps2Clk				=> i_ps2Clk,
		i_ps2Data			=> i_ps2Data
		);
		
	end;
