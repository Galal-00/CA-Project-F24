LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_ID_EX_reg IS
END ENTITY tb_ID_EX_reg;

ARCHITECTURE behavior OF tb_ID_EX_reg IS
    -- Component declaration for the unit under test (UUT)
    COMPONENT ID_EX_reg
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            -- Input control signals
            EX_SIGNALS_IN : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
            MEM_SIGNALS_IN : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            WB_SIGNALS_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            -- Input data signals
            PC_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_INC_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdata1_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdata2_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rsrc1_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdst_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            IMM_OFFSET_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            OP_CODE_IN : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

            -- Output control signals
            EX_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
            MEM_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            WB_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            -- Output data signals
            PC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_INC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdata1_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdata2_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rsrc1_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdst_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            IMM_OFFSET_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            OP_CODE_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT;

    -- Testbench signals
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL EX_SIGNALS_IN : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MEM_SIGNALS_IN : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL WB_SIGNALS_IN : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_IN : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_INC_IN : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rdata1_IN : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rdata2_IN : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rsrc1_IN : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rsrc2_IN : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rdst_IN : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IMM_OFFSET_IN : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL OP_CODE_IN : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');

    SIGNAL EX_SIGNALS_OUT : STD_LOGIC_VECTOR(13 DOWNTO 0);
    SIGNAL MEM_SIGNALS_OUT : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL WB_SIGNALS_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL PC_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL PC_INC_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Rdata1_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Rdata2_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Rsrc1_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL Rsrc2_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL Rdst_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL IMM_OFFSET_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL OP_CODE_OUT : STD_LOGIC_VECTOR(4 DOWNTO 0);

    -- Clock period definition
    CONSTANT CLK_PERIOD : TIME := 100 ps;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : ID_EX_reg
    PORT MAP(
        CLK => CLK,
        RST => RST,
        EX_SIGNALS_IN => EX_SIGNALS_IN,
        MEM_SIGNALS_IN => MEM_SIGNALS_IN,
        WB_SIGNALS_IN => WB_SIGNALS_IN,
        PC_IN => PC_IN,
        PC_INC_IN => PC_INC_IN,
        Rdata1_IN => Rdata1_IN,
        Rdata2_IN => Rdata2_IN,
        Rsrc1_IN => Rsrc1_IN,
        Rsrc2_IN => Rsrc2_IN,
        Rdst_IN => Rdst_IN,
        IMM_OFFSET_IN => IMM_OFFSET_IN,
        OP_CODE_IN => OP_CODE_IN,

        EX_SIGNALS_OUT => EX_SIGNALS_OUT,
        MEM_SIGNALS_OUT => MEM_SIGNALS_OUT,
        WB_SIGNALS_OUT => WB_SIGNALS_OUT,
        PC_OUT => PC_OUT,
        PC_INC_OUT => PC_INC_OUT,
        Rdata1_OUT => Rdata1_OUT,
        Rdata2_OUT => Rdata2_OUT,
        Rsrc1_OUT => Rsrc1_OUT,
        Rsrc2_OUT => Rsrc2_OUT,
        Rdst_OUT => Rdst_OUT,
        IMM_OFFSET_OUT => IMM_OFFSET_OUT,
        OP_CODE_OUT => OP_CODE_OUT
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

        -- Test case 1: Apply sample input signals
        EX_SIGNALS_IN <= "10101010101010";
        MEM_SIGNALS_IN <= "1010101010";
        WB_SIGNALS_IN <= "0101";
        PC_IN <= "0000000000000001";
        PC_INC_IN <= "0000000000000010";
        Rdata1_IN <= "0000000000000011";
        Rdata2_IN <= "0000000000000100";
        Rsrc1_IN <= "001";
        Rsrc2_IN <= "010";
        Rdst_IN <= "011";
        IMM_OFFSET_IN <= "0000000000001000";
        OP_CODE_IN <= "10000";
        WAIT FOR CLK_PERIOD;

        -- Assert that the outputs match the inputs after the rising edge
        ASSERT (EX_SIGNALS_OUT = "10101010101010") REPORT "Testcase 1: EX_SIGNALS_OUT mismatch!" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS_OUT = "1010101010") REPORT "Testcase 1: MEM_SIGNALS_OUT mismatch!" SEVERITY ERROR;
        ASSERT (WB_SIGNALS_OUT = "0101") REPORT "Testcase 1: WB_SIGNALS_OUT mismatch!" SEVERITY ERROR;
        ASSERT (PC_OUT = "0000000000000001") REPORT "Testcase 1: PC_OUT mismatch!" SEVERITY ERROR;
        ASSERT (PC_INC_OUT = "0000000000000010") REPORT "Testcase 1: PC_INC_OUT mismatch!" SEVERITY ERROR;
        ASSERT (Rdata1_OUT = "0000000000000011") REPORT "Testcase 1: Rdata1_OUT mismatch!" SEVERITY ERROR;
        ASSERT (Rdata2_OUT = "0000000000000100") REPORT "Testcase 1: Rdata2_OUT mismatch!" SEVERITY ERROR;
        ASSERT (Rsrc1_OUT = "001") REPORT "Testcase 1: Rsrc1_OUT mismatch!" SEVERITY ERROR;
        ASSERT (Rsrc2_OUT = "010") REPORT "Testcase 1: Rsrc2_OUT mismatch!" SEVERITY ERROR;
        ASSERT (Rdst_OUT = "011") REPORT "Testcase 1: Rdst_OUT mismatch!" SEVERITY ERROR;
        ASSERT (IMM_OFFSET_OUT = "0000000000001000") REPORT "Testcase 1: IMM_OFFSET_OUT mismatch!" SEVERITY ERROR;
        ASSERT (OP_CODE_OUT = "10000") REPORT "Testcase 1: OP_CODE_OUT mismatch!" SEVERITY ERROR;
        WAIT FOR CLK_PERIOD;

        -- Test case 2: Apply another set of input signals
        EX_SIGNALS_IN <= "01010101010101";
        MEM_SIGNALS_IN <= "0101010101";
        WB_SIGNALS_IN <= "1010";
        PC_IN <= "0000000000000011";
        PC_INC_IN <= "0000000000000100";
        Rdata1_IN <= "0000000000000101";
        Rdata2_IN <= "0000000000000110";
        Rsrc1_IN <= "100";
        Rsrc2_IN <= "101";
        Rdst_IN <= "110";
        IMM_OFFSET_IN <= "0000000000001100";
        OP_CODE_IN <= "11000";
        WAIT FOR CLK_PERIOD;

        -- Assert that the outputs match the new inputs
        ASSERT (EX_SIGNALS_OUT = "01010101010101") REPORT "Testcase 2: EX_SIGNALS_OUT mismatch!" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS_OUT = "0101010101") REPORT "Testcase 2: MEM_SIGNALS_OUT mismatch!" SEVERITY ERROR;
        ASSERT (WB_SIGNALS_OUT = "1010") REPORT "Testcase 2: WB_SIGNALS_OUT mismatch!" SEVERITY ERROR;
        ASSERT (PC_OUT = "0000000000000011") REPORT "Testcase 2: PC_OUT mismatch!" SEVERITY ERROR;
        ASSERT (PC_INC_OUT = "0000000000000100") REPORT "Testcase 2: PC_INC_OUT mismatch!" SEVERITY ERROR;
        ASSERT (Rdata1_OUT = "0000000000000101") REPORT "Testcase 2: Rdata1_OUT mismatch!" SEVERITY ERROR;
        ASSERT (Rdata2_OUT = "0000000000000110") REPORT "Testcase 2: Rdata2_OUT mismatch!" SEVERITY ERROR;
        ASSERT (Rsrc1_OUT = "100") REPORT "Testcase 2: Rsrc1_OUT mismatch!" SEVERITY ERROR;
        ASSERT (Rsrc2_OUT = "101") REPORT "Testcase 2: Rsrc2_OUT mismatch!" SEVERITY ERROR;
        ASSERT (Rdst_OUT = "110") REPORT "Testcase 2: Rdst_OUT mismatch!" SEVERITY ERROR;
        ASSERT (IMM_OFFSET_OUT = "0000000000001100") REPORT "Testcase 2: IMM_OFFSET_OUT mismatch!" SEVERITY ERROR;
        ASSERT (OP_CODE_OUT = "11000") REPORT "Testcase 2: OP_CODE_OUT mismatch!" SEVERITY ERROR;

        -- Finish the simulation
        WAIT;
    END PROCESS;
END ARCHITECTURE behavior;