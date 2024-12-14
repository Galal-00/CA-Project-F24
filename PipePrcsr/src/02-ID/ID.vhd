LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ID IS
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;

        -- i/p IF Signals
        PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        INSTR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- i/p EX Signals
        FLUSH : IN STD_LOGIC;
        ID_EX_MEM_READ : IN STD_LOGIC;
        ID_EX_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ALU_RESULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        SP_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_EX : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        EX_OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- i/p WB Signals
        RegWrite : IN STD_LOGIC;
        Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        WR_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        MEM_OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

        -- o/p control signals:
        --  1) IF stage
        IF_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
        --  2) EX stage
        ALU_SRC1 : OUT STD_LOGIC := '0';
        ALU_SRC2 : OUT STD_LOGIC := '0';
        JUMP_UNCOND : OUT STD_LOGIC := '0';
        BRANCH : OUT STD_LOGIC := '0';
        JUMP_COND : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
        SET_FLAGS : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
        RESET_FLAGS : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
        SP_INC_SIG : OUT STD_LOGIC := '0';
        MEM_READ : OUT STD_LOGIC := '0';
        --  3) MEM stage
        MEM_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
        --  4) WB stage
        WB_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
        -- o/p data signals
        PC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        PC_INC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        Rdata1_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        Rdata2_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        Rsrc1_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
        Rsrc2_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
        Rdst_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
        IMM_OFFSET_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        OP_CODE_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0')
    );
END ENTITY ID;

ARCHITECTURE ID_arch OF ID IS

    COMPONENT CU IS
        PORT (
            -- Inputs
            INSTR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            SP_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            ALU_RESULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            EX_Opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- Hazard Detection Unit (ID stage)
            Rsrc1_EN : OUT STD_LOGIC := '0';
            Rsrc2_EN : OUT STD_LOGIC := '0';
            -- Exceptions (ID stage)
            Store_EN_EPC : OUT STD_LOGIC := '0';
            EXP_SRC : OUT STD_LOGIC := '0';
            -- Exceptions and Interrupts (IF stage)
            IF_SIGNALS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
            -- Pipeline Control Signals (EX Stage)
            EX_SIGNALS : OUT STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
            -- Pipeline Control Signals (MEM Stage)
            MEM_SIGNALS : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
            -- Pipeline Control Signals (WB Stage)
            WB_SIGNALS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')
        );
    END COMPONENT;

    COMPONENT reg_file IS
        GENERIC (
            address_bits : INTEGER := 3;
            word_width : INTEGER := 16
        );

        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            RegWrite : IN STD_LOGIC; -- Write Enable

            Rdst : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
            WR_data : IN STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);

            Rsrc1 : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
            Rdata1 : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);

            Rsrc2 : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
            Rdata2 : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT EPC IS
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

    COMPONENT ID_FLUSH_MUX IS
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
    END COMPONENT;

    COMPONENT ID_EX_reg IS
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

            -- Output control signals:
            --  1) EX stage
            EX_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
            --  2) MEM stage
            MEM_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
            --  3) WB stage
            WB_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
            -- Output data signals
            PC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
            PC_INC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
            Rdata1_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
            Rdata2_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
            Rsrc1_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
            Rsrc2_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
            Rdst_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
            IMM_OFFSET_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
            OP_CODE_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0')
        );
    END COMPONENT;

    SIGNAL DUMMY_RSRC1_EN, DUMMY_RSRC2_EN : STD_LOGIC;
    SIGNAL DUMMY_ID_EX_FLUSH, DUMMY_STALL : STD_LOGIC := '0';

    -- EPC inputs
    SIGNAL Store_EN_EPC, EXP_SRC : STD_LOGIC := '0';
    -- EPC output
    SIGNAL EXP_PC : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    -- ID_FLUSH_MUX inputs
    SIGNAL ID_FLUSH_MUX_EX_SIGNALS_IN : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_FLUSH_MUX_MEM_SIGNALS_IN : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_FLUSH_MUX_WB_SIGNALS_IN : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');

    -- ID_EX Register inputs
    SIGNAL ID_EX_REG_EX_SIGNALS_IN : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_REG_MEM_SIGNALS_IN : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_REG_WB_SIGNALS_IN : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_Rdata1_IN, ID_EX_Rdata2_IN : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_IMM_OFFSET_IN : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    -- ID_EX Register outputs
    SIGNAL ID_EX_REG_EX_SIGNALS_OUT : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');

