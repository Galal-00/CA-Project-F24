LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY PipePrcsr IS
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        -- Data i/p
        IN_DATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- Data o/p
        OUT_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY PipePrcsr;

ARCHITECTURE PipePrcsr_arch OF PipePrcsr IS

    COMPONENT IF_Stage IS
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            -- EX jump address
            jump_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- RET_RTI address MEM
            RET_RTI_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- Control Inputs
            -- EXP_SIG 0, EXP_NUM 1, INT_SIG 2, INT_NUM 3
            IF_SIGNALS_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            -- Mem_Control_Sigs(7) : Is_RET_RTI EX mem reg
            is_RET_RTI : IN STD_LOGIC;
            -- PCsrc Signal from execute stage
            PCsrc : IN STD_LOGIC;
            -- HazardUnit Signals
            IF_ID_write : IN STD_LOGIC;
            IF_ID_flush : IN STD_LOGIC;
            PC_stall : IN STD_LOGIC;

            -- OUTPUTS
            -- PC output
            PC_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_out_inc : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ID IS
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
            -- i/p MEM Signals
            IS_RET_RTI : IN STD_LOGIC;
            -- i/p WB Signals
            RegWrite : IN STD_LOGIC;
            Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            WR_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

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
            -- o/p hazard (including flush) signals
            --  1) IF Stage
            IF_ID_WRITE : OUT STD_LOGIC := '1';
            PC_STALL : OUT STD_LOGIC := '0';
            IF_ID_FLUSH : OUT STD_LOGIC := '0';
            --  2) EX Stage
            EX_FLUSH : OUT STD_LOGIC := '0';
            -- o/p data signals
            -- 1) EX stage
            PC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
            PC_INC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
            Rdata1_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
            Rdata2_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
            Rsrc1_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
            Rsrc2_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
            Rdst_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
            IMM_OFFSET_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
            OP_CODE_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
            --  2) EPC
            EXP_PC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
        );
    END COMPONENT;

    COMPONENT EX IS
        PORT (
            Clk : IN STD_LOGIC;
            Rst : IN STD_LOGIC;

            -- Input control signals

            -- Mem_Control_Sigs(0) : MemRead
            -- Mem_Control_Sigs(1) : MemWrite
            -- Mem_Control_Sigs(2) : DM_Addr
            -- Mem_Control_Sigs(3) : CallSig
            -- Mem_Control_Sigs(4) : Add_Flags
            -- Mem_Control_Sigs(5) : SP_DEC
            -- Mem_Control_Sigs(6) : SP_EN
            -- Mem_Control_Sigs(7) : Is_RET_RTI
            -- Mem_Control_Sigs(8) : Update_Flags
            -- Mem_Control_Sigs(9) : RegWrite for forwarding

            Mem_Control_Sigs : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            -- Wb_Control_Sigs(0) : MemToReg
            -- Wb_Control_Sigs(1) : RegWrite
            -- Wb_Control_Sigs(2) : OutSig
            -- Wb_Control_Sigs(3) : InSig
            Wb_Control_Sigs : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

            -- Ex control sigs
            Reset_Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Jump_Cond : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            Jump_Uncond : IN STD_LOGIC;
            SP_INC : IN STD_LOGIC;
            Set_Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ALU_Src1 : IN STD_LOGIC;
            ALU_Src2 : IN STD_LOGIC;
            Ex_Flush : IN STD_LOGIC;
            ID_EX_MEM_READ_IN : IN STD_LOGIC;
            Update_Flags : IN STD_LOGIC; -- recieved from mem stage
            Branch : IN STD_LOGIC;
            SP_EN : IN STD_LOGIC; -- comes form the mem stage Mem_Control_Sigs(6)

            -- Input control signals from next stages
            RegWrite_Ex_Mem : IN STD_LOGIC;
            RegWrite_Mem_Wb : IN STD_LOGIC;

            -- Input data 
            ReadData1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            ReadData2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IMM : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            PC_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_inc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

            -- input data forwarded from the next stages registers
            Fwd_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Fwd_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst_Ex_Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdst_Mem_Wb : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            OpCode_Mem : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- for Forwarding unit to know the instruction was IN
            OpCode_Wb : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- for Forwarding unit to know the instruction was IN

            -- input data from mem stage
            Flags_Popped : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            SP_Write_Data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- in Port from outside will connect to EX/MEM reg
            IN_Port : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

            -- Output data
            Jump_Addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            PCSrc : OUT STD_LOGIC;
            PC_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- Output data from the Ex/Mem reg
            ALU_Result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_inc_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            ReadData1_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            OpCode_Out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            IN_Port_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            SP_inc_data_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Flags_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- Output control signals
            ID_EX_MEM_READ_OUT : OUT STD_LOGIC;
            Mem_Control_Sigs_Out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            Wb_Control_Sigs_Out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT MEM IS
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
            FWD_ALU_EX_MEM : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            FWD_IN_EX_MEM : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- 3) WB Stage
            ALU_RESULT_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            DM_DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            IN_DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            OP_CODE_WB_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT WB IS
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            -- Control signals i/p
            WB_SIGNALS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            -- Data i/p
            ALU_RESULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            DM_DATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            IN_DATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            OP_CODE_IN : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            -- Control signals o/p
            REG_WRITE : OUT STD_LOGIC;
            -- Data o/p
            -- 1) ID:
            Rdst_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            REG_WB_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- 2) EX:
            FWD_ALU_MEM_WB : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            FWD_IN_MEM_WB : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            OP_CODE_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            -- 3) Others:
            OUT_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    -- IF_Stage Signals
    -- OUTPUTS
    -- PC output
    SIGNAL FROM_IF_PC_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_IF_PC_OUT_INC : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_IF_INSTRUCTION : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- ID Signals
    -- o/p control signals:
    --  1) IF stage
    SIGNAL FROM_ID_IF_SIGNALS_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    --  2) EX stage
    SIGNAL FROM_ID_ALU_SRC1 : STD_LOGIC := '0';
    SIGNAL FROM_ID_ALU_SRC2 : STD_LOGIC := '0';
    SIGNAL FROM_ID_JUMP_UNCOND : STD_LOGIC := '0';
    SIGNAL FROM_ID_BRANCH : STD_LOGIC := '0';
    SIGNAL FROM_ID_JUMP_COND : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_ID_SET_FLAGS : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_ID_RESET_FLAGS : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_ID_SP_INC_SIG : STD_LOGIC := '0';
    SIGNAL FROM_ID_MEM_READ : STD_LOGIC := '0';
    --  3) MEM stage
    SIGNAL FROM_ID_MEM_SIGNALS_OUT : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    --  4) WB stage
    SIGNAL FROM_ID_WB_SIGNALS_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    -- o/p hazard (including flush) signals
    --  1) IF Stage
    SIGNAL FROM_ID_IF_ID_WRITE : STD_LOGIC := '1';
    SIGNAL FROM_ID_PC_STALL : STD_LOGIC := '0';
    SIGNAL FROM_ID_IF_ID_FLUSH : STD_LOGIC := '0';
    --  2) EX Stage
    SIGNAL FROM_ID_EX_FLUSH : STD_LOGIC := '0';
    -- o/p data signals
    --  1) EX stage
    SIGNAL FROM_ID_PC_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_ID_PC_INC_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_ID_Rdata1_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_ID_Rdata2_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_ID_Rsrc1_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_ID_Rsrc2_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_ID_Rdst_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_ID_IMM_OFFSET_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_ID_OP_CODE_OUT : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    --  2) EPC
    SIGNAL FROM_ID_EXP_PC : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

    -- EX Signals
    -- Output data
    SIGNAL FROM_EX_JUMP_ADDR : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_EX_PCSrc : STD_LOGIC;
    SIGNAL FROM_EX_PC_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    -- Output data from the Ex/Mem reg
    SIGNAL FROM_EX_ALU_RESULT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_EX_PC_INC_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_EX_ReadData1_Out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_EX_Rdst_Out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FROM_EX_OpCode_Out : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL FROM_EX_IN_Port_Out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_EX_SP_inc_data_Out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_EX_Flags_Out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- Output control signals
    SIGNAL FROM_EX_ID_EX_MEM_READ_OUT : STD_LOGIC;
    SIGNAL FROM_EX_Mem_Control_Sigs_Out : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL FROM_EX_Wb_Control_Sigs_Out : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- MEM Signals
    SIGNAL FROM_MEM_IS_RET_RTI : STD_LOGIC := '0';
    SIGNAL FROM_MEM_UPDATE_FLAGS : STD_LOGIC := '0';
    SIGNAL FROM_MEM_EX_MEM_REG_WRITE : STD_LOGIC := '0';
    SIGNAL FROM_MEM_SP_EN : STD_LOGIC := '0';
    SIGNAL FROM_MEM_WB_SIGNALS_OUT : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FROM_MEM_RET_RTI_ADDRESS : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_MEM_FLAGS_POPPED : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FROM_MEM_OP_CODE_EX_OUT : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL FROM_MEM_Rdst_EX_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FROM_MEM_SP_WRITE_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0FFF";
    SIGNAL FROM_MEM_FWD_ALU_EX_MEM : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_MEM_FWD_IN_EX_MEM : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_MEM_ALU_RESULT_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_MEM_DM_DATA_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_MEM_Rdst_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FROM_MEM_IN_DATA_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_MEM_OP_CODE_WB_OUT : STD_LOGIC_VECTOR(4 DOWNTO 0);

    -- WB Signals
    SIGNAL FROM_WB_REG_WRITE : STD_LOGIC;
    SIGNAL FROM_WB_RDST_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FROM_WB_REG_WB_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_WB_FWD_ALU_EX_MEM : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_WB_FWD_IN_EX_MEM : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL FROM_WB_OP_CODE_OUT : STD_LOGIC_VECTOR(4 DOWNTO 0);
