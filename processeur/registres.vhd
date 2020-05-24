----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:05:58 04/22/2020 
-- Design Name: 
-- Module Name:    registres - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity registres is
	Port ( addrA : in  STD_LOGIC_VECTOR (3 downto 0);
					addrB : in  STD_LOGIC_VECTOR (3 downto 0);
					addrW : in  STD_LOGIC_VECTOR (3 downto 0);
					W : in  STD_LOGIC;
					DATA : in  STD_LOGIC_VECTOR (7 downto 0);
					RST : in  STD_LOGIC;
					CLK : in  STD_LOGIC;
					QA : out  STD_LOGIC_VECTOR (7 downto 0);
					QB : out  STD_LOGIC_VECTOR (7 downto 0));
end registres;

architecture Behavioral of registres is
type regs is array (integer range 15 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
signal reg : regs;

begin

	rw : process (CLK) is
	begin
		if rising_edge(CLK) then
			if RST = '0' then
				reg <= (others => (others => '0'));
			else
				if W = '1' and addrW /= "UUUU" then
					reg(conv_integer(addrW)) <= DATA;
  					if addrA = addrW then
  						QA <= DATA;
  					end if;
  					if addrB = addrW then
  						QB <= DATA;
  					end if;
				end if;			
			end if;
		end if;
		QA <= reg(conv_integer(addrA));
		QB <= reg(conv_integer(addrB));
	end process;

end Behavioral;

