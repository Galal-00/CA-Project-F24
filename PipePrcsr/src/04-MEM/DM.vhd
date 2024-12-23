LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY DM IS
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        -- Control Signals i/p
        MEM_READ : IN STD_LOGIC;
        MEM_WRITE : IN STD_LOGIC;
        DM_ADDR_SIG : IN STD_LOGIC;
        CALL_OR_INT : IN STD_LOGIC;
        -- Data i/p
        ALU_RESULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        SP_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdata1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_INC_MODIFIED : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- Data o/p
        DM_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY DM;

ARCHITECTURE DM_arch OF DM IS

    TYPE mem_type IS ARRAY (2 ** 12 - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL memory : mem_type;

    SIGNAL DM_DATA_OUT_SIG : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL DM_ADDR : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL DM_DATA_IN_SIG : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

    PROCESS (CLK, RST)
    BEGIN
        IF RST = '1' THEN
            memory <= (OTHERS => (OTHERS => '0'));
        ELSIF falling_edge(CLK) THEN
            IF MEM_READ = '1' THEN
                DM_DATA_OUT_SIG <= memory(to_integer(unsigned(DM_ADDR)));
            ELSIF MEM_WRITE = '1' THEN
                memory(to_integer(unsigned(DM_ADDR))) <= DM_DATA_IN_SIG;
            END IF;
        END IF;
    END PROCESS;

    DM_ADDR <= ALU_RESULT WHEN DM_ADDR_SIG = '0' ELSE
        SP_INC; -- Data Memory Address. 
    DM_DATA_IN_SIG <= Rdata1 WHEN CALL_OR_INT = '0' ELSE
        PC_INC_MODIFIED; -- Data Memory Input.

    DM_DATA <= DM_DATA_OUT_SIG; -- Data Memory Output.

END ARCHITECTURE;