BEGIN

    -- Component instantiation
    IF_Stage_inst : IF_Stage PORT MAP(
        clk => CLK,
        reset => RST,
        --EX jump address
        jump_addr => FROM_EX_JUMP_ADDR,
        --RET_RTI address MEM
        RET_RTI_addr => FROM_MEM_RET_RTI_ADDRESS,
        -- Control Inputs
        -- EXP_SIG 0, EXP_NUM 1, INT_SIG 2, INT_NUM 3
        IF_SIGNALS_IN => FROM_ID_IF_SIGNALS_OUT,
        -- Mem_Control_Sigs(7) : Is_RET_RTI EX mem reg
        is_RET_RTI => FROM_MEM_IS_RET_RTI,
        -- PCsrc Signal from execute stage
        PCsrc => FROM_EX_PCSrc,
        --HazardUnit Signals
        IF_ID_write => FROM_ID_IF_ID_WRITE,
        IF_ID_flush => FROM_ID_IF_ID_FLUSH,
        PC_stall => FROM_ID_PC_STALL,

        --OUTPUTS
        -- PC output
        PC_out => FROM_IF_PC_OUT,
        PC_out_inc => FROM_IF_PC_OUT_INC,
        Instruction => FROM_IF_INSTRUCTION
    );

    ID_inst : ID PORT MAP(
        CLK => CLK,
        RST => RST,

        -- i/p IF Signals
        PC => FROM_IF_PC_OUT,
        PC_INC => FROM_IF_PC_OUT_INC,
        INSTR => FROM_IF_INSTRUCTION,
        -- i/p EX Signals
        FLUSH => FROM_EX_PCSrc, -- same as flush
        ID_EX_MEM_READ => FROM_EX_ID_EX_MEM_READ_OUT,
        ID_EX_Rdst => FROM_EX_Rdst_Out,
        ALU_RESULT => FROM_EX_ALU_RESULT,
        SP_INC => FROM_EX_SP_inc_data_Out,
        PC_EX => FROM_EX_PC_OUT,
        EX_OpCode => FROM_EX_OpCode_Out,
        -- i/p MEM Signals
        IS_RET_RTI => FROM_MEM_IS_RET_RTI,
        -- i/p WB Signals
        RegWrite => FROM_WB_REG_WRITE,
        Rdst => FROM_WB_RDST_OUT,
        WR_data => FROM_WB_REG_WB_DATA,

        -- o/p control signals:
        --  1) IF stage
        IF_SIGNALS_OUT => FROM_ID_IF_SIGNALS_OUT,
        --  2) EX stage
        ALU_SRC1 => FROM_ID_ALU_SRC1,
        ALU_SRC2 => FROM_ID_ALU_SRC2,
        JUMP_UNCOND => FROM_ID_JUMP_UNCOND,
        BRANCH => FROM_ID_BRANCH,
        JUMP_COND => FROM_ID_JUMP_COND,
        SET_FLAGS => FROM_ID_SET_FLAGS,
        RESET_FLAGS => FROM_ID_RESET_FLAGS,
        SP_INC_SIG => FROM_ID_SP_INC_SIG,
        MEM_READ => FROM_ID_MEM_READ,
        --  3) MEM stage
        MEM_SIGNALS_OUT => FROM_ID_MEM_SIGNALS_OUT,
        --  4) WB stage
        WB_SIGNALS_OUT => FROM_ID_WB_SIGNALS_OUT,
        -- o/p hazard (including flush) signals
        --  1) IF Stage
        IF_ID_WRITE => FROM_ID_IF_ID_WRITE,
        PC_STALL => FROM_ID_PC_STALL,
        IF_ID_FLUSH => FROM_ID_IF_ID_FLUSH,
        -- 2) EX Stage
        EX_FLUSH => FROM_ID_EX_FLUSH,
        -- o/p data signals
        -- 1) EX stage
        PC_OUT => FROM_ID_PC_OUT,
        PC_INC_OUT => FROM_ID_PC_INC_OUT,
        Rdata1_OUT => FROM_ID_Rdata1_OUT,
        Rdata2_OUT => FROM_ID_Rdata2_OUT,
        Rsrc1_OUT => FROM_ID_Rsrc1_OUT,
        Rsrc2_OUT => FROM_ID_Rsrc2_OUT,
        Rdst_OUT => FROM_ID_Rdst_OUT,
        IMM_OFFSET_OUT => FROM_ID_IMM_OFFSET_OUT,
        OP_CODE_OUT => FROM_ID_OP_CODE_OUT,
        --  2) EPC
        EXP_PC => FROM_ID_EXP_PC
    );

    EX_inst : EX PORT MAP(
        Clk => CLK,
        Rst => RST,

        -- Input control signals
        -- 1) MEM
        Mem_Control_Sigs => FROM_ID_MEM_SIGNALS_OUT,
        -- 2) WB
        Wb_Control_Sigs => FROM_ID_WB_SIGNALS_OUT,
        -- 3) EX
        Reset_Flags => FROM_ID_RESET_FLAGS,
        Jump_Cond => FROM_ID_JUMP_COND,
        Jump_Uncond => FROM_ID_JUMP_UNCOND,
        SP_INC => FROM_ID_SP_INC_SIG,
        Set_Flags => FROM_ID_SET_FLAGS,
        ALU_Src1 => FROM_ID_ALU_SRC1,
        ALU_Src2 => FROM_ID_ALU_SRC2,
        Ex_Flush => FROM_ID_EX_FLUSH,
        ID_EX_MEM_READ_IN => FROM_ID_MEM_READ,
        Update_Flags => FROM_MEM_UPDATE_FLAGS, -- recieved from mem stage
        Branch => FROM_ID_BRANCH,
        SP_EN => FROM_MEM_SP_EN, -- comes form the mem stage Mem_Control_Sigs(6)

        -- Input control signals from next stages
        RegWrite_Ex_Mem => FROM_MEM_EX_MEM_REG_WRITE,
        RegWrite_Mem_Wb => FROM_WB_REG_WRITE,

        -- Input data 
        ReadData1 => FROM_ID_Rdata1_OUT,
        ReadData2 => FROM_ID_Rdata2_OUT,
        IMM => FROM_ID_IMM_OFFSET_OUT,
        Rdst => FROM_ID_Rdst_OUT,
        Rsrc1 => FROM_ID_Rsrc1_OUT,
        Rsrc2 => FROM_ID_Rsrc2_OUT,
        OpCode => FROM_ID_OP_CODE_OUT,
        PC_IN => FROM_ID_PC_OUT,
        PC_inc => FROM_ID_PC_INC_OUT,

        -- input data forwarded from the next stages registers
        Fwd_Ex_Mem => FROM_MEM_FWD_ALU_EX_MEM,
        Fwd_Mem_WB => FROM_WB_FWD_ALU_EX_MEM,
        IN_Ex_Mem => FROM_MEM_FWD_IN_EX_MEM,
        IN_Mem_WB => FROM_WB_FWD_IN_EX_MEM,
        Rdst_Ex_Mem => FROM_MEM_Rdst_EX_OUT,
        Rdst_Mem_Wb => FROM_WB_RDST_OUT,
        OpCode_Mem => FROM_MEM_OP_CODE_EX_OUT, -- for Forwarding unit to know the instruction was IN
        OpCode_Wb => FROM_WB_OP_CODE_OUT, -- for Forwarding unit to know the instruction was IN

        -- input data from mem stage
        Flags_Popped => FROM_MEM_FLAGS_POPPED,
        SP_Write_Data => FROM_MEM_SP_WRITE_DATA,
        -- in Port from outside will connect to EX/MEM reg
        IN_Port => IN_DATA,

        -- Output data
        Jump_Addr => FROM_EX_JUMP_ADDR,
        PCSrc => FROM_EX_PCSrc,
        PC_OUT => FROM_EX_PC_OUT,
        -- Output data from the Ex/Mem reg
        ALU_Result => FROM_EX_ALU_RESULT,
        PC_inc_Out => FROM_EX_PC_INC_OUT,
        ReadData1_Out => FROM_EX_ReadData1_Out,
        Rdst_Out => FROM_EX_Rdst_Out,
        OpCode_Out => FROM_EX_OpCode_Out,
        IN_Port_Out => FROM_EX_IN_Port_Out,
        SP_inc_data_Out => FROM_EX_SP_inc_data_Out,
        Flags_Out => FROM_EX_Flags_Out,

        -- Output control signals
        ID_EX_MEM_READ_OUT => FROM_EX_ID_EX_MEM_READ_OUT,
        Mem_Control_Sigs_Out => FROM_EX_Mem_Control_Sigs_Out,
        Wb_Control_Sigs_Out => FROM_EX_Wb_Control_Sigs_Out
    );

    MEM_inst : MEM PORT MAP(
        CLK => CLK,
        RST => RST,
        -- Control Signals i/p. From EX Stage
        MEM_SIGNALS => FROM_EX_Mem_Control_Sigs_Out,
        WB_SIGNALS_IN => FROM_EX_Wb_Control_Sigs_Out,
        -- Data i/p. From EX Stage
        ALU_RESULT_IN => FROM_EX_ALU_RESULT,
        SP_INC => FROM_EX_SP_inc_data_Out,
        Rdata1 => FROM_EX_ReadData1_Out,
        FLAGS => FROM_EX_Flags_Out,
        PC_INC => FROM_EX_PC_INC_OUT,
        Rdst_IN => FROM_EX_Rdst_Out,
        IN_DATA_IN => FROM_EX_IN_Port_Out,
        OP_CODE_IN => FROM_EX_OpCode_Out,
        -- Control Signals o/p
        -- 1) IF, ID Stage
        IS_RET_RTI => FROM_MEM_IS_RET_RTI,
        -- 2) EX Stage
        UPDATE_FLAGS => FROM_MEM_UPDATE_FLAGS,
        EX_MEM_REG_WRITE => FROM_MEM_EX_MEM_REG_WRITE,
        SP_EN => FROM_MEM_SP_EN,
        -- 3) WB Stage
        WB_SIGNALS_OUT => FROM_MEM_WB_SIGNALS_OUT,
        -- Data o/p
        -- 1) IF Stage
        RET_RTI_ADDRESS => FROM_MEM_RET_RTI_ADDRESS,
        -- 2) EX Stage
        FLAGS_POPPED => FROM_MEM_FLAGS_POPPED,
        OP_CODE_EX_OUT => FROM_MEM_OP_CODE_EX_OUT,
        Rdst_EX_OUT => FROM_MEM_Rdst_EX_OUT,
        SP_WRITE_DATA => FROM_MEM_SP_WRITE_DATA,
        FWD_ALU_EX_MEM => FROM_MEM_FWD_ALU_EX_MEM,
        FWD_IN_EX_MEM => FROM_MEM_FWD_IN_EX_MEM,
        -- 3) WB Stage
        ALU_RESULT_OUT => FROM_MEM_ALU_RESULT_OUT,
        DM_DATA_OUT => FROM_MEM_DM_DATA_OUT,
        Rdst_OUT => FROM_MEM_Rdst_OUT,
        IN_DATA_OUT => FROM_MEM_IN_DATA_OUT,
        OP_CODE_WB_OUT => FROM_MEM_OP_CODE_WB_OUT
    );

    WB_inst : WB PORT MAP(
        CLK => CLK,
        RST => RST,
        -- Control signals i/p
        WB_SIGNALS => FROM_MEM_WB_SIGNALS_OUT,
        -- Data i/p
        ALU_RESULT => FROM_MEM_ALU_RESULT_OUT,
        DM_DATA => FROM_MEM_DM_DATA_OUT,
        Rdst_IN => FROM_MEM_Rdst_OUT,
        IN_DATA => FROM_MEM_IN_DATA_OUT,
        OP_CODE_IN => FROM_MEM_OP_CODE_WB_OUT,
        -- Control signals o/p
        REG_WRITE => FROM_WB_REG_WRITE,
        -- Data o/p
        -- 1) ID:
        Rdst_OUT => FROM_WB_RDST_OUT,
        REG_WB_DATA => FROM_WB_REG_WB_DATA,
        -- 2) EX:
        FWD_ALU_MEM_WB => FROM_WB_FWD_ALU_EX_MEM,
        FWD_IN_MEM_WB => FROM_WB_FWD_IN_EX_MEM,
        OP_CODE_OUT => FROM_WB_OP_CODE_OUT,
        -- 3) Others:
        OUT_DATA => OUT_DATA
    );

END ARCHITECTURE;