----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:05:58 04/22/2020 
-- Design Name: 
-- Module Name:    fpga - Behavioral 
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

entity fpga is
  Port ( CLK : in  STD_LOGIC);
end fpga;

architecture Behavioral of fpga is

  component pipeline is
    Port ( OP_in : in  STD_LOGIC_VECTOR (3 downto 0);
            A_in : in  STD_LOGIC_VECTOR (7 downto 0);
            B_in : in  STD_LOGIC_VECTOR (7 downto 0);
            C_in : in  STD_LOGIC_VECTOR (7 downto 0);
            OP_out : in  STD_LOGIC_VECTOR (3 downto 0);
            A_out : in  STD_LOGIC_VECTOR (7 downto 0);
            B_out : in  STD_LOGIC_VECTOR (7 downto 0);
            C_out : in  STD_LOGIC_VECTOR (7 downto 0);
            CLK : in  STD_LOGIC);
  end component;

  component instructions is
    Port ( addr : in  STD_LOGIC_VECTOR (7 downto 0);
            CLK : in  STD_LOGIC;
            P_OUT : out  STD_LOGIC_VECTOR (31 downto 0));
  end component;

  component decoder is
    Port ( Inst : in  STD_LOGIC_VECTOR (31 downto 0);
           Op : out  STD_LOGIC_VECTOR (3 downto 0);
           A : out  STD_LOGIC_VECTOR (7 downto 0);
           B : out  STD_LOGIC_VECTOR (7 downto 0);
           C : out  STD_LOGIC_VECTOR (7 downto 0));
  end component;

  component registres is
    Port ( addrA : in  STD_LOGIC_VECTOR (3 downto 0);
            addrB : in  STD_LOGIC_VECTOR (3 downto 0);
            addrW : in  STD_LOGIC_VECTOR (3 downto 0);
            W : in  STD_LOGIC;
            DATA : in  STD_LOGIC_VECTOR (7 downto 0);
            RST : in  STD_LOGIC;
            CLK : in  STD_LOGIC;
            QA : out  STD_LOGIC_VECTOR (7 downto 0);
            QB : out  STD_LOGIC_VECTOR (7 downto 0));
  end component;

  component ual is
    Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
           B : in  STD_LOGIC_VECTOR (7 downto 0);
           Ctrl_Ual : in  STD_LOGIC_VECTOR (2 downto 0);
           N : out  STD_LOGIC;
           O : out  STD_LOGIC;
           Z : out  STD_LOGIC;
           C : out  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR (7 downto 0));
  end component;

  component memory is
    Port ( addr : in  STD_LOGIC_VECTOR (7 downto 0);
            P_IN : in  STD_LOGIC_VECTOR (7 downto 0);
            RW : in  STD_LOGIC;
            RST : in  STD_LOGIC;
            CLK : in  STD_LOGIC;
            P_OUT : out  STD_LOGIC_VECTOR (7 downto 0));
  end component;

  type stage is record
    OP: STD_LOGIC_VECTOR(3 downto 0);
    A: STD_LOGIC_VECTOR(7 downto 0);
    B: STD_LOGIC_VECTOR(7 downto 0);
    C: STD_LOGIC_VECTOR(7 downto 0);
  end record;

  signal ip: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal rst: std_logic;

  signal dec2lidi: stage;
  signal lidi2diex: stage;
  signal diex2exmem: stage;
  signal exmem2memre: stage;
  signal memre2regs: stage;

  signal lidiMUXdiex: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal diexMUXexmem: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal exmemMUXmemin: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal memoutMUXmemre: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	signal diexLCexmem : std_logic;
	signal exmemLCmemre : std_logic;
	signal memreLCregs : std_logic;

begin
		
	lidi: Pipeline PORT MAP (
		dec2lidi.Op,
		dec2lidi.A,
		dec2lidi.B,
		dec2lidi.C,
		lidi2diex.Op,
		lidi2diex.A,
		lidi2diex.B,
		lidi2diex.C,
		CLK
	);
		
	diex: Pipeline PORT MAP (
		lidi2diex.Op,
		lidi2diex.A,
		lidi2diex.B,
		lidi2diex.C,
		diex2exmem.Op,
		diex2exmem.A,
		diex2exmem.B,
		diex2exmem.C,
		CLK
	);
		
	exmem: Pipeline PORT MAP (
		diex2exmem.Op,
		diex2exmem.A,
		diex2exmem.B,
		diex2exmem.C,
		exmem2memre.Op,
		exmem2memre.A,
		exmem2memre.B,
		exmem2memre.C,
		CLK
	);
		
	memre: Pipeline PORT MAP (
		exmem2memre.Op,
		exmem2memre.A,
		exmem2memre.B,
		exmem2memre.C,
		memre2regs.Op,
		memre2regs.A,
		memre2regs.B,
		memre2regs.C,
		CLK
	);

  inst: instructions PORT MAP (
    ip,
    CLK,
    ip
  );

   dec: decoder PORT MAP (
		 ip,
		 dec2lidi.Op,
		 dec2lidi.A,
		 dec2lidi.B,
		 dec2lidi.C
   );

  regs: registres PORT MAP (
    lidi2diex.B,
    lidi2diex.C,
    memre2regs.A,
    memreLCregs,
    memre2regs.B,
    rst,
    CLK,
    lidiMUXdiex,
    lidi2diex.C
  );

  ual_map: ual PORT MAP (
    diexMUXexmem,
    diex2exmem.C,
    diexLCexmem,
    '0',
    '0',
    '0',
    '0',
    diexMUXexmem
  );

  mem: memory PORT MAP (
    exmemMUXmemin,
    memoutMUXmemre,
    exmemLCmemre,
    rst,
    CLK,
    memoutMUXmemre
  );

end Behavioral;