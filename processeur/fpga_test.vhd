--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:22:36 05/16/2020
-- Design Name:   
-- Module Name:   /home/lager/ProjetSysteme/processeur/fpga_test.vhd
-- Project Name:  processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fpga
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
 
ENTITY fpga_test IS
END fpga_test;
 
ARCHITECTURE behavior OF fpga_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fpga
    PORT(
         RST : IN  std_logic;
			CLK : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal RST : std_logic := '1';
   signal CLK : std_logic := '0';

   -- Clock period definitions
   constant CLK_period : time := 25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fpga PORT MAP (
			 RST => RST,
          CLK => CLK
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;

END;
