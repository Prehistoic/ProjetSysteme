----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:05:58 04/22/2020 
-- Design Name: 
-- Module Name:    instructions - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instructions is
	Port ( addr : in  STD_LOGIC_VECTOR (7 downto 0);
					CLK : in  STD_LOGIC;
					P_OUT : out  STD_LOGIC_VECTOR (31 downto 0));
end instructions;

architecture Behavioral of instructions is
type Instruction is array (255 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
signal inst : Instruction;
signal result : STD_LOGIC_VECTOR (31 downto 0);

begin

	instproc : process (CLK) is
	begin
		if rising_edge(CLK) then
			result <= inst(to_integer(unsigned(addr)));
		end if;
	end process;

  P_OUT <= result;

end Behavioral;