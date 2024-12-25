LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Rdata1_MUX IS
    PORT (
        -- FWD unit i/p
        ForwardA : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- Choices
        ReadData1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Fwd_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Fwd_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        IN_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        IN_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- data o/p
        FWD_ReadData1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY Rdata1_MUX;

ARCHITECTURE Rdata1_MUX_arch OF Rdata1_MUX IS

BEGIN

    FWD_ReadData1 <= ReadData1 WHEN ForwardA(2) = '1' ELSE
        Fwd_Ex_Mem WHEN ForwardA = "000" ELSE
        Fwd_Mem_WB WHEN ForwardA = "001" ELSE
        IN_Ex_Mem WHEN ForwardA = "010" ELSE
        IN_Mem_WB;

END ARCHITECTURE;