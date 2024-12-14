LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_ID IS
END ENTITY tb_ID;

ARCHITECTURE behavior OF tb_ID IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT ID IS
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;

            PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            INSTR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            FLUSH : IN STD_LOGIC;
            ID_EX_MEM_READ : IN STD_LOGIC;
            ID_EX_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ALU_RESULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            SP_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_EX : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            EX_OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

            RegWrite : IN STD_LOGIC;
            Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            WR_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            MEM_OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

            IF_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            ALU_SRC1 : OUT STD_LOGIC;
            ALU_SRC2 : OUT STD_LOGIC;
            JUMP_UNCOND : OUT STD_LOGIC;
            BRANCH : OUT STD_LOGIC;
            JUMP_COND : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            SET_FLAGS : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            RESET_FLAGS : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            SP_INC_SIG : OUT STD_LOGIC;
            MEM_READ : OUT STD_LOGIC;

            MEM_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            WB_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

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

    -- Signals for the UUT inputs
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';

    SIGNAL PC : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_INC : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL INSTR : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    SIGNAL FLUSH : STD_LOGIC := '0';
    SIGNAL ID_EX_MEM_READ : STD_LOGIC := '0';
    SIGNAL ID_EX_Rdst : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ALU_RESULT : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL SP_INC : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_EX : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL EX_OpCode : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');

    SIGNAL RegWrite : STD_LOGIC := '0';
    SIGNAL Rdst : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL WR_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MEM_OpCode : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');

    -- Signals for the UUT outputs
    SIGNAL IF_SIGNALS_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL ALU_SRC1 : STD_LOGIC;
    SIGNAL ALU_SRC2 : STD_LOGIC;
    SIGNAL JUMP_UNCOND : STD_LOGIC;
    SIGNAL BRANCH : STD_LOGIC;
    SIGNAL JUMP_COND : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL SET_FLAGS : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL RESET_FLAGS : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL SP_INC_SIG : STD_LOGIC;
    SIGNAL MEM_READ : STD_LOGIC;

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
    uut : ID PORT MAP(
        CLK => CLK,
        RST => RST,
        PC => PC,
        PC_INC => PC_INC,
        INSTR => INSTR,
        FLUSH => FLUSH,
        ID_EX_MEM_READ => ID_EX_MEM_READ,
        ID_EX_Rdst => ID_EX_Rdst,
        ALU_RESULT => ALU_RESULT,
        SP_INC => SP_INC,
        PC_EX => PC_EX,
        EX_OpCode => EX_OpCode,
        RegWrite => RegWrite,
        Rdst => Rdst,
        WR_data => WR_data,
        MEM_OpCode => MEM_OpCode,
        IF_SIGNALS_OUT => IF_SIGNALS_OUT,
        ALU_SRC1 => ALU_SRC1,
        ALU_SRC2 => ALU_SRC2,
        JUMP_UNCOND => JUMP_UNCOND,
        BRANCH => BRANCH,
        JUMP_COND => JUMP_COND,
        SET_FLAGS => SET_FLAGS,
        RESET_FLAGS => RESET_FLAGS,
        SP_INC_SIG => SP_INC_SIG,
        MEM_READ => MEM_READ,
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

    -- Stimulus process
    stimulus_process : PROCESS
    BEGIN
        -- Reset the system
        RST <= '1';
        WAIT FOR CLK_PERIOD;
        RST <= '0';

        -- Provide test stimulus
        PC <= X"0001";
        PC_INC <= X"0002";
        INSTR <= "00000000000011111000011100000000"; -- STD Rsrc1[111], OFFSET(Rsrc2[000]). OFFSET = 0x000F
        FLUSH <= '0';
        ID_EX_MEM_READ <= '0';
        ID_EX_Rdst <= "101";
        ALU_RESULT <= X"FFFF";
        SP_INC <= X"0FFF";
        PC_EX <= X"0000";
        EX_OpCode <= "00000";
        RegWrite <= '1';
        Rdst <= "111";
        WR_data <= X"0001";
        MEM_OpCode <= "00000";

        -- Wait for the next clock cycle and
        -- give time for the output signals to be updated
        WAIT FOR CLK_PERIOD + 1ps;

        -- Assertions
        ASSERT (IF_SIGNALS_OUT = "0000") REPORT "Test failed: IF_SIGNALS_OUT not equal '0000'." SEVERITY ERROR;
        ASSERT (ALU_SRC1 = '1') REPORT "Test failed: ALU_SRC1 not equal '1'." SEVERITY ERROR;
        ASSERT (ALU_SRC2 = '0') REPORT "Test failed: ALU_SRC2 not equal '0'." SEVERITY ERROR;
        ASSERT (JUMP_UNCOND = '0') REPORT "Test failed: JUMP_UNCOND not equal '0'." SEVERITY ERROR;
        ASSERT (BRANCH = '0') REPORT "Test failed: BRANCH not equal '0'." SEVERITY ERROR;
        ASSERT (JUMP_COND = "00") REPORT "Test failed: JUMP_COND not equal '00'." SEVERITY ERROR;
        ASSERT (SET_FLAGS = "000") REPORT "Test failed: SET_FLAGS not equal '000'." SEVERITY ERROR;
        ASSERT (RESET_FLAGS = "000") REPORT "Test failed: RESET_FLAGS not equal '000'." SEVERITY ERROR;
        ASSERT (SP_INC_SIG = '0') REPORT "Test failed: SP_INC_SIG not equal '0'." SEVERITY ERROR;
        ASSERT (MEM_READ = '0') REPORT "Test failed: MEM_READ not equal '0'." SEVERITY ERROR;

        ASSERT (MEM_SIGNALS_OUT(1) = '1') REPORT "Test failed: MEM MEM_WRITE signal not equal '1'." SEVERITY ERROR;

        ASSERT (WB_SIGNALS_OUT = "0100") REPORT "Test failed: WB_SIGNALS_OUT not equal '0100'." SEVERITY ERROR;

        ASSERT (PC_OUT = PC) REPORT "Test failed: PC_OUT not equal PC." SEVERITY ERROR;
        ASSERT (PC_INC_OUT = PC_INC) REPORT "Test failed: PC_INC_OUT not equal PC_INC." SEVERITY ERROR;
        ASSERT (Rdata1_OUT = x"0001") REPORT "Test failed: Rdata1_OUT not equal 0x0001." SEVERITY ERROR;
        ASSERT (Rdata2_OUT = x"0000") REPORT "Test failed: Rdata2_OUT not equal 0x0000." SEVERITY ERROR;
        ASSERT (Rsrc1_OUT = "111") REPORT "Test failed: Rsrc1_OUT not equal '111'." SEVERITY ERROR;
        ASSERT (Rsrc2_OUT = "000") REPORT "Test failed: Rsrc2_OUT not equal '000'." SEVERITY ERROR;
        ASSERT (Rdst_OUT = "000") REPORT "Test failed: Rdst_OUT not equal '000'." SEVERITY ERROR;
        ASSERT (IMM_OFFSET_OUT = x"000F") REPORT "Test failed: IMM_OFFSET_OUT not equal 0x000F." SEVERITY ERROR;
        ASSERT (OP_CODE_OUT = "10000") REPORT "Test failed: OP_CODE_OUT not equal '10000'." SEVERITY ERROR;

        -- End of Testbench
        WAIT;
    END PROCESS;

END ARCHITECTURE behavior;