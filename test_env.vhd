----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.02.2021 10:31:04
-- Design Name: 
-- Module Name: test_env - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
  Port (input: in std_logic;
        clk: in std_logic;
        en: out std_logic);
end component;

component SSD is
  Port (clk: in std_logic;
        data: in std_logic_vector(15 downto 0);
        an: out std_logic_vector(3 downto 0);
        cat: out std_logic_vector(6 downto 0));  
end component;

component InstructionFetch is
  Port (clk: in std_logic;
        branchAddr: in std_logic_vector(15 downto 0);
        jumpAddr: in std_logic_vector(15 downto 0);
        Jump: in std_logic; 
        PCSrc: in std_logic;
        pcEn: in std_logic; 
        pcReset: in std_logic; 
        Instruction: out std_logic_vector(15 downto 0);
        nextInstrAddr: out std_logic_vector(15 downto 0));
end component;

component ID is 
  Port( clk: in std_logic;
        RegWrite: in std_logic;
        en: in std_logic;
        RegDst: in std_logic;
        ExtOp: in std_logic; 
        Instr: in std_logic_vector(15 downto 0);
        WD: in std_logic_vector(15 downto 0);
        sa: out std_logic;
        func: out std_logic_vector(2 downto 0);
        Ext_imm: out std_logic_vector(15 downto 0);
        RD1: out std_logic_vector(15 downto 0);
        RD2: out std_logic_vector(15 downto 0));
end component;

component ControlUnit is 
  Port( Instr: in std_logic_vector (2 downto 0);
        RegDst: out std_logic;
        ExtOp: out std_logic;
        ALUSrc: out std_logic;
        Branch: out std_logic;
        Jump: out std_logic;
        MemWrite: out std_logic;
        MemToReg: out std_logic;
        RegWrite: out std_logic;
        ALUOp: out std_logic_vector (2 downto 0));
end component;

component EX is
  Port( RD1: in std_logic_vector (15 downto 0);
        RD2: in std_logic_vector (15 downto 0);
        Ext_Imm: in std_logic_vector (15 downto 0);
        func: in std_logic_vector (2 downto 0);
        PCplus1: in std_logic_vector (15 downto 0);
        ALUOp: in std_logic_vector (2 downto 0);
        ALUSrc: in std_logic;
        sa: in std_logic;
        BranchAddress: out std_logic_vector (15 downto 0);
        ALURes: out std_logic_vector (15 downto 0);
        Zero: out std_logic );
end component;

component MEM is 
  Port( clk: in std_logic;
        en: in std_logic;
        MemWrite: in std_logic;	
        ALUResIn: in std_logic_vector(15 downto 0);
        WriteData: in std_logic_vector(15 downto 0);	
        MemData: out std_logic_vector(15 downto 0);
        ALUResOut: out std_logic_vector(15 downto 0));
end component;

--semnale UC
signal RegDst: std_logic;
signal ExtOp: std_logic;
signal ALUSrc: std_logic;
signal Branch: std_logic;
signal Jump: std_logic;
signal MemWrite: std_logic;
signal MemToReg: std_logic;
signal RegWrite: std_logic;
signal ALUOp: std_logic_vector (2 downto 0);


signal WD: std_logic_vector(15 downto 0);
signal sa: std_logic;
signal func: std_logic_vector(2 downto 0);
signal Ext_imm: std_logic_vector(15 downto 0);
signal RD1: std_logic_vector(15 downto 0);
signal RD2: std_logic_vector(15 downto 0);
  
signal Instruction: std_logic_vector(15 downto 0);
signal nextInstrAddr: std_logic_vector(15 downto 0);
signal branchAddr: std_logic_vector(15 downto 0);
signal jumpAddr: std_logic_vector(15 downto 0);
signal PCSrc: std_logic;

signal ALURes: std_logic_vector(15 downto 0);
signal Zero: std_logic;

signal MemData: std_logic_vector(15 downto 0);
signal ALUResOut: std_logic_vector(15 downto 0);
   
signal en: std_logic;
signal rst: std_logic;
signal DO: std_logic_vector(15 downto 0);

begin

MPGcomp1: MPG port map(input => btn(0), clk => clk, en => en); --butonul din centru -> enable program counter
MPGcomp2: MPG port map(input => btn(1), clk => clk, en => rst); --butonul de sus -> reset program counter
SSDComp: SSD port map(clk => clk, data => DO, an => an, cat => cat);

IFetch: InstructionFetch port map(clk => clk, 
                                  branchAddr =>  branchAddr, 
                                  jumpAddr => jumpAddr, 
                                  Jump => Jump,
                                  PCSrc => PCSrc,
                                  pcEn => en,
                                  pcReset => rst,
                                  Instruction => Instruction,
                                  nextInstrAddr => nextInstrAddr );
                                  
IDecode: ID port map(clk => clk,
                     RegWrite => RegWrite,
                     en => en,
                     RegDst => RegDst,
                     ExtOp => ExtOp,
                     Instr => Instruction,
                     WD => WD,
                     sa => sa,
                     func => func,
                     Ext_imm => Ext_imm,
                     RD1 => RD1,
                     RD2 => RD2 );       
                             
UC: ControlUnit port map(Instr => Instruction(15 downto 13), 
                         RegDst => RegDst,
                         ExtOp => ExtOp,
                         ALUSrc => ALUSrc,
                         Branch => Branch,
                         Jump => Jump,
                         MemWrite => MemWrite,
                         MemToReg => MemToReg,
                         RegWrite => RegWrite,
                         ALUOp => ALUOp );

ExUnit: EX port map(RD1 => RD1,
                    RD2 => RD2,
                    Ext_Imm => Ext_imm,
                    func => func,
                    PCplus1 => nextInstrAddr,
                    ALUOp  => ALUOp,
                    ALUSrc => ALUSrc,
                    sa => sa,
                    BranchAddress => branchAddr,
                    ALURes => ALURes,
                    Zero => Zero );

Memory: MEM port map(clk => clk,
                     en => en,
                     MemWrite =>  MemWrite,
                     ALUResIn => ALURes,
                     WriteData => RD2,
                     MemData => MemData,
                     ALUResOut => ALUResOut );

--unitatea Write Back
process(MemToReg, MemData, ALUResOut) 
begin
case MemToReg is 
    when '1' => WD <= MemData;
    when '0' => WD <= ALUResOut;
    when others => WD <= (others => '0');
end case;
end process;

--logica de branch
PCSrc <= Zero and Branch;

--logica de calcul a adresei de jump
jumpAddr <= nextInstrAddr(15 downto 13) & Instruction(12 downto 0);
    
       
--selectia valorii de afisat
process(Instruction,nextInstrAddr,RD1,RD2,WD,Ext_Imm,sw)
begin
	case sw(7 downto 5) is
		when "000" => DO <= Instruction;			
		when "001" => DO <= nextInstrAddr;			
		when "010" => DO <= RD1;			        
		when "011" => DO <= RD2;		            
		when "100" => DO <= Ext_imm;                    
		when "101" => DO <= ALURes;
		when "110" => DO <= MemData;
		when "111" => DO <= WD;			
		when others => DO <= X"0000";
	end case;
end process;

led(7) <= RegDst;
led(6) <= ExtOp;
led(5) <= ALUSrc;
led(4) <= Branch;
led(3) <= Jump;
led(2) <= MemWrite;
led(1) <= MemToReg;
led(0) <= RegWrite;
led(10 downto 8) <= ALUOp;
led(15 downto 11) <= "00000";

end Behavioral;
