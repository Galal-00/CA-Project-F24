LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_IF_Stage IS
END ENTITY tb_IF_Stage;

ARCHITECTURE behavior OF tb_IF_Stage IS
    -- Component declaration for the unit under test (UUT)
    COMPONENT IF_Stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        --EX jump address
        jump_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        --RET_RTI address MEM
        RET_RTI_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- Control Inputs
        -- EXP_SIG 0, EXP_NUM 1, INT_SIG 2, INT_NUM 3
        IF_SIGNALS_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        --Mem_Control_Sigs(7) : Is_RET_RTI EX mem reg
        is_RET_RTI : IN STD_LOGIC;
        -- PCsrc Signal from execute stage
        PCsrc : IN STD_LOGIC;
        --HazardUnit Signals
        IF_ID_write : IN STD_LOGIC;
        IF_ID_flush : IN STD_LOGIC;
        PC_stall : IN STD_LOGIC;

        --OUTPUTS
        -- PC output
        PC_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_out_inc : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)

    );
    END COMPONENT;

    -- Testbench signals
    SIGNAL CLK             : STD_LOGIC := '0';
    SIGNAL RST             : STD_LOGIC := '0';
    SIGNAL jump_addr       : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL RET_RTI_addr    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IF_SIGNALS_IN   : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL is_RET_RTI      : STD_LOGIC := '0';
    SIGNAL PCsrc           : STD_LOGIC := '0';
    SIGNAL IF_ID_write     : STD_LOGIC := '0';
    SIGNAL IF_ID_flush     : STD_LOGIC := '0';
    SIGNAL PC_stall        : STD_LOGIC := '0';

    SIGNAL PC_out          : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL PC_out_inc      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Instruction     : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Clock period definition
    CONSTANT CLK_PERIOD : TIME := 100 ps;
    

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: IF_Stage
        PORT MAP (
            clk             => CLK,
            reset           => RST,
            jump_addr       => jump_addr,
            RET_RTI_addr    => RET_RTI_addr,
            IF_SIGNALS_IN   => IF_SIGNALS_IN,
            is_RET_RTI      => is_RET_RTI,
            PCsrc           => PCsrc,
            IF_ID_write     => IF_ID_write,
            IF_ID_flush     => IF_ID_flush,
            PC_stall        => PC_stall,
            PC_out          => PC_out,
            PC_out_inc      => PC_out_inc,
            Instruction     => Instruction
        );
        

    -- Clock process
    clk_process : PROCESS
        VARIABLE cycles : INTEGER := 0;
        CONSTANT max_cycles : INTEGER := 10; -- Set maximum clock cycles
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

    -- Stimulus process with assertions
    STIMULUS_PROCESS : PROCESS
    BEGIN
        -- Apply reset
        RST <= '1';
        WAIT FOR CLK_PERIOD;
        RST <= '0';
        WAIT FOR CLK_PERIOD;

        -- I am using the hardcoded test instructions in Instruction_Memory.vhd!

        -- Test Case 1
        -- Jump to instruction no. 1024 (NOP)
        jump_addr <= std_logic_vector(to_unsigned(1536, 16));
        RET_RTI_addr <= x"0001";
        IF_SIGNALS_IN <= "0000";
        is_RET_RTI <= '0';
        PCsrc <= '0';
        IF_ID_write <= '1';
        IF_ID_flush <= '0';
        PC_stall <= '0';

        -- Wait for signal propagation
        WAIT FOR CLK_PERIOD;
        PCsrc <= '1';
        WAIT FOR CLK_PERIOD;
        PCsrc <= '0';
        WAIT FOR CLK_PERIOD;

        -- Add assertions for Test Case 1
        ASSERT PC_out = std_logic_vector(to_unsigned(1536, 16))
            REPORT "PC_out mismatch in Test Case 1! Expected: " & integer'image(1536) & ", Got: " & integer'image(to_integer(unsigned(PC_out))) SEVERITY ERROR;
        ASSERT PC_out_inc = std_logic_vector(to_unsigned(1537, 16))
            REPORT "PC_out_inc mismatch in Test Case 1! Expected: " & integer'image(1537) & ", Got: " & integer'image(to_integer(unsigned(PC_out_inc))) SEVERITY ERROR;
        ASSERT Instruction(15 DOWNTO 0) = x"0000"
            REPORT "Instruction mismatch in Test Case 1! Expected: 0000, Got: " & integer'image(to_integer(unsigned(Instruction(15 DOWNTO 0)))) SEVERITY ERROR;
        REPORT "Test Case 1: jump_addr = " & integer'image(to_integer(unsigned(jump_addr)));

        -- -- Test Case 2
        -- -- Initialize the input signals with new values
        -- jump_addr <= x"0002";
        -- RET_RTI_addr <= x"0003";
        -- IF_SIGNALS_IN <= "0010";
        -- is_RET_RTI <= '1';
        -- PCsrc <= '1';
        -- IF_ID_write <= '0';
        -- IF_ID_flush <= '1';
        -- PC_stall <= '1';

        -- -- Wait for signal propagation
        -- WAIT FOR CLK_PERIOD;

        -- -- Add assertions for Test Case 2
        -- ASSERT PC_out = x"0002"
        --     REPORT "PC_out mismatch in Test Case 2!" SEVERITY ERROR;
        -- ASSERT PC_out_inc = x"0003"
        --     REPORT "PC_out_inc mismatch in Test Case 2!" SEVERITY ERROR;
        -- ASSERT Instruction = x"00000001"
        --     REPORT "Instruction mismatch in Test Case 2!" SEVERITY ERROR;

        -- -- Test Case 3
        -- -- Initialize the input signals with different values
        -- jump_addr <= x"0010";
        -- RET_RTI_addr <= x"0011";
        -- IF_SIGNALS_IN <= "0100";
        -- is_RET_RTI <= '0';
        -- PCsrc <= '0';
        -- IF_ID_write <= '1';
        -- IF_ID_flush <= '0';
        -- PC_stall <= '0';

        -- -- Wait for signal propagation
        -- WAIT FOR CLK_PERIOD;

        -- -- Add assertions for Test Case 3
        -- ASSERT PC_out = x"0010"
        --     REPORT "PC_out mismatch in Test Case 3!" SEVERITY ERROR;
        -- ASSERT PC_out_inc = x"0011"
        --     REPORT "PC_out_inc mismatch in Test Case 3!" SEVERITY ERROR;
        -- ASSERT Instruction = x"00000010"
        --     REPORT "Instruction mismatch in Test Case 3!" SEVERITY ERROR;
        
        -- -- End the simulation
        WAIT;
    END PROCESS;
END ARCHITECTURE behavior;