BEGIN

    CU_inst : CU PORT MAP(
        -- Inputs
        INSTR => INSTR, SP_INC => SP_INC, ALU_RESULT => ALU_RESULT,
        EX_OpCode => EX_OpCode, PC => PC,
        -- Hazard Detection Unit (ID stage)
        Rsrc1_EN => DUMMY_RSRC1_EN, Rsrc2_EN => DUMMY_RSRC2_EN,
        -- Exceptions (ID stage)
        Store_EN_EPC => Store_EN_EPC, EXP_SRC => EXP_SRC,
        -- Exceptions and Interrupts (IF stage)
        IF_SIGNALS => IF_SIGNALS_OUT,
        -- Pipeline Control Signals (EX Stage)
        EX_SIGNALS => ID_FLUSH_MUX_EX_SIGNALS_IN,
        -- Pipeline Control Signals (MEM Stage)
        MEM_SIGNALS => ID_FLUSH_MUX_MEM_SIGNALS_IN,
        -- Pipeline Control Signals (WB Stage)
        WB_SIGNALS => ID_FLUSH_MUX_WB_SIGNALS_IN
    );

    reg_file_inst : reg_file PORT MAP(
        CLK => CLK, RST => RST, RegWrite => RegWrite,
        Rdst => Rdst, WR_data => WR_data,
        Rsrc1 => INSTR(10 DOWNTO 8), Rdata1 => ID_EX_Rdata1_IN,
        Rsrc2 => INSTR(7 DOWNTO 5), Rdata2 => ID_EX_Rdata2_IN
    );

    EPC_inst : EPC PORT MAP(
        CLK => CLK, RST => RST,
        PC_D => PC, PC_EX => PC_EX, EXP_SRC => EXP_SRC, Store_EN => Store_EN_EPC,
        EPC_data => EXP_PC
    );

    ID_FLUSH_MUX_inst : ID_FLUSH_MUX PORT MAP(
        -- I/P flush, stall, pipeline control signals
        ID_EX_FLUSH => DUMMY_ID_EX_FLUSH, STALL => DUMMY_STALL,
        EX_SIGNALS_IN => ID_FLUSH_MUX_EX_SIGNALS_IN,
        MEM_SIGNALS_IN => ID_FLUSH_MUX_MEM_SIGNALS_IN,
        WB_SIGNALS_IN => ID_FLUSH_MUX_WB_SIGNALS_IN,
        -- Pipeline Control Signals (EX Stage)
        EX_SIGNALS_OUT => ID_EX_REG_EX_SIGNALS_IN,
        -- Pipeline Control Signals (MEM Stage)
        MEM_SIGNALS_OUT => ID_EX_REG_MEM_SIGNALS_IN,
        -- Pipeline Control Signals (WB Stage)
        WB_SIGNALS_OUT => ID_EX_REG_WB_SIGNALS_IN
    );

    ID_EX_reg_inst : ID_EX_reg PORT MAP(
        CLK => CLK, RST => RST,
        -- Input control signals
        EX_SIGNALS_IN => ID_EX_REG_EX_SIGNALS_IN,
        MEM_SIGNALS_IN => ID_EX_REG_MEM_SIGNALS_IN,
        WB_SIGNALS_IN => ID_EX_REG_WB_SIGNALS_IN,
        -- Input data signals
        PC_IN => PC, PC_INC_IN => PC_INC,
        Rdata1_IN => ID_EX_Rdata1_IN, Rdata2_IN => ID_EX_Rdata2_IN,
        Rsrc1_IN => INSTR(10 DOWNTO 8), Rsrc2_IN => INSTR(7 DOWNTO 5),
        Rdst_IN => INSTR(4 DOWNTO 2), IMM_OFFSET_IN => INSTR(31 DOWNTO 16),
        OP_CODE_IN => INSTR(15 DOWNTO 11),
        -- Output control signals:
        --  1) EX stage
        EX_SIGNALS_OUT => ID_EX_REG_EX_SIGNALS_OUT,
        --  2) MEM stage
        MEM_SIGNALS_OUT => MEM_SIGNALS_OUT,
        --  3) WB stage
        WB_SIGNALS_OUT => WB_SIGNALS_OUT,
        -- Output data signals
        PC_OUT => PC_OUT, PC_INC_OUT => PC_INC_OUT,
        Rdata1_OUT => Rdata1_OUT, Rdata2_OUT => Rdata2_OUT,
        Rsrc1_OUT => Rsrc1_OUT, Rsrc2_OUT => Rsrc2_OUT,
        Rdst_OUT => Rdst_OUT, IMM_OFFSET_OUT => IMM_OFFSET_OUT,
        OP_CODE_OUT => OP_CODE_OUT
    );

    ALU_SRC1 <= ID_EX_REG_EX_SIGNALS_OUT(0);
    ALU_SRC2 <= ID_EX_REG_EX_SIGNALS_OUT(1);
    JUMP_UNCOND <= ID_EX_REG_EX_SIGNALS_OUT(2);
    BRANCH <= ID_EX_REG_EX_SIGNALS_OUT(3);
    JUMP_COND <= ID_EX_REG_EX_SIGNALS_OUT(5 DOWNTO 4);
    SET_FLAGS <= ID_EX_REG_EX_SIGNALS_OUT(8 DOWNTO 6);
    RESET_FLAGS <= ID_EX_REG_EX_SIGNALS_OUT(11 DOWNTO 9);
    SP_INC_SIG <= ID_EX_REG_EX_SIGNALS_OUT(12);
    MEM_READ <= ID_EX_REG_EX_SIGNALS_OUT(13);
END ARCHITECTURE ID_arch;