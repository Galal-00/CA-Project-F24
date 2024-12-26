LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY Src_Mux IS
    PORT (
        -- input data
        ReadData1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        ReadData2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        IMM : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Fwd_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Fwd_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        IN_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        IN_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- control signals
        ALU_Src1 : IN STD_LOGIC;
        ALU_Src2 : IN STD_LOGIC;
        ForwardA: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ForwardB: IN STD_LOGIC_VECTOR(2 DOWNTO 0);        

        Src1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Src2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY Src_Mux;

ARCHITECTURE Src_Mux_arch OF Src_Mux IS
    

BEGIN
    Src1 <=  ReadData1 when ALU_Src1 = '0' AND ForwardA(2) = '1' else
        IMM when ALU_Src1 = '1' else 
        Fwd_Ex_Mem when ForwardA = "000" else
        Fwd_Mem_WB when ForwardA = "001" else
        IN_Ex_Mem when ForwardA = "010" else
        IN_Mem_WB;
    Src2 <=  ReadData2 when ALU_Src2 = '0' AND ForwardB(2) = '1' else
        IMM when ALU_Src2 = '1' else 
        Fwd_Ex_Mem when ForwardB = "000" else
        Fwd_Mem_WB when ForwardB = "001" else
        IN_Ex_Mem when ForwardB = "010" else
        IN_Mem_WB;
END ARCHITECTURE;