LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY WB IS
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        -- Control signals i/p
        WB_SIGNALS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        -- Data i/p
        ALU_RESULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        DM_DATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        IN_DATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        OP_CODE_IN : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- Control signals o/p
        REG_WRITE : OUT STD_LOGIC;
        -- Data o/p
        OUT_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        REG_WB_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        OP_CODE_OUT : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END ENTITY WB;

ARCHITECTURE WB_arch OF WB IS

    COMPONENT OUT_UNIT IS
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            -- Control signals i/p
            OUT_SIG : IN STD_LOGIC;
            -- Data i/p
            ALU_RESULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- Data o/p
            OUT_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT OUT_UNIT;

    SIGNAL MEM_TO_REG : STD_LOGIC := '1';
    SIGNAL IN_SIG : STD_LOGIC := '0';

BEGIN

    -- WB logic
    IN_SIG <= WB_SIGNALS(1);
    MEM_TO_REG <= WB_SIGNALS(2);

    REG_WB_DATA <= IN_DATA WHEN IN_SIG = '1' ELSE
        DM_DATA WHEN (IN_SIG = '0' AND MEM_TO_REG = '0') ELSE
        ALU_RESULT; -- To ID stage.

    -- Component Instantiation
    OUT_UNIT_inst : OUT_UNIT PORT MAP(
        CLK => CLK,
        RST => RST,
        -- Control signals i/p
        OUT_SIG => WB_SIGNALS(0),
        -- Data i/p
        ALU_RESULT => ALU_RESULT,
        -- Data o/p
        OUT_DATA => OUT_DATA
    );

    -- To ID stage
    REG_WRITE <= WB_SIGNALS(3);

    -- To EX stage
    OP_CODE_OUT <= OP_CODE_IN;

    -- To ID and EX stages
    Rdst_OUT <= Rdst_IN;

END ARCHITECTURE;