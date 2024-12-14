LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_ID_FLUSH_MUX IS
END ENTITY;

ARCHITECTURE behavior OF tb_ID_FLUSH_MUX IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT ID_FLUSH_MUX
        PORT (
            ID_EX_FLUSH : IN STD_LOGIC;
            STALL : IN STD_LOGIC;
            EX_SIGNALS_IN : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
            MEM_SIGNALS_IN : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            WB_SIGNALS_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            EX_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
            MEM_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            WB_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals to connect to the UUT
    SIGNAL ID_EX_FLUSH : STD_LOGIC := '0';
    SIGNAL STALL : STD_LOGIC := '0';
    SIGNAL EX_SIGNALS_IN : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MEM_SIGNALS_IN : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL WB_SIGNALS_IN : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL EX_SIGNALS_OUT : STD_LOGIC_VECTOR(13 DOWNTO 0);
    SIGNAL MEM_SIGNALS_OUT : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL WB_SIGNALS_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- Zero vector for data
    CONSTANT EX_ZERO_VECTOR : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
    CONSTANT MEM_ZERO_VECTOR : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    CONSTANT WB_ZERO_VECTOR : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : ID_FLUSH_MUX
    PORT MAP(
        ID_EX_FLUSH => ID_EX_FLUSH,
        STALL => STALL,
        EX_SIGNALS_IN => EX_SIGNALS_IN,
        MEM_SIGNALS_IN => MEM_SIGNALS_IN,
        WB_SIGNALS_IN => WB_SIGNALS_IN,
        EX_SIGNALS_OUT => EX_SIGNALS_OUT,
        MEM_SIGNALS_OUT => MEM_SIGNALS_OUT,
        WB_SIGNALS_OUT => WB_SIGNALS_OUT
    );

    -- Stimulus process
    stimulus : PROCESS
    BEGIN
        -- Test case 1: No flush, no stall
        ID_EX_FLUSH <= '0';
        STALL <= '0';
        EX_SIGNALS_IN <= "11111111111111"; -- 14-bit binary. 0x3FFF
        MEM_SIGNALS_IN <= "1111111111"; -- 10-bit binary. 0x1FF
        WB_SIGNALS_IN <= "1111"; -- 4-bit binary. 0xF
        WAIT FOR 100 ps;
        ASSERT (EX_SIGNALS_OUT = "11111111111111" AND MEM_SIGNALS_OUT = "1111111111" AND WB_SIGNALS_OUT = "1111")
        REPORT "Test case 1 failed: Signals not passed through correctly." SEVERITY ERROR;

        -- Test case 2: Flush active
        ID_EX_FLUSH <= '1';
        WAIT FOR 100 ps;
        ASSERT (EX_SIGNALS_OUT = EX_ZERO_VECTOR AND MEM_SIGNALS_OUT = MEM_ZERO_VECTOR AND WB_SIGNALS_OUT = WB_ZERO_VECTOR)
        REPORT "Test case 2 failed: Signals not flushed correctly."
            SEVERITY ERROR;

        -- Test case 3: Stall active
        ID_EX_FLUSH <= '0';
        STALL <= '1';
        WAIT FOR 100 ps;
        ASSERT (EX_SIGNALS_OUT = EX_ZERO_VECTOR AND MEM_SIGNALS_OUT = MEM_ZERO_VECTOR AND WB_SIGNALS_OUT = WB_ZERO_VECTOR)
        REPORT "Test case 3 failed: Signals not stalled correctly."
            SEVERITY ERROR;

        -- Test case 4: Flush and stall both inactive
        ID_EX_FLUSH <= '0';
        STALL <= '0';
        EX_SIGNALS_IN <= "00010010001101"; -- 14-bit binary. 0x048D
        MEM_SIGNALS_IN <= "0000001111"; -- 10-bit binary. 0x0F
        WB_SIGNALS_IN <= "1111"; -- 4-bit binary. 0xF
        WAIT FOR 100 ps;
        ASSERT (EX_SIGNALS_OUT = "00010010001101" AND MEM_SIGNALS_OUT = "0000001111" AND WB_SIGNALS_OUT = "1111")
        REPORT "Test case 4 failed: Signals not passed through correctly after flush/stall inactive."
            SEVERITY ERROR;

        -- End simulation
        WAIT;
    END PROCESS;

END ARCHITECTURE;