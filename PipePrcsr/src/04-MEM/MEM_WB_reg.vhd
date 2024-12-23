LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MEM_WB_reg IS
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        -- Control Signals i/p
        WB_SIGNALS_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        -- Data i/p
        ALU_RESULT_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        DM_DATA_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        IN_DATA_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        OP_CODE_IN : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- Control Signals o/p. WB Stage
        WB_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        -- Data o/p. WB Stage
        ALU_RESULT_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DM_DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        IN_DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        OP_CODE_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END ENTITY MEM_WB_reg;

ARCHITECTURE MEM_WB_reg_arch OF MEM_WB_reg IS

BEGIN

    PROCESS (CLK, RST)
    BEGIN
        IF RST = '1' THEN
            WB_SIGNALS_OUT <= (OTHERS => '0');
            ALU_RESULT_OUT <= (OTHERS => '0');
            DM_DATA_OUT <= (OTHERS => '0');
            Rdst_OUT <= (OTHERS => '0');
            IN_DATA_OUT <= (OTHERS => '0');
            OP_CODE_OUT <= (OTHERS => '0');
        ELSIF rising_edge(CLK) THEN
            WB_SIGNALS_OUT <= WB_SIGNALS_IN;
            ALU_RESULT_OUT <= ALU_RESULT_IN;
            DM_DATA_OUT <= DM_DATA_IN;
            Rdst_OUT <= Rdst_IN;
            IN_DATA_OUT <= IN_DATA_IN;
            OP_CODE_OUT <= OP_CODE_IN;
        END IF;
    END PROCESS;

END ARCHITECTURE;