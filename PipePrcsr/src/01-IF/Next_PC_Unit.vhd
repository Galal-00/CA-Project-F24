--Next PC control Unit
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Next_PC_Unit IS
    PORT (
        -- Inputs
        reset      : IN STD_LOGIC;
        exp_sig    : IN STD_LOGIC;
        int_sig    : IN STD_LOGIC;
        is_RET_RTI : IN STD_LOGIC;
        -- if the instruction is a branch instruction
        PCsrc : IN STD_LOGIC;
        -- Outputs
        Next_PC : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END Next_PC_Unit;

ARCHITECTURE Next_PC_Unit_arch OF Next_PC_Unit IS
BEGIN
    Next_PC <=  "00" WHEN reset = '1' 
                    OR exp_sig = '1' 
                    OR int_sig = '1' ELSE
                "01" WHEN is_RET_RTI = '1' ELSE
                "10" WHEN PCsrc = '1' ELSE
                "11";
END Next_PC_Unit_arch;
