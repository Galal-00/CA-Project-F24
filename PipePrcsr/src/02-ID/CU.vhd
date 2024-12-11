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

ENTITY CU IS
    PORT (
        INSTR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        SP_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        ALU_RESULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        EX_Opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        Store_EN_EPC : OUT STD_LOGIC := '0';
        EXP_SRC : OUT STD_LOGIC := '0';
        EXP_SIG : OUT STD_LOGIC := '0';
        EXP_NUM : OUT STD_LOGIC := '0';

        INT_SIG : OUT STD_LOGIC := '0';
        INT_INDEX : OUT STD_LOGIC := '0'
    );
END ENTITY CU;

ARCHITECTURE CU_arch OF CU IS

    SIGNAL OP_CODE : STD_LOGIC_VECTOR(4 DOWNTO 0) := INSTR(15 DOWNTO 11);
    SIGNAL IS_LDD_OR_STD : STD_LOGIC := '0';

BEGIN

    -- Exceptions:
    -- Invalid MEM address (IM) can occur when PC > 0x0FFF. Cases:
    -- 1- PC += 1 > 0x0FFF
    -- 2- Jump or Call  w/ R[Rsrc1] > 0x0FFF
    -- 3- RET / RTI w/ DM[SP] > 0x0FFF
    -- 4- INT w/ IM[index + 3] > 0x0FFF ?????
    -- Invalid MEM address (DM) can occur when DM read address > 0x0FFF:
    -- 1- MEM access w/ address from ALU (LDD / STD)

    IS_LDD_OR_STD <= '1' WHEN (OP_CODE = "01111" OR OP_CODE = "10000") ELSE
        '0';
    EXP_SIG <= '1' WHEN (PC > x"0FFF" OR (IS_LDD_OR_STD = '1' AND ALU_RESULT > x"0FFF")) ELSE
        '0';

    -- Empty stack can occur when SP > 0x0FFF. Cases:
    -- 1- POP. SP += 1 > 0x0FFF
    -- 2- RET / RTI ??? SP += 1 > 0x0FFF

    -- Interrupts:
    -- Opcode = "10111".
    -- INSTR(1) = index.
    INT_SIG <= '1' WHEN OP_CODE = "10111" ELSE
        '0';
    INT_INDEX <= INSTR(1);
END ARCHITECTURE;