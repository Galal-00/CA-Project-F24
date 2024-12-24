LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MEM IS
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        -- Control Signals i/p. From EX Stage
        MEM_SIGNALS : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        WB_SIGNALS_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        -- Data i/p. From EX Stage
        ALU_RESULT_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        SP_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdata1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        FLAGS : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        PC_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        IN_DATA_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        OP_CODE_IN : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- Control Signals o/p
        -- 1) IF, ID Stage
        IS_RET_RTI : OUT STD_LOGIC := '0';
        -- 2) EX Stage
        UPDATE_FLAGS : OUT STD_LOGIC := '0';
        EX_MEM_REG_WRITE : OUT STD_LOGIC := '0';
        SP_EN : OUT STD_LOGIC := '0';
        -- 3) WB Stage
        WB_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
        -- Data o/p
        -- 1) IF Stage
        RET_RTI_ADDRESS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- 2) EX Stage
        FLAGS_POPPED : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        OP_CODE_EX_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        Rdst_EX_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        SP_WRITE_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0FFF";
        -- 3) WB Stage
        ALU_RESULT_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DM_DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        IN_DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        OP_CODE_WB_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END ENTITY MEM;

ARCHITECTURE MEM_arch OF MEM IS

    COMPONENT DM IS
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
    END COMPONENT DM;

    COMPONENT PUSH_POP_FLAGS IS
        PORT (
            -- Control Signals i/p
            ADD_FLAGS : IN STD_LOGIC;
            -- Data i/p
            FLAGS : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            PC_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            DM_DATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- Data o/p
            PC_INC_MODIFIED : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            FLAGS_POPPED : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT PUSH_POP_FLAGS;

    COMPONENT SP_DEC_BLOCK IS
        PORT (
            -- Control Signals i/p
            SP_DEC_SIG : IN STD_LOGIC;
            -- Data i/p
            SP_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- Data o/p
            SP_WRITE_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT SP_DEC_BLOCK;

    COMPONENT MEM_WB_reg IS
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            -- Control Signals i/p
            WB_SIGNALS_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            -- Data i/p
            ALU_RESULT_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            DM_DATA_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            IN_DATA_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            OP_CODE_IN : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            -- Control Signals o/p. WB Stage
            WB_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            -- Data o/p. WB Stage
            ALU_RESULT_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            DM_DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            IN_DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            OP_CODE_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT MEM_WB_reg;

    SIGNAL PC_INC_MODIFIED : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    SIGNAL DM_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

BEGIN

    -- To IF Stage
    IS_RET_RTI <= MEM_SIGNALS(9);
    RET_RTI_ADDRESS <= DM_DATA;

    -- To EX Stage
    UPDATE_FLAGS <= MEM_SIGNALS(5);
    EX_MEM_REG_WRITE <= MEM_SIGNALS(4);
    SP_EN <= MEM_SIGNALS(7);
    OP_CODE_EX_OUT <= OP_CODE_IN;
    Rdst_EX_OUT <= Rdst_IN;

    -- Components Instantiation
    DM_inst : DM PORT MAP(
        CLK => CLK,
        RST => RST,
        -- Control Signals i/p
        MEM_READ => MEM_SIGNALS(0),
        MEM_WRITE => MEM_SIGNALS(1),
        DM_ADDR_SIG => MEM_SIGNALS(2),
        CALL_OR_INT => MEM_SIGNALS(3),
        -- Data i/p
        ALU_RESULT => ALU_RESULT_IN,
        SP_INC => SP_INC,
        Rdata1 => Rdata1,
        PC_INC_MODIFIED => PC_INC_MODIFIED,
        -- Data o/p
        DM_DATA => DM_DATA
    );

    PUSH_POP_FLAGS_inst : PUSH_POP_FLAGS PORT MAP(
        -- Control Signals i/p
        ADD_FLAGS => MEM_SIGNALS(6),
        -- Data i/p
        FLAGS => FLAGS,
        PC_INC => PC_INC,
        DM_DATA => DM_DATA,
        -- Data o/p
        PC_INC_MODIFIED => PC_INC_MODIFIED,
        FLAGS_POPPED => FLAGS_POPPED
    );

    SP_DEC_BLOCK_inst : SP_DEC_BLOCK PORT MAP(
        -- Control Signals i/p
        SP_DEC_SIG => MEM_SIGNALS(8),
        -- Data i/p
        SP_INC => SP_INC,
        -- Data o/p
        SP_WRITE_DATA => SP_WRITE_DATA
    );

    MEM_WB_reg_inst : MEM_WB_reg PORT MAP(
        CLK => CLK,
        RST => RST,
        -- Control Signals i/p
        WB_SIGNALS_IN => WB_SIGNALS_IN,
        -- Data i/p
        ALU_RESULT_IN => ALU_RESULT_IN,
        DM_DATA_IN => DM_DATA,
        Rdst_IN => Rdst_IN,
        IN_DATA_IN => IN_DATA_IN,
        OP_CODE_IN => OP_CODE_IN,
        -- Control Signals o/p. WB Stage
        WB_SIGNALS_OUT => WB_SIGNALS_OUT,
        -- Data o/p. WB Stage
        ALU_RESULT_OUT => ALU_RESULT_OUT,
        DM_DATA_OUT => DM_DATA_OUT,
        Rdst_OUT => Rdst_OUT,
        IN_DATA_OUT => IN_DATA_OUT,
        OP_CODE_OUT => OP_CODE_WB_OUT
    );

END ARCHITECTURE;