LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY IF_Stage IS
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
END ENTITY;

ARCHITECTURE IF_ARCH OF IF_Stage IS
    COMPONENT Instruction_Memory IS
        PORT (
            address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            reset : IN STD_LOGIC;
            exp_sig : IN STD_LOGIC;
            exp_num : IN STD_LOGIC;
            int_sig : IN STD_LOGIC;
            int_index : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT PC IS
        PORT (
            clk : IN STD_LOGIC;
            pc_mux_out : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- Stall signal to stop the PC from incrementing
            stall : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT Next_PC_Unit IS
        PORT (
            reset : IN STD_LOGIC;
            exp_sig : IN STD_LOGIC;
            int_sig : IN STD_LOGIC;
            is_RET_RTI : IN STD_LOGIC;
            PCsrc : IN STD_LOGIC;
            Next_PC : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT PC_ADD IS
        PORT (
            PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_inc_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            PC_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT FCU IS
        PORT (
            OPcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            PC_inc_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT PC_Mux IS
        PORT (
            PC_inc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            jump_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            RET_RTI_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IM_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Next_PC_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            PC_mux_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT IF_ID_reg IS
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_inc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            IF_ID_write : IN STD_LOGIC;
            IF_ID_flush : IN STD_LOGIC;
            PC_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_inc_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Instruction_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL PC_Mux_out_sig : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL PC_out_pcreg : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL PC_out_ADD : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Instruction_out_sig : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Next_PC_sig : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL PC_inc_sel_sig : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
    Instruction_Memory_inst : Instruction_Memory
    PORT MAP(
        address => PC_out_pcreg,
        data_out => Instruction_out_sig,
        reset => reset,
        exp_sig => IF_SIGNALS_IN(0),
        exp_num => IF_SIGNALS_IN(1),
        int_sig => IF_SIGNALS_IN(2),
        int_index => IF_SIGNALS_IN(3)
    );

    PC_inst : PC
    PORT MAP(
        clk => clk,
        stall => PC_stall,
        pc_mux_out => PC_Mux_out_sig,
        pc_out => PC_out_pcreg
    );

    Next_PC_Unit_inst : Next_PC_Unit
    PORT MAP(
        reset => reset,
        exp_sig => IF_SIGNALS_IN(0),
        int_sig => IF_SIGNALS_IN(2),
        is_RET_RTI => is_RET_RTI,
        PCsrc => PCsrc,
        Next_PC => Next_PC_sig
    );

    PC_ADD_inst : PC_ADD
    PORT MAP(
        PC => PC_out_pcreg,
        PC_inc_sel => PC_inc_sel_sig,
        PC_out => PC_out_ADD
    );

    FCU_inst : FCU
    PORT MAP(
        OPcode => Instruction_out_sig(15 DOWNTO 11),
        PC_inc_sel => PC_inc_sel_sig
    );

    PC_Mux_inst : PC_Mux
    PORT MAP
    (
        PC_inc => PC_out_ADD,
        jump_addr => jump_addr,
        RET_RTI_addr => RET_RTI_addr,
        IM_addr => Instruction_out_sig(15 DOWNTO 0),
        Next_PC_sel => Next_PC_sig,
        PC_mux_out => PC_Mux_out_sig
    );

    IF_ID_Reg_inst : IF_ID_reg
    PORT MAP(
        clk => clk,
        reset => reset,
        PC => PC_out_pcreg,
        PC_inc => PC_out_ADD,
        Instruction => Instruction_out_sig,
        IF_ID_write => IF_ID_write,
        IF_ID_flush => IF_ID_flush,
        PC_out => PC_out,
        PC_inc_out => PC_out_inc,
        Instruction_out => Instruction
    );

END ARCHITECTURE;