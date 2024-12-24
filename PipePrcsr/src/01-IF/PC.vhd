--16-bit program counter
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY PC IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        pc_mux_out : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        pc_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- Stall signal to stop the PC from incrementing
        stall : IN STD_LOGIC
    );
END PC;

ARCHITECTURE PC_arch OF PC IS
    SIGNAL pc_reg : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            pc_reg <= pc_mux_out;
        ELSIF clk'EVENT AND clk = '1' THEN
            IF stall = '0' THEN
                pc_reg <= pc_mux_out;
            END IF;
        END IF;
    END PROCESS;
    pc_out <= pc_reg;
END PC_arch;