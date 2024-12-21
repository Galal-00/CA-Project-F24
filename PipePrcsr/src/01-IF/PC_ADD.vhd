--PC Adder
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY PC_ADD IS
    PORT (
        -- Inputs
        PC         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_inc_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        -- Outputs
        PC_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)

    );
END ENTITY;

ARCHITECTURE PC_ADD_arch OF PC_ADD IS
    SIGNAL PC_inc : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
    PC_inc <= PC;
    PROCESS (PC_inc_sel)
    BEGIN
        CASE PC_inc_sel IS
            WHEN "01" =>
                PC_inc <= std_logic_vector(unsigned(PC_inc) + 1);
            WHEN "10" =>
                PC_inc <= std_logic_vector(unsigned(PC_inc) + 2);
            WHEN OTHERS =>
                PC_inc <= PC_inc; 
        END CASE;
    END PROCESS;
    PC_out <= PC_inc;
END ARCHITECTURE;