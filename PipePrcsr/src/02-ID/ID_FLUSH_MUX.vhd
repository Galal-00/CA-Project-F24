LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ID_FLUSH_MUX IS
    PORT (
        -- I/P flush, stall, pipeline control signals
        ID_EX_FLUSH : IN STD_LOGIC;
        STALL : IN STD_LOGIC;
        EX_SIGNALS_IN : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
        MEM_SIGNALS_IN : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        WB_SIGNALS_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        -- Pipeline Control Signals (EX Stage)
        EX_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
        -- Pipeline Control Signals (MEM Stage)
        MEM_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
        -- Pipeline Control Signals (WB Stage)
        WB_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')
    );
END ENTITY ID_FLUSH_MUX;

ARCHITECTURE ID_FLUSH_MUX_arch OF ID_FLUSH_MUX IS

    SIGNAL FLUSH_RESULT : STD_LOGIC := '0';

BEGIN

    FLUSH_RESULT <= ID_EX_FLUSH OR STALL;

    -- Flush Pipeline Control Signals (EX Stage)
    EX_SIGNALS_OUT <= EX_SIGNALS_IN WHEN FLUSH_RESULT = '0' ELSE
        (9 => EX_SIGNALS_IN(9), 10 => EX_SIGNALS_IN(10), 11 => EX_SIGNALS_IN(11), OTHERS => '0');
    -- Flush Pipeline Control Signals (MEM Stage)
    MEM_SIGNALS_OUT <= MEM_SIGNALS_IN WHEN FLUSH_RESULT = '0' ELSE
        (OTHERS => '0');
    -- Flush Pipeline Control Signals (WB Stage)
    WB_SIGNALS_OUT <= WB_SIGNALS_IN WHEN FLUSH_RESULT = '0' ELSE
        (OTHERS => '0');

END ARCHITECTURE;