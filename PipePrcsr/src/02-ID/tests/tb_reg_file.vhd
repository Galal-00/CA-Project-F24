LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_reg_file IS
END ENTITY;

ARCHITECTURE behavior OF tb_reg_file IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT reg_file
        GENERIC (
            address_bits : INTEGER := 3;
            word_width : INTEGER := 16
        );
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            RegWrite : IN STD_LOGIC;

            Rdst : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
            WR_data : IN STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);

            Rsrc1 : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
            Rdata1 : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);

            Rsrc2 : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
            Rdata2 : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- Signal declarations
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL RegWrite : STD_LOGIC := '0';

    SIGNAL Rdst : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL WR_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    SIGNAL Rsrc1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rdata1 : STD_LOGIC_VECTOR(15 DOWNTO 0);

    SIGNAL Rsrc2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rdata2 : STD_LOGIC_VECTOR(15 DOWNTO 0);

    -- Clock period definition
    CONSTANT CLK_PERIOD : TIME := 100 ps;

    -- Zero vector for data
    CONSTANT ZERO_VECTOR : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : reg_file
    GENERIC MAP(
        address_bits => 3,
        word_width => 16
    )
    PORT MAP(
        CLK => CLK,
        RST => RST,
        RegWrite => RegWrite,
        Rdst => Rdst,
        WR_data => WR_data,
        Rsrc1 => Rsrc1,
        Rdata1 => Rdata1,
        Rsrc2 => Rsrc2,
        Rdata2 => Rdata2
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
        -- Reset all registers
        RST <= '1';
        WAIT FOR CLK_PERIOD;
        RST <= '0';

        -- Write to register 1
        RegWrite <= '1';
        Rdst <= "001"; -- Address 1
        WR_data <= X"1234"; -- Data to write
        WAIT FOR CLK_PERIOD;

        -- Write to register 2
        Rdst <= "010"; -- Address 2
        WR_data <= X"5678"; -- Data to write
        WAIT FOR CLK_PERIOD;

        -- Disable write
        RegWrite <= '0';

        -- Read from register 1
        Rsrc1 <= "001";
        WAIT FOR CLK_PERIOD;

        ASSERT Rdata1 = x"1234"
        REPORT "Error: Rdata1 did not match expected value 0x1234."
            SEVERITY ERROR;

        -- Read from register 2
        Rsrc2 <= "010";
        WAIT FOR CLK_PERIOD;
        ASSERT Rdata2 = x"5678"
        REPORT "Error: Rdata2 did not match expected value 0x5678."
            SEVERITY ERROR;

        -- Read from uninitialized register (address 3)
        Rsrc1 <= "011";
        WAIT FOR CLK_PERIOD;
        ASSERT Rdata1 = ZERO_VECTOR
        REPORT "Error: Rdata1 did not match expected uninitialized value."
            SEVERITY ERROR;

        -- End simulation
        WAIT;
    END PROCESS;

END ARCHITECTURE;