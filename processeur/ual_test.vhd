--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:09:48 04/22/2020
-- Design Name:   
-- Module Name:   /home/lager/ProjetSysteme/processeur/ual_test.vhd
-- Project Name:  processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ual
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ual_test IS
END ual_test;
 
ARCHITECTURE behavior OF ual_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ual
    PORT(
         A : IN  std_logic_vector(7 downto 0);
         B : IN  std_logic_vector(7 downto 0);
         Ctrl_Ual : IN  std_logic_vector(2 downto 0);
         N : OUT  std_logic;
         O : OUT  std_logic;
         Z : OUT  std_logic;
         C : OUT  std_logic;
         S : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(7 downto 0) := (others => '0');
   signal B : std_logic_vector(7 downto 0) := (others => '0');
   signal Ctrl_Ual : std_logic_vector(2 downto 0) := (others => '0');
	signal CLK : std_logic;

 	--Outputs
   signal N : std_logic;
   signal O : std_logic;
   signal Z : std_logic;
   signal C : std_logic;
   signal S : std_logic_vector(7 downto 0);
   -- No clocks detected in port list. Replace CLK below with 
   -- appropriate port name 
 
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ual PORT MAP (
          A => A,
          B => B,
          Ctrl_Ual => Ctrl_Ual,
          N => N,
          O => O,
          Z => Z,
          C => C,
          S => S
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;

      -- insert stimulus here 
		
		-- add
		A <= x"05";
		B <= x"03";
		Ctrl_Ual <= "100";
		wait for CLK_period*5;
		
		-- sub
		A <= x"05";
		B <= x"03";
		Ctrl_Ual <= "101";
		wait for CLK_period*5;
		
		-- mul
		A <= x"02";
		B <= x"02";
		Ctrl_Ual <= "110";
		wait for CLK_period*5;
		
		-- Flag O/C/Z
		A <= x"FF";
		B <= x"01";
		Ctrl_Ual <= "100";
		wait for CLK_period*5;
		
		-- Flag O/C/N
		A <= x"00";
		B <= x"01";
		Ctrl_Ual <= "101";
		wait for CLK_period*5;
		
		-- Flag Z
		A <= x"05";
		B <= x"05";
		Ctrl_Ual <= "101";
		wait for CLK_period*5;

      wait;
   end process;

END;
