LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY reg_file IS

    GENERIC (
        address_bits : INTEGER := 3;
        word_width : INTEGER := 16
    );

    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        RegWrite : IN STD_LOGIC; -- Write Enable

        Rdst : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
        WR_data : IN STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);

        Rsrc1 : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
        Rdata1 : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);

        Rsrc2 : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
        Rdata2 : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE reg_file_bhv OF reg_file IS

    TYPE reg_type IS ARRAY((2 ** address_bits) - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);
    SIGNAL Reg : reg_type;

BEGIN

    PROCESS (CLK, RST)
    BEGIN
        IF (RST = '1') THEN
            FOR loc IN 0 TO (2 ** address_bits) - 1 LOOP
                Reg(loc) <= (OTHERS => '0');
            END LOOP;
        ELSIF falling_edge(CLK) THEN
            IF RegWrite = '1' THEN
                Reg(to_integer(unsigned(Rdst))) <= WR_data;
            END IF;
        END IF;
    END PROCESS;

    Rdata1 <= Reg(to_integer(unsigned(Rsrc1)));
    Rdata2 <= Reg(to_integer(unsigned(Rsrc2)));

END ARCHITECTURE;