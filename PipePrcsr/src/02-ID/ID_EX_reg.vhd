LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ID_EX_reg IS

    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        -- Input control signals
        EX_SIGNALS_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        MEM_SIGNALS_IN : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        WB_SIGNALS_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        -- Input data signals
        PC_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_INC_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdata1_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdata2_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rsrc1_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc2_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rdst_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        IMM_OFFSET_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        OP_CODE_IN : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

        -- Output control signals:
        --  1) EX stage
        EX_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        --  2) MEM stage
        MEM_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
        --  3) WB stage
        WB_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
        -- Output data signals
        PC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        PC_INC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        Rdata1_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        Rdata2_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        Rsrc1_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
        Rsrc2_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
        Rdst_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
        IMM_OFFSET_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        OP_CODE_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0')
    );

END ENTITY ID_EX_reg;
ARCHITECTURE ID_EX_reg_arch OF ID_EX_reg IS
BEGIN
    PROCESS (CLK, RST)
    BEGIN
        IF (RST = '1') THEN
            -- Reset output signals
            -- Control signals:
            --  1) EX Stage
            EX_SIGNALS_OUT <= (OTHERS => '0');
            --  2) MEM Stage
            MEM_SIGNALS_OUT <= (OTHERS => '0');
            --  3) WB Stage
            WB_SIGNALS_OUT <= (OTHERS => '0');
            -- Data signals
            PC_OUT <= (OTHERS => '0');
            PC_INC_OUT <= (OTHERS => '0');
            Rdata1_OUT <= (OTHERS => '0');
            Rdata2_OUT <= (OTHERS => '0');
            Rsrc1_OUT <= (OTHERS => '0');
            Rsrc2_OUT <= (OTHERS => '0');
            Rdst_OUT <= (OTHERS => '0');
            IMM_OFFSET_OUT <= (OTHERS => '0');
            OP_CODE_OUT <= (OTHERS => '0');
        ELSIF rising_edge(CLK) THEN
            -- Update output signals on the rising edge
            -- Control signals:
            --  1) EX Stage
            EX_SIGNALS_OUT <= EX_SIGNALS_IN;
            --  2) MEM Stage
            MEM_SIGNALS_OUT <= MEM_SIGNALS_IN;
            --  3) WB Stage
            WB_SIGNALS_OUT <= WB_SIGNALS_IN;
            -- Data signals
            PC_OUT <= PC_IN;
            PC_INC_OUT <= PC_INC_IN;
            Rdata1_OUT <= Rdata1_IN;
            Rdata2_OUT <= Rdata2_IN;
            Rsrc1_OUT <= Rsrc1_IN;
            Rsrc2_OUT <= Rsrc2_IN;
            Rdst_OUT <= Rdst_IN;
            IMM_OFFSET_OUT <= IMM_OFFSET_IN;
            OP_CODE_OUT <= OP_CODE_IN;
        END IF;
    END PROCESS;

END ARCHITECTURE;