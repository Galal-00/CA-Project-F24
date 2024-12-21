--IF/ID register
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY IF_ID_reg IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        -- Inputs
        PC          : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_inc      : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- Hazard inputs
        IF_ID_write : IN STD_LOGIC;
        IF_ID_flush : IN STD_LOGIC;
        -- Outputs
        PC_out          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        PC_inc_out      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        Instruction_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0')
    );
END ENTITY;

ARCHITECTURE IF_ID_reg_arch OF IF_ID_reg IS
BEGIN
    PROCESS (clk, reset, IF_ID_write, IF_ID_flush)
    BEGIN
        IF reset = '1' OR IF_ID_flush = '1' THEN
            PC_out <= (OTHERS => '0');
            PC_inc_out <= (OTHERS => '0');
            Instruction_out <= (OTHERS => '0');
        ELSIF clk'EVENT AND clk = '1' THEN
            IF IF_ID_write = '1' THEN ----- M4 3AREF DA BY3ML EH
                PC_out <= PC;
                PC_inc_out <= PC_inc;
                Instruction_out <= Instruction;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;
