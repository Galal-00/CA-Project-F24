LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY ForwardingUnit IS
    PORT (
        -- input data
        EX_MEM_RegWrite : IN STD_LOGIC;
        MEM_WB_RegWrite : IN STD_LOGIC;
        Rdst_Ex_Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rdst_Mem_Wb : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc1_ID_EX : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc2_ID_EX : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        OpCode_Mem : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        OpCode_Wb : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

        -- output signals
        ForwardA : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ForwardB : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)

    );
END ENTITY ForwardingUnit;

ARCHITECTURE ForwardingUnit_arch OF ForwardingUnit IS

BEGIN
    ForwardA <= "000" WHEN (EX_MEM_RegWrite = '1' AND Rdst_Ex_Mem = Rsrc1_ID_EX AND NOT (OpCode_Mem = "00110")) ELSE
        "001" WHEN (MEM_WB_RegWrite = '1' AND Rdst_Mem_Wb = Rsrc1_ID_EX AND NOT (OpCode_Wb = "00110")
        AND NOT (EX_MEM_RegWrite = '1' AND Rdst_Ex_Mem = Rsrc1_ID_EX AND NOT (OpCode_Mem = "00110"))) ELSE
        "010" WHEN (EX_MEM_RegWrite = '1' AND Rdst_Ex_Mem = Rsrc1_ID_EX AND OpCode_Mem = "00110") ELSE
        "011" WHEN (MEM_WB_RegWrite = '1' AND Rdst_Mem_Wb = Rsrc1_ID_EX AND OpCode_Wb = "00110"
        AND NOT (EX_MEM_RegWrite = '1' AND Rdst_Ex_Mem = Rsrc1_ID_EX)) ELSE
        "100";
    ForwardB <= "000" WHEN (EX_MEM_RegWrite = '1' AND Rdst_Ex_Mem = Rsrc2_ID_EX AND NOT (OpCode_Mem = "00110")) ELSE
        "001" WHEN (MEM_WB_RegWrite = '1' AND Rdst_Mem_Wb = Rsrc2_ID_EX AND NOT (OpCode_Wb = "00110")
        AND NOT (EX_MEM_RegWrite = '1' AND Rdst_Ex_Mem = Rsrc2_ID_EX AND NOT (OpCode_Mem = "00110"))) ELSE
        "010" WHEN (EX_MEM_RegWrite = '1' AND Rdst_Ex_Mem = Rsrc2_ID_EX AND OpCode_Mem = "00110") ELSE
        "011" WHEN (MEM_WB_RegWrite = '1' AND Rdst_Mem_Wb = Rsrc2_ID_EX AND OpCode_Wb = "00110"
        AND NOT (EX_MEM_RegWrite = '1' AND Rdst_Ex_Mem = Rsrc2_ID_EX)) ELSE
        "100";
END ARCHITECTURE;