LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_CU IS
END ENTITY tb_CU;

ARCHITECTURE behavior OF tb_CU IS

    -- Signal Declarations
    SIGNAL INSTR : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL SP_INC : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ALU_RESULT : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL EX_Opcode : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL PC : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Rsrc1_EN, Rsrc2_EN : STD_LOGIC;
    SIGNAL Store_EN_EPC, EXP_SRC : STD_LOGIC;
    SIGNAL IF_SIGNALS : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL EX_SIGNALS : STD_LOGIC_VECTOR(13 DOWNTO 0);
    SIGNAL MEM_SIGNALS : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL WB_SIGNALS : STD_LOGIC_VECTOR(3 DOWNTO 0);

    COMPONENT CU
        PORT (
            INSTR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            SP_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            ALU_RESULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            EX_Opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- Hazard Detection Unit (ID stage)
            Rsrc1_EN : OUT STD_LOGIC;
            Rsrc2_EN : OUT STD_LOGIC;
            -- Exceptions (ID stage)
            Store_EN_EPC : OUT STD_LOGIC;
            EXP_SRC : OUT STD_LOGIC;
            -- Exceptions and Interrupts (IF stage)
            IF_SIGNALS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            -- Pipeline Control Signals (EX Stage)
            EX_SIGNALS : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
            -- Pipeline Control Signals (MEM Stage)
            MEM_SIGNALS : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            -- Pipeline Control Signals (WB Stage)
            WB_SIGNALS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    -- Zero data vectors
    CONSTANT IF_SIGNALS_ZERO : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    CONSTANT EX_SIGNALS_ZERO : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
    CONSTANT MEM_SIGNALS_ZERO : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    CONSTANT WB_SIGNALS_ZERO : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";

BEGIN
    -- Instantiate the Control Unit (CU)
    uut : CU
    PORT MAP(
        INSTR => INSTR,
        SP_INC => SP_INC,
        ALU_RESULT => ALU_RESULT,
        EX_Opcode => EX_Opcode,
        PC => PC,
        Rsrc1_EN => Rsrc1_EN,
        Rsrc2_EN => Rsrc2_EN,
        Store_EN_EPC => Store_EN_EPC,
        EXP_SRC => EXP_SRC,
        IF_SIGNALS => IF_SIGNALS,
        EX_SIGNALS => EX_SIGNALS,
        MEM_SIGNALS => MEM_SIGNALS,
        WB_SIGNALS => WB_SIGNALS
    );

    -- Stimulus Process to provide test cases
    stim_proc : PROCESS
    BEGIN
        -- Test case 1: Basic instruction (NOP)
        INSTR <= x"00000000"; -- NOP
        SP_INC <= x"0001";
        ALU_RESULT <= x"0000";
        EX_Opcode <= "00000";
        PC <= x"0001";
        WAIT FOR 100 ps;
        ASSERT (Rsrc1_EN = '0') REPORT "Test case 1 failed: Rsrc1_EN not '0' for NOP" SEVERITY ERROR;
        ASSERT (Rsrc2_EN = '0') REPORT "Test case 1 failed: Rsrc2_EN not '0' for NOP" SEVERITY ERROR;
        ASSERT (Store_EN_EPC = '0') REPORT "Test case 1 failed: Store_EN_EPC not '0' for NOP" SEVERITY ERROR;
        ASSERT (EXP_SRC = '1') REPORT "Test case 1 failed: EXP_SRC not '1' for NOP" SEVERITY ERROR;
        ASSERT (IF_SIGNALS = IF_SIGNALS_ZERO) REPORT "Test case 1 failed: IF_SIGNALS not zero for NOP" SEVERITY ERROR;
        ASSERT (EX_SIGNALS = EX_SIGNALS_ZERO) REPORT "Test case 1 failed: EX_SIGNALS not zero for NOP" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS = MEM_SIGNALS_ZERO) REPORT "Test case 1 failed: MEM_SIGNALS not zero for NOP" SEVERITY ERROR;
        ASSERT (WB_SIGNALS = WB_SIGNALS_ZERO) REPORT "Test case 1 failed: WB_SIGNALS not zero for NOP" SEVERITY ERROR;

        -- Test case 2: Test with ADD
        INSTR <= "00000000000000000100000000000000"; -- ADD
        SP_INC <= "0000000000000010";
        ALU_RESULT <= "0000000000000010";
        EX_Opcode <= "00000";
        PC <= "0000000000000011";
        WAIT FOR 100 ps;
        ASSERT (Rsrc1_EN = '1') REPORT "Test case 2 failed: Rsrc1_EN not '1' for ADD" SEVERITY ERROR;
        ASSERT (Rsrc2_EN = '1') REPORT "Test case 2 failed: Rsrc2_EN not '1' for ADD" SEVERITY ERROR;
        ASSERT (EX_SIGNALS(8 DOWNTO 6) = "111") REPORT "Test case 2 failed: EX SET_FLAGS for ADD not correct" SEVERITY ERROR;
        ASSERT MEM_SIGNALS(4) = '1' REPORT "Test case 2 failed: MEM REG_WRITE not '1' for ADD" SEVERITY ERROR;
        ASSERT WB_SIGNALS(3) = '1' REPORT "Test case 2 failed: WB REG_WRITE not '1' for ADD" SEVERITY ERROR;

        -- Test case 3: Invalid Memory Exception for MEM access (LDD)
        INSTR <= "00000000000000000000000000000000"; -- NOP
        SP_INC <= "0000000000000011";
        ALU_RESULT <= x"1000"; -- Greater than 0x0FFF (invalid address)
        EX_Opcode <= "01111"; -- LDD
        PC <= "0000000000001000"; -- PC > 0x0FFF
        WAIT FOR 100 ps;
        ASSERT (Store_EN_EPC = '1') REPORT "Test case 3 failed: Store_EN_EPC not '1' for LDD invalid address" SEVERITY ERROR;
        ASSERT (EXP_SRC = '1') REPORT "Test case 3 failed: EXP_SRC not '1' for LDD invalid address" SEVERITY ERROR;
        ASSERT (IF_SIGNALS(0) = '1') REPORT "Test case 3 failed: IF EXP_SIG not '1' for LDD invalid address" SEVERITY ERROR;
        ASSERT (IF_SIGNALS(1) = '1') REPORT "Test case 3 failed: IF EXP_NUM not '1' for LDD invalid address" SEVERITY ERROR;

        -- Test case 4: Empty stack exception for SP > 0x0FFF (RET)
        INSTR <= "00000000000000001100000000000000"; -- RET
        SP_INC <= x"1000"; -- SP > 0x0FFF
        ALU_RESULT <= "0000000000000000";
        EX_Opcode <= "00000";
        PC <= "0000000000000001";
        WAIT FOR 100 ps;
        ASSERT (Store_EN_EPC = '1') REPORT "Test case 4 failed: Store_EN_EPC not '1' for RET with empty stack" SEVERITY ERROR;
        ASSERT (EXP_SRC = '1') REPORT "Test case 4 failed: EXP_SRC not '1' for RET with empty stack" SEVERITY ERROR;
        ASSERT (IF_SIGNALS(0) = '1') REPORT "Test case 4 failed: IF EXP_SIG not '1' for RET with empty stack" SEVERITY ERROR;
        ASSERT (IF_SIGNALS(1) = '0') REPORT "Test case 4 failed: IF EXP_NUM not '0' for RET with empty stack" SEVERITY ERROR;

        -- Test case 5: Trigger interrupt with INT instruction (INT with index)
        INSTR <= "00000000000000001011100000000010"; -- INT instruction with index 1
        SP_INC <= "0000000000000001";
        ALU_RESULT <= "0000000000000000";
        EX_Opcode <= "00000";
        PC <= "0000000000000011";
        WAIT FOR 100 ps;
        ASSERT (IF_SIGNALS(2) = '1') REPORT "Test case 5 failed: Interrupt signal not '1' for INT instruction" SEVERITY ERROR;
        ASSERT (IF_SIGNALS(3) = '1') REPORT "Test case 5 failed: Interrupt index not '1' for INT instruction" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS(1) = '1') REPORT "Test case 5 failed: MEM MEM_WRITE signal not '1' for INT instruction" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS(3) = '1') REPORT "Test case 5 failed: MEM CALL_OR_INT signal not '1' for INT instruction" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS(6) = '1') REPORT "Test case 5 failed: MEM ADD_FLAGS signal not '1' for INT instruction" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS(8) = '1') REPORT "Test case 5 failed: MEM SP_DEC signal not '1' for INT instruction" SEVERITY ERROR;

        -- Test case 6: Normal operation with JUMP (JMP)
        INSTR <= "00000000000000001010000000000000"; -- JMP
        SP_INC <= "0000000000000001";
        ALU_RESULT <= "0000000000000010";
        EX_Opcode <= "00000";
        PC <= "0000000000000100";
        WAIT FOR 100 ps;
        ASSERT (Rsrc1_EN = '1') REPORT "Test case 6 failed: Rsrc1_EN not '1' for JMP" SEVERITY ERROR;
        ASSERT (EX_SIGNALS(2) = '1') REPORT "Test case 6 failed: EX JUMP_UNCOND for JMP not '1'" SEVERITY ERROR;
        ASSERT (EX_SIGNALS(3) = '1') REPORT "Test case 6 failed: EX BRANCH for JMP not '1'" SEVERITY ERROR;

        -- Test case 7: Test IADD instruction
        INSTR <= "00000000000000000101100000000000"; -- IADD with flags set
        SP_INC <= "0000000000000001";
        ALU_RESULT <= "0000000000000011";
        EX_Opcode <= "00000";
        PC <= "0000000000000011";
        WAIT FOR 100 ps;
        ASSERT (Rsrc1_EN = '1') REPORT "Test case 7 failed: Rsrc1_EN not '1' for IADD" SEVERITY ERROR;
        ASSERT (EX_SIGNALS(1) = '1') REPORT "Test case 7 failed: EX ALU_SRC2 for IADD not '1'" SEVERITY ERROR;
        ASSERT (EX_SIGNALS(8 DOWNTO 6) = "111") REPORT "Test case 7 failed: EX SET_FLAGS for IADD not correct" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS(4) = '1') REPORT "Test case 7 failed: MEM REG_WRITE not '1' for IADD" SEVERITY ERROR;
        ASSERT (WB_SIGNALS(3) = '1') REPORT "Test case 7 failed: WB REG_WRITE not '1' for IADD" SEVERITY ERROR;

        -- Test case 8: Memory Read for LDD instruction
        INSTR <= "00000000000000000111100000000000"; -- LDD
        SP_INC <= "0000000000000001";
        ALU_RESULT <= "0000000000001000"; -- Valid address
        EX_Opcode <= "01111";
        PC <= "0000000000000001";
        WAIT FOR 100 ps;
        ASSERT (EX_SIGNALS(1) = '1') REPORT "Test case 8 failed: EX ALU_SRC2 for LDD not '1'" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS(0) = '1') REPORT "Test case 8 failed: MEM signal for LDD not '1'" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS(4) = '1') REPORT "Test case 8 failed: MEM REG_WRITE not '1' for LDD" SEVERITY ERROR;
        ASSERT (WB_SIGNALS(2) = '0') REPORT "Test case 8 failed: WB MEM_TO_REG for LDD not '1'" SEVERITY ERROR;
        ASSERT (WB_SIGNALS(3) = '1') REPORT "Test case 8 failed: WB REG_WRITE not '1' for LDD" SEVERITY ERROR;

        -- Test case 9: Invalid Opcode (should not trigger any control signals)
        INSTR <= "00000000000000001111100000000000"; -- Invalid Opcode
        SP_INC <= "0000000000000001";
        ALU_RESULT <= "0000000000000000";
        EX_Opcode <= "00000";
        PC <= "0000000000000001";
        WAIT FOR 100 ps;
        ASSERT (Rsrc1_EN = '0') REPORT "Test case 9 failed: Rsrc1_EN should be '0' for invalid opcode" SEVERITY ERROR;
        ASSERT (Rsrc2_EN = '0') REPORT "Test case 9 failed: Rsrc2_EN should be '0' for invalid opcode" SEVERITY ERROR;
        ASSERT (EX_SIGNALS = EX_SIGNALS_ZERO) REPORT "Test case 9 failed: EX signals should be zero for invalid opcode" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS = MEM_SIGNALS_ZERO) REPORT "Test case 9 failed: MEM signals should be zero for invalid opcode" SEVERITY ERROR;

        -- Test case 12: Test for RTI with update flags
        INSTR <= "00000000000000001100000000000000"; -- RTI
        SP_INC <= "0000000000000011";
        ALU_RESULT <= "0000000000000001";
        EX_Opcode <= "00000";
        PC <= "0000000000000100";
        WAIT FOR 100 ps;
        ASSERT (EX_SIGNALS(12) = '1') REPORT "Test case 12 failed: EX SP_INC_SIG for RTI not '1'" SEVERITY ERROR;
        ASSERT (EX_SIGNALS(13) = '1') REPORT "Test case 12 failed: EX MEM_READ for RTI not '1'" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS(5) = '1') REPORT "Test case 12 failed: MEM UPDATE_FLAGS for RTI not '1'" SEVERITY ERROR;
        ASSERT (MEM_SIGNALS(9) = '1') REPORT "Test case 12 failed: MEM IS_RET_RTI for RTI not '1'" SEVERITY ERROR;

        -- Test case 13: Test for JUMP_COND (JZ) in EX stage
        INSTR <= x"00000000"; -- NOP
        SP_INC <= "0000000000000001";
        ALU_RESULT <= "0000000000000011";
        EX_Opcode <= "10001"; -- JZ
        PC <= "0000000000000010";
        WAIT FOR 100 ps;
        ASSERT (EX_SIGNALS(9) = '1') REPORT "Test case 13 failed: EX RESET_FLAGS for JZ not '1'" SEVERITY ERROR;

        -- End of Testbench
        WAIT;
    END PROCESS stim_proc;

END ARCHITECTURE behavior;