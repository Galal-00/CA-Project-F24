LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY OUT_UNIT IS
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        -- Control signals i/p
        OUT_SIG : IN STD_LOGIC;
        -- Data i/p
        ALU_RESULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- Data o/p
        OUT_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY OUT_UNIT;

ARCHITECTURE OUT_UNIT_arch OF OUT_UNIT IS

    SIGNAL OUT_DATA_SIG : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

BEGIN

    PROCESS (CLK, RST)
    BEGIN
        IF RST = '1' THEN
            OUT_DATA_SIG <= (OTHERS => '0');
        ELSIF falling_edge(CLK) THEN
            IF OUT_SIG = '1' THEN
                OUT_DATA_SIG <= ALU_RESULT;
            END IF;
        END IF;
    END PROCESS;

    OUT_DATA <= OUT_DATA_SIG;

END ARCHITECTURE;