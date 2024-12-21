--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY PC_Mux IS
    PORT (
        -- Inputs
        PC_inc       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        jump_addr    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        RET_RTI_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        IM_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- FROM IM lower 16 bits
        -- NEXT PC UNIT Control signals
        Next_PC_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        -- Output
        PC_mux_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END PC_Mux;

ARCHITECTURE PC_Mux_arch OF PC_Mux IS
BEGIN
    PC_mux_out <=   IM_addr WHEN Next_PC_sel = "00" ELSE
                    RET_RTI_addr WHEN Next_PC_sel = "01" ELSE
                    jump_addr WHEN Next_PC_sel = "10" ELSE
                    PC_inc;
END PC_Mux_arch;
