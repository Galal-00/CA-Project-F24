
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY SP_Inc_Block IS
    PORT (
        Clk : IN STD_LOGIC;
        Rst : IN STD_LOGIC;
        SP_EN : IN STD_LOGIC;
        SP_INC : IN STD_LOGIC;

        SP_Write_Data : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- comes from the mem stage
        SP_inc_data_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- goes to the mem stage
    );
END ENTITY SP_Inc_Block;

ARCHITECTURE SP_Inc_Block OF SP_Inc_Block IS
    SIGNAL SP_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '1'); -- starts at location 2^12 - 1 (end of mem)
    SIGNAL SP_Adrr : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
    PROCESS (Clk, Rst)
    BEGIN
        IF Rst = '1' THEN
            SP_reg <= (OTHERS => '1');
        ELSIF falling_edge(Clk) THEN
            IF SP_EN = '1' THEN
                SP_reg <= SP_Write_Data;
            END IF;

        END IF;
    END PROCESS;

    SP_Adrr <= SP_reg;

    WITH SP_INC SELECT
        SP_inc_data_Out <= STD_LOGIC_VECTOR(unsigned(SP_Adrr) + 1) WHEN '1',
        SP_Adrr WHEN OTHERS;

    -- IF SP_INC = '1' THEN
    --     SP_inc_data_Out <= STD_LOGIC_VECTOR(unsigned(SP_Adrr) + 1);
    -- ELSE
    --     SP_inc_data_Out <= SP_Adrr;
    -- END IF;

END ARCHITECTURE;