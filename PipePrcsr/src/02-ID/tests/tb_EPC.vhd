LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_EPC IS
END ENTITY;

ARCHITECTURE behavior OF tb_EPC IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT EPC
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;

            PC_D : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_EX : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            EXP_SRC : IN STD_LOGIC;
            Store_EN : IN STD_LOGIC;

            EPC_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals to connect to the UUT
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL PC_D : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_EX : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL EXP_SRC : STD_LOGIC := '0';
    SIGNAL Store_EN : STD_LOGIC := '0';
    SIGNAL EPC_data : STD_LOGIC_VECTOR(15 DOWNTO 0);

    -- Clock period definition
    CONSTANT CLK_PERIOD : TIME := 100 ps;

    -- Zero vector for data
    CONSTANT ZERO_VECTOR : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : EPC
    PORT MAP(
        CLK => CLK,
        RST => RST,
        PC_D => PC_D,
        PC_EX => PC_EX,
        EXP_SRC => EXP_SRC,
        Store_EN => Store_EN,
        EPC_data => EPC_data
    );

    -- Clock process
    clk_process : PROCESS
        VARIABLE cycles : INTEGER := 0;
        CONSTANT max_cycles : INTEGER := 100; -- Set maximum clock cycles
    BEGIN
        WHILE cycles < max_cycles LOOP
            CLK <= '1';
            WAIT FOR CLK_PERIOD / 2;
            CLK <= '0';
            WAIT FOR CLK_PERIOD / 2;
            cycles := cycles + 1;
        END LOOP;
        WAIT;
    END PROCESS;

    -- Stimulus process
    stimulus : PROCESS
    BEGIN
        -- Reset the system
        RST <= '1';
        WAIT FOR CLK_PERIOD;
        RST <= '0';

        -- Test case 1: Store PC_D when Store_EN = 1 and EXP_SRC = 0
        Store_EN <= '1';
        EXP_SRC <= '0';
        PC_D <= X"1234";
        WAIT FOR CLK_PERIOD;
        ASSERT (EPC_data = X"1234")
        REPORT "Test case 1 failed: EPC_data did not store PC_D."
            SEVERITY ERROR;

        -- Test case 2: Store PC_EX when Store_EN = 1 and EXP_SRC = 1
        EXP_SRC <= '1';
        PC_EX <= X"5678";
        WAIT FOR CLK_PERIOD;
        ASSERT (EPC_data = X"5678")
        REPORT "Test case 2 failed: EPC_data did not store PC_EX."
            SEVERITY ERROR;

        -- Test case 3: No change when Store_EN = 0
        Store_EN <= '0';
        PC_D <= X"9ABC";
        PC_EX <= X"DEF0";
        WAIT FOR CLK_PERIOD;
        ASSERT (EPC_data = X"5678")
        REPORT "Test case 3 failed: EPC_data changed when Store_EN = 0."
            SEVERITY ERROR;

        -- Test case 4: Reset behavior
        RST <= '1';
        WAIT FOR CLK_PERIOD;
        RST <= '0';
        ASSERT (EPC_data = ZERO_VECTOR)
        REPORT "Test case 4 failed: EPC_data did not reset to zero."
            SEVERITY ERROR;

        -- End simulation
        WAIT;
    END PROCESS;

END ARCHITECTURE;