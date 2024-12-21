--Fetch Control Unit
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY FCU IS
    PORT (
        -- Inputs
        OPcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- Outputs
        PC_inc_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END FCU;

ARCHITECTURE FCU_arch OF FCU IS
BEGIN
                    -- HLT = 00001
    PC_inc_sel <=  "00" WHEN OPcode = "00001" ELSE
                    -- IADD = 01011, LDM = 01110, LDD = 01111, STD = 10000
                    "10" WHEN (OPcode = "01011" OR OPcode = "01110" OR OPcode = "01111" OR OPcode = "10000")
                    ELSE
                    "01";
END FCU_arch;