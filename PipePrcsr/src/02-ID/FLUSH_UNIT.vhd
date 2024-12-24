LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY FLUSH_UNIT IS
    PORT (
        -- Control signals i/p
        Store_EN_EPC : IN STD_LOGIC;
        EXP_SRC : IN STD_LOGIC;
        BRANCH_FLUSH : IN STD_LOGIC;
        IS_RET_RTI : IN STD_LOGIC;
        -- Data i/p
        OP_CODE : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- Hazard Signals o/p
        IF_ID_FLUSH : OUT STD_LOGIC;
        ID_EX_FLUSH : OUT STD_LOGIC;
        EX_FLUSH : OUT STD_LOGIC
    );
END ENTITY FLUSH_UNIT;

ARCHITECTURE FLUSH_UNIT_arch OF FLUSH_UNIT IS

    -- Branch Flush Condition. Flushes IF, ID stages
    SIGNAL BRANCH_FLUSH_CONDITION : STD_LOGIC := '0';

    -- RET, RTI Flush Condition. Flushes IF, ID, EX stages
    SIGNAL RET_RTI_FLUSH_CONDITION : STD_LOGIC := '0';

    -- INT Flush Condition. Flushes IF stage
    SIGNAL INT_FLUSH_CONDITION : STD_LOGIC := '0';

    -- When EXP occurs in ID stage, flushes IF, ID stages.
    SIGNAL EXP_ID_FLUSH_CONDITION : STD_LOGIC := '0';

    -- When EXP occurs in EX stage, flushes IF, ID, EX stages.
    SIGNAL EXP_EX_FLUSH_CONDITION : STD_LOGIC := '0';

BEGIN

    BRANCH_FLUSH_CONDITION <= BRANCH_FLUSH;

    RET_RTI_FLUSH_CONDITION <= '1' WHEN IS_RET_RTI = '1' ELSE
        '0';

    INT_FLUSH_CONDITION <= '1' WHEN OP_CODE = "10111" ELSE
        '0';

    EXP_ID_FLUSH_CONDITION <= '1' WHEN (Store_EN_EPC = '1' AND EXP_SRC = '0') ELSE
        '0';

    EXP_EX_FLUSH_CONDITION <= '1' WHEN (Store_EN_EPC = '1' AND EXP_SRC = '1') ELSE
        '0';

    IF_ID_FLUSH <= '1' WHEN (BRANCH_FLUSH_CONDITION = '1'
        OR RET_RTI_FLUSH_CONDITION = '1'
        OR INT_FLUSH_CONDITION = '1'
        OR EXP_ID_FLUSH_CONDITION = '1'
        OR EXP_EX_FLUSH_CONDITION = '1') ELSE
        '0';

    ID_EX_FLUSH <= '1' WHEN (BRANCH_FLUSH_CONDITION = '1'
        OR RET_RTI_FLUSH_CONDITION = '1'
        OR EXP_ID_FLUSH_CONDITION = '1'
        OR EXP_EX_FLUSH_CONDITION = '1') ELSE
        '0';

    EX_FLUSH <= '1' WHEN (RET_RTI_FLUSH_CONDITION = '1'
        OR EXP_EX_FLUSH_CONDITION = '1') ELSE
        '0';

END ARCHITECTURE;