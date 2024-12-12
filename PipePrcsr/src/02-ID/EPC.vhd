LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY EPC IS
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;

        PC_D : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_EX : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        EXP_SRC : IN STD_LOGIC;
        Store_EN : IN STD_LOGIC;

        EPC_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY EPC;

ARCHITECTURE EPC_arch OF EPC IS

    SIGNAL data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

BEGIN

    PROCESS (CLK, RST)
    BEGIN
        IF RST = '1' THEN
            data <= (OTHERS => '0');
        ELSIF falling_edge(CLK) THEN
            IF Store_EN = '1' THEN
                IF EXP_SRC = '1' THEN
                    data <= PC_EX;
                ELSE
                    data <= PC_D;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    EPC_data <= data;

END ARCHITECTURE;