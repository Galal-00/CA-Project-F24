LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY Flags_reg IS
    PORT (
        Clk            : IN  STD_LOGIC;
        Flags          : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        Flags_Popped   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); -- received from mem stage
        Set_Flags      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        Update_Flags   : IN  STD_LOGIC; -- received from mem stage
        Reset_Flags    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);

        Flags_Out      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY Flags_reg;

ARCHITECTURE Flags_reg_arch OF Flags_reg IS
    SIGNAL Flags_reg : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS (Clk,Reset_Flags)
    BEGIN
        IF Reset_Flags /= "000" THEN
            FOR i IN 0 TO 2 LOOP
                IF Reset_Flags(i) = '1' THEN
                    Flags_reg(i) <= '0';
                END IF;
            END LOOP;
        ELSIF falling_edge(Clk) THEN
            IF Update_Flags = '1' THEN
                Flags_reg <= Flags_Popped;
            ELSE
                FOR i IN 0 TO 2 LOOP
                    IF Set_Flags(i) = '1' THEN
                        Flags_reg(i) <= Flags(i);
                    END IF;
                END LOOP;
            END IF;
        END IF;
    END PROCESS;
    -- output
    Flags_Out <= Flags_reg;

END ARCHITECTURE;
