LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- CU input data signals:
-- INSTR [31:0] : Instruction
-- SP_INC : Incremented SP value. Used for exp detection (invalid MEM (DM) address)
-- ALU_RESULT : Result of ALU Operation. Used for exp detection (invalid MEM (DM) address)
-- EX_OpCode [15:11] : Used to decide whether to check for exceptions or not (maybe)
-- PC : Used for exp detection (invalid MEM (IM) address)

-- CU output control signals:
-- Rsrc1_EN, Rsrc2_EN: State if Rsrc1 / Rsrc2 is used in this instruction

-- Store_EN_EPC: Store Enable for EPC
-- EXP_SRC: EPC source. PC of decode or PC of execute
-- EXP_SIG: Exception triggered signal
-- EXP_NUM: Exception number. 0 = Empty Stack, 1 = Invalid Memory address

-- INT_SIG: Interrupt triggered signal
-- INT_INDEX: Interrupt index. 0 = INT 0, 1 = INT 1

-- Pipeline Control Signals:
-- 1) EX Stage:
--  a) ALU_SRC1, ALU_SRC2
--  b) JUMP_UNCOND, BRANCH, JUMP_COND[1:0], SET_FLAGS[2:0], RESET_FLAGS[2:0]
--  c) SP_INC_SIG
--  d) MEM_READ
-- 2) MEM Stage:
--  a) MEM_READ, MEM_WRITE, DM_ADDR, CALL_SIG 
--  b) REG_WRITE
--  c) UPDATE_FLAGS, ADD_FLAGS
--  d) SP_EN, SP_DEC
--  e) IS_RET_RTI
-- 3) WB Stage:
--  a) OUT_SIG, IN_SIG
--  b) MEM_TO_REG
--  c) REG_WRITE

ENTITY CU IS
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
END ENTITY CU;

ARCHITECTURE CU_arch OF CU IS

    SIGNAL OP_CODE : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');

    -- EXP checks
    SIGNAL EX_IS_LDD_OR_STD : STD_LOGIC := '0';
    SIGNAL USES_IMM_OR_OFFSET : STD_LOGIC := '0';
    SIGNAL INVALID_MEM_EXP : STD_LOGIC := '0';
    SIGNAL EMPTY_STACK_EXP : STD_LOGIC := '0';

