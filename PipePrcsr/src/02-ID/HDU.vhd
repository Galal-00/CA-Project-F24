LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY HDU IS
    PORT (
        -- Control signals i/p
        ID_EX_MEM_READ : IN STD_LOGIC;
        Rsrc1_EN : IN STD_LOGIC;
        Rsrc2_EN : IN STD_LOGIC;
        -- Data i/p
        ID_EX_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- Hazard Signals o/p
        STALL : OUT STD_LOGIC;
        IF_ID_WRITE : OUT STD_LOGIC
    );
END ENTITY HDU;

ARCHITECTURE HDU_arch OF HDU IS

    SIGNAL STALL_CONDITION : STD_LOGIC := '0';

BEGIN

    STALL_CONDITION <= '1' WHEN (ID_EX_MEM_READ = '1'
        AND ((ID_EX_Rdst = Rsrc1 AND Rsrc1_EN = '1')
        OR (ID_EX_Rdst = Rsrc2 AND Rsrc2_EN = '1'))) ELSE
        '0';

    STALL <= '1' WHEN STALL_CONDITION = '1' ELSE
        '0';
    IF_ID_WRITE <= '0' WHEN STALL_CONDITION = '1' ELSE
        '1';

END ARCHITECTURE;