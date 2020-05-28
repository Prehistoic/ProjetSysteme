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
  Port ( RST : in  STD_LOGIC;
			CLK : in  STD_LOGIC);
end fpga;

architecture Behavioral of fpga is

  component pipeline is
    Port ( OP_in : in  STD_LOGIC_VECTOR (4 downto 0);
            A_in : in  STD_LOGIC_VECTOR (7 downto 0);
            B_in : in  STD_LOGIC_VECTOR (7 downto 0);
            C_in : in  STD_LOGIC_VECTOR (7 downto 0);
            OP_out : out  STD_LOGIC_VECTOR (4 downto 0);
            A_out : out  STD_LOGIC_VECTOR (7 downto 0);
            B_out : out  STD_LOGIC_VECTOR (7 downto 0);
            C_out : out  STD_LOGIC_VECTOR (7 downto 0);
            CLK : in  STD_LOGIC);
  end component;

  component instructions is
    Port ( addr : in  STD_LOGIC_VECTOR (7 downto 0);
				WAITING : in  STD_LOGIC;
            CLK : in  STD_LOGIC;
            P_OUT : out  STD_LOGIC_VECTOR (31 downto 0));
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
    OP: STD_LOGIC_VECTOR(4 downto 0);
    A: STD_LOGIC_VECTOR(7 downto 0);
    B: STD_LOGIC_VECTOR(7 downto 0);
    C: STD_LOGIC_VECTOR(7 downto 0);
  end record;

  signal lidi2diex: stage;
  signal diex2exmem: stage;
  signal exmem2memre: stage;
  signal memre2regs: stage;

  signal lidiMUXdiex: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal diexMUXexmem: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal exmemMUXmemin: STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal memoutMUXmemre: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	signal diexLCexmem: STD_LOGIC_VECTOR(2 DOWNTO 0);
	signal exmemLCmemre: std_logic;
	signal memreLCregs: std_logic;
	
	signal lidiR: boolean;
	signal diexW: boolean;
	signal exmemW: boolean;
	signal waiting: std_logic;
	
   signal ip: STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
   signal instr: STD_LOGIC_VECTOR(31 DOWNTO 0);
   signal regs_QA: STD_LOGIC_VECTOR(7 DOWNTO 0);
   signal regs_QB: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal flag_N: std_logic;
	signal flag_O: std_logic;
	signal flag_Z: std_logic;
	signal flag_C: std_logic;
   signal ual_S: STD_LOGIC_VECTOR(7 DOWNTO 0);
   signal mem_OUT: STD_LOGIC_VECTOR(7 DOWNTO 0);

begin
		
	lidi: Pipeline PORT MAP (
		instr(28 DOWNTO 24),
		instr(23 DOWNTO 16),
		instr(15 DOWNTO 8),
		instr(7 DOWNTO 0),
		lidi2diex.Op,
		lidi2diex.A,
		lidi2diex.B,
		lidi2diex.C,
		CLK
	);
		
	diex: Pipeline PORT MAP (
		lidi2diex.Op,
		lidi2diex.A,
		lidiMUXdiex,
		regs_QB,
		diex2exmem.Op,
		diex2exmem.A,
		diex2exmem.B,
		diex2exmem.C,
		CLK
	);
		
	exmem: Pipeline PORT MAP (
		diex2exmem.Op,
		diex2exmem.A,
		diexMUXexmem,
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
		memoutMUXmemre,
		exmem2memre.C,
		memre2regs.Op,
		memre2regs.A,
		memre2regs.B,
		memre2regs.C,
		CLK
	);

  inst: instructions PORT MAP (
    ip,
	 waiting,
    CLK,
    instr
  );

  regs: registres PORT MAP (
    lidi2diex.B(3 DOWNTO 0),
    lidi2diex.C(3 DOWNTO 0),
    memre2regs.A(3 DOWNTO 0),
    memreLCregs,
    memre2regs.B,
    RST,
    CLK,
    regs_QA,
    regs_QB
   );

  ual_map: ual PORT MAP (
    diex2exmem.B,
    diex2exmem.C,
    diexLCexmem,
    flag_N,
    flag_O,
    flag_Z,
    flag_C,
    ual_S
  );

  mem: memory PORT MAP (
    exmemMUXmemin,
    exmem2memre.B,
    exmemLCmemre,
    RST,
    CLK,
    mem_OUT
  );

  lidiMUXdiex <= lidi2diex.B when lidi2diex.Op = x"02" or lidi2diex.Op = x"11" or lidi2diex.Op = x"12" else regs_QA;
  diexMUXexmem <= ual_S when (diex2exmem.Op >= x"04" and diex2exmem.Op <= x"0C") else diex2exmem.B;
  exmemMUXmemin <= exmem2memre.A when exmem2memre.Op = x"11" else exmem2memre.B;
  memoutMUXmemre <= mem_OUT when exmem2memre.Op = x"12" else exmem2memre.B;
	
	diexLCexmem <= diex2exmem.Op(2 DOWNTO 0);
	exmemLCmemre <= '0' when exmem2memre.Op = x"11" else '1';
	memreLCregs <= '0' when memre2regs.Op = x"11" else '1';
	
	lidiR <= lidi2diex.Op /= "UUUUU" and lidi2diex.Op /= x"00" and lidi2diex.Op /= x"02" and lidi2diex.Op /= x"12";
	diexW <= diex2exmem.Op /= "UUUUU" and diex2exmem.Op /= x"00" and diex2exmem.Op /= x"11";
	exmemW <= exmem2memre.Op /= "UUUUU" and exmem2memre.Op /= x"00" and exmem2memre.Op /= x"11";
	waiting <= '1' when (lidiR and diexW and (lidi2diex.B = diex2exmem.A or lidi2diex.C = diex2exmem.A)) 
			  or (lidiR and exmemW and (lidi2diex.B = exmem2memre.A or lidi2diex.C = exmem2memre.A)) else '0';

	run : process (CLK) is
	begin
		if (rising_edge(CLK) and (waiting = '0' or true)) then
			ip <= ip + x"01";
		end if;
	end process;

end Behavioral;