BEGIN

    OP_CODE <= INSTR(15 DOWNTO 11);

    -- Hazard Detection Unit signals:
    -- 1 when NOT, INC, OUT, MOV, ADD, SUB, AND, IADD, PUSH, LDD, STD, JZ, JN, JC, JMP, CALL
    Rsrc1_EN <= '1' WHEN ((OP_CODE >= "00011" AND OP_CODE <= "00101")
        OR (OP_CODE >= "00111" AND OP_CODE <= "01100")
        OR (OP_CODE >= "01111" AND OP_CODE <= "10101")) ELSE
        '0';
    -- 1 when ADD, SUB, AND, STD
    Rsrc2_EN <= '1' WHEN ((OP_CODE >= "01000" AND OP_CODE <= "01010")
        OR OP_CODE = "10000") ELSE
        '0';

    -- Exceptions:
    -- Invalid MEM address (IM) can occur when PC > 0x0FFF. Cases:
    -- 1- PC += 1 > 0x0FFF
    -- 2- Jump or Call  w/ R[Rsrc1] > 0x0FFF
    -- 3- RET / RTI w/ DM[SP] > 0x0FFF
    -- 4- INT w/ IM[index + 3] > 0x0FFF ?????
    -- 5- PC = 0x0FFF but instruction takes IMM / OFFSET. IADD, LDM, LDD, STD
    -- Invalid MEM address (DM) can occur when DM read address > 0x0FFF, i.e:
    -- MEM access (LDD / STD) w/ address from ALU > 

    EX_IS_LDD_OR_STD <= '1' WHEN (EX_OpCode = "01111" OR EX_OpCode = "10000") ELSE
        '0';
    USES_IMM_OR_OFFSET <= '1' WHEN (OP_CODE = "01011"
        OR (OP_CODE >= "01110" AND OP_CODE <= "10000")) ELSE
        '0';
    INVALID_MEM_EXP <= '1' WHEN (PC > x"0FFF"
        OR (EX_IS_LDD_OR_STD = '1' AND ALU_RESULT > x"0FFF")
        OR (USES_IMM_OR_OFFSET = '1' AND PC = x"0FFF")) ELSE
        '0';

    -- Empty stack can occur when SP > 0x0FFF. Cases:
    -- 1- POP. SP += 1 > 0x0FFF
    -- 2- RET / RTI ??? SP += 1 > 0x0FFF
    EMPTY_STACK_EXP <= '1' WHEN (SP_INC > x"0FFF") ELSE
        '0';

    -- Store offending PC in EPC
    Store_EN_EPC <= '1' WHEN (INVALID_MEM_EXP = '1' OR EMPTY_STACK_EXP = '1') ELSE
        '0'; -- Store_EN_EPC. 1 when invalid MEM or empty stack exp.
    EXP_SRC <= '0' WHEN PC > x"0FFF" ELSE
        '1'; -- EXP_SRC. 1 when exp from PC_EX and default. 0 when exp from PC_D

    IF_SIGNALS(0) <= '1' WHEN (INVALID_MEM_EXP = '1' OR EMPTY_STACK_EXP = '1') ELSE
    '0'; -- EXP_SIG
    IF_SIGNALS(1) <= '1' WHEN INVALID_MEM_EXP = '1' ELSE
    '0'; -- EXP_NUM. 1 when invalid memory exp, 0 when empty stack exp

    -- Interrupts:
    -- Opcode = "10111".
    -- INSTR(1) = index.
    IF_SIGNALS(2) <= '1' WHEN OP_CODE = "10111" ELSE
    '0'; -- INT_SIG. 1 when INT
    IF_SIGNALS(3) <= INSTR(1); -- INT_INDEX.

    -- Pipeline Control Signals (EX Stage)
    -- ALU
    EX_SIGNALS(0) <= '1' WHEN OP_CODE = "10000" ELSE
    '0'; -- ALU_SRC1. 1 (use imm / offset) when STD.
    EX_SIGNALS(1) <= '1' WHEN (OP_CODE = "01011" OR OP_CODE = "01110" OR OP_CODE = "01111") ELSE
    '0'; -- ALU_SRC2. 1 (use imm / offset) when IADD, LDM, LDD
    -- Branch
    EX_SIGNALS(2) <= '1' WHEN (OP_CODE = "10100" OR OP_CODE = "10101") ELSE
    '0'; -- JUMP_UNCOND. 1 when JMP, CALL
    EX_SIGNALS(3) <= '1' WHEN (OP_CODE >= "10001" AND OP_CODE <= "10101") ELSE
    '0'; -- BRANCH. 1 when unconditional or conditional jump
    EX_SIGNALS(5 DOWNTO 4) <= "00" WHEN (OP_CODE = "10001") ELSE
    "01" WHEN (OP_CODE = "10010") ELSE
    "10" WHEN (OP_CODE = "10011") ELSE
    "00"; -- JUMP_COND. "00" when JZ, "01" when JN, "10" when JC, "00" else
    EX_SIGNALS(6) <= '1' WHEN (OP_CODE = "00011" OR OP_CODE = "00100" OR
    (OP_CODE >= "01000" AND OP_CODE <= "01011")) ELSE
    '0'; -- SET_FLAGS(0). 1 when NOT, INC, ADD, SUB, AND, IADD else 0
    EX_SIGNALS(7) <= '1' WHEN (OP_CODE = "00011" OR OP_CODE = "00100" OR
    (OP_CODE >= "01000" AND OP_CODE <= "01011")) ELSE
    '0'; -- SET_FLAGS(1). 1 when NOT, INC, ADD, SUB, AND, IADD else 0
    EX_SIGNALS(8) <= '1' WHEN (OP_CODE = "00010" OR OP_CODE = "00100" OR OP_CODE = "01000" OR OP_CODE = "01001"
    OR OP_CODE = "01011") ELSE
    '0'; -- SET_FLAGS(2). 1 when SETC, INC, ADD, SUB, IADD else 0
    EX_SIGNALS(9) <= '1' WHEN (EX_Opcode = "10001") ELSE
    '0'; -- RESET_FLAGS(0). 1 when JZ in EX stage
    EX_SIGNALS(10) <= '1' WHEN (EX_Opcode = "10010") ELSE
    '0'; -- RESET_FLAGS(1). 1 when JN in EX stage
    EX_SIGNALS(11) <= '1' WHEN (EX_Opcode = "10011") ELSE
    '0'; -- RESET_FLAGS(2). 1 when JC in EX stage
    -- Stack Pointer Increment
    EX_SIGNALS(12) <= '1' WHEN (OP_CODE = "01101" OR OP_CODE = "10110" OR OP_CODE = "11000") ELSE
    '0'; -- SP_INC_SIG. 1 WHEN POP, RET, RTI
    -- Memory Read
    EX_SIGNALS(13) <= '1' WHEN (OP_CODE = "01101" OR OP_CODE = "01111"
    OR OP_CODE = "10110" OR OP_CODE = "11000") ELSE
    '0'; -- MEM_READ. 1 WHEN POP, LDD, RET, RTI

    -- Pipeline Control Signals (MEM Stage)
    -- Data Memory
    MEM_SIGNALS(0) <= EX_SIGNALS(13); -- MEM_READ. 
    MEM_SIGNALS(1) <= '1' WHEN (OP_CODE = "01100" OR OP_CODE = "10000"
    OR OP_CODE = "10101" OR OP_CODE = "10111") ELSE
    '0'; -- MEM_WRITE. 1 when PUSH, STD, CALL, INT
    MEM_SIGNALS(2) <= '1' WHEN (OP_CODE = "01100" OR OP_CODE = "01101"
    OR (OP_CODE >= "10101" AND OP_CODE <= "11000")) ELSE
    '0'; -- DM_ADDR. 1 when DM[SP] else 0 (DM[ALU_RESULT]).
    MEM_SIGNALS(3) <= '1' WHEN (OP_CODE = "10101" OR OP_CODE = "10111") ELSE
    '0'; -- CALL_OR_INT. 1 when CALL, INT.
    -- Register Writeback Enable
    MEM_SIGNALS(4) <= '1' WHEN (OP_CODE = "00011" OR OP_CODE = "00100" OR OP_CODE = "00110"
    OR (OP_CODE >= "00111" AND OP_CODE <= "01011")
    OR (OP_CODE >= "01101" AND OP_CODE <= "01111")) ELSE
    '0'; -- REG_WRITE. 1 when NOT, INC, IN, MOV, ADD, SUB, AND, IADD, POP, LDM, LDD
    -- Store / Restore Flags when INT / RTI.
    MEM_SIGNALS(5) <= '1' WHEN OP_CODE = "11000" ELSE
    '0'; -- UPDATE_FLAGS. 1 when RTI.
    MEM_SIGNALS(6) <= '1' WHEN OP_CODE = "10111" ELSE
    '0'; -- ADD_FLAGS. 1 when INT.
    -- Stack Pointer
    MEM_SIGNALS(7) <= '1' WHEN (OP_CODE = "01100" OR OP_CODE = "01101"
    OR (OP_CODE >= "10101" AND OP_CODE <= "11000")) ELSE
    '0'; -- SP_EN. 1 when SP value changes.
    MEM_SIGNALS(8) <= '1'WHEN (OP_CODE = "01100" OR OP_CODE = "10101" OR OP_CODE = "10111") ELSE
    '0'; -- SP_DEC. 1 when PUSH, CALL, INT
    -- RET OR RTI
    MEM_SIGNALS(9) <= '1' WHEN (OP_CODE = "10110" OR OP_CODE = "11000") ELSE
    '0'; -- IS_RET_RTI. 1 when RET, RTI

    -- Pipeline Control Signals (WB Stage)
    -- IO Signals
    WB_SIGNALS(0) <= '1' WHEN OP_CODE = "00101" ELSE
    '0'; -- OUT_SIG. 1 when OUT
    WB_SIGNALS(1) <= '1' WHEN OP_CODE = "00110" ELSE
    '0'; -- IN_SIG. 1 when IN
    -- Memory to Register
    WB_SIGNALS(2) <= '0' WHEN (OP_CODE = "01101" AND OP_CODE = "01111") ELSE
    '1'; -- MEM_TO_REG. 0 when POP, LDD
    -- Register Writeback Enable
    WB_SIGNALS(3) <= '1' WHEN (OP_CODE = "00011" OR OP_CODE = "00100" OR OP_CODE = "00110"
    OR (OP_CODE >= "00111" AND OP_CODE <= "01011")
    OR (OP_CODE >= "01101" AND OP_CODE <= "01111")) ELSE
    '0'; -- REG_WRITE. 1 when NOT, INC, IN, MOV, ADD, SUB, AND, IADD, POP, LDM, LDD

END ARCHITECTURE;