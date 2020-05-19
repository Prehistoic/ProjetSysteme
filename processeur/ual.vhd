----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:03:49 04/22/2020 
-- Design Name: 
-- Module Name:    ual - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ual is
  Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
         B : in  STD_LOGIC_VECTOR (7 downto 0);
         Ctrl_Ual : in  STD_LOGIC_VECTOR (2 downto 0);
         N : out  STD_LOGIC;
         O : out  STD_LOGIC;
         Z : out  STD_LOGIC;
         C : out  STD_LOGIC;
         S : out  STD_LOGIC_VECTOR (7 downto 0));
end ual;

architecture Behavioral of ual is
signal result : STD_LOGIC_VECTOR(15 downto 0);

begin

	calcul : process (A, B, Ctrl_Ual) is
	begin
		case Ctrl_Ual is
			when "100" => -- add
				result <= (x"00" & A) + (x"00" & B);
			when "101" => -- sub 
				result <= (x"00" & A) - (x"00" & B);
			when "110" => -- mul 
				result <= A * B;
			when others => -- when "100" => div
				result <= x"0000";
		end case;
	end process;

	S <= result(7 downto 0);
	N <= result(7);
	O <= '0' when result(15 downto 8) = x"00" else '1';
	Z <= '1' when result(7 downto 0) = x"00" else '0';
	C <= result(8);
  
end Behavioral;
