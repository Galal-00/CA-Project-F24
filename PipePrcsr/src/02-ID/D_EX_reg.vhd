LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY D_EX_reg IS
    GENERIC (
        address_bits : INTEGER := 3;
        word_width : INTEGER := 8;
        op_code_bits : INTEGER := 2
    );
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        
        OP_CODE_IN : IN STD_LOGIC_VECTOR(op_code_bits - 1 DOWNTO 0);
        DATA1_IN : IN STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);
        DATA2_IN : IN STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);
        Wr_addr_IN : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
        WE_IN : IN STD_LOGIC;

        OP_CODE_OUT : OUT STD_LOGIC_VECTOR(op_code_bits - 1 DOWNTO 0);
        DATA1_OUT : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);
        DATA2_OUT : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);
        Wr_addr_OUT : OUT STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
        WE_OUT : OUT STD_LOGIC

    );

END ENTITY D_EX_reg;
ARCHITECTURE D_EX_reg_arch OF D_EX_reg IS
BEGIN
    PROCESS (CLK, RST)
    BEGIN

        IF (RST = '1') THEN
            -- Reset output signals
            OP_CODE_OUT <= (OTHERS => '0');
            DATA1_OUT <= (OTHERS => '0');
            DATA2_OUT <= (OTHERS => '0');
            Wr_addr_OUT <= (OTHERS => '0');
            WE_OUT <= '0';

        ELSIF rising_edge(CLK) THEN
            -- Update output signals on the rising edge
            OP_CODE_OUT <= OP_CODE_IN;
            DATA1_OUT <= DATA1_IN;
            DATA2_OUT <= DATA2_IN;
            Wr_addr_OUT <= Wr_addr_IN;
            WE_OUT <= WE_IN;
        END IF;
    END PROCESS;

END ARCHITECTURE;