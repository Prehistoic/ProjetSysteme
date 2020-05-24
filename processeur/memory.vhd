----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:05:58 04/22/2020 
-- Design Name: 
-- Module Name:    memory - Behavioral 
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

entity memory is
	Port ( addr : in  STD_LOGIC_VECTOR (7 downto 0);
					P_IN : in  STD_LOGIC_VECTOR (7 downto 0);
					RW : in  STD_LOGIC;
					RST : in  STD_LOGIC;
					CLK : in  STD_LOGIC;
					P_OUT : out  STD_LOGIC_VECTOR (7 downto 0));
end memory;

architecture Behavioral of memory is
type Mem is array (255 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
signal data : Mem;
signal result : STD_LOGIC_VECTOR (7 downto 0);

begin

	memproc : process (CLK) is
	begin
		if falling_edge(CLK) then
			if RST = '0' then
				data <= (others => (others => '0'));
			else 
				if RW = '1' then
					result <= data(to_integer(unsigned(addr)));
				else
					data(to_integer(unsigned(addr))) <= P_IN;
					result <= data(to_integer(unsigned(addr)));
				end if;
			end if;
		end if;
	end process;

  P_OUT <= result;

end Behavioral;