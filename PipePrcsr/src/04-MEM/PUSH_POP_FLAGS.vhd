LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY PUSH_POP_FLAGS IS
    PORT (
        -- Control Signals i/p
        ADD_FLAGS : IN STD_LOGIC;
        -- Data i/p
        FLAGS : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        PC_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        DM_DATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- Data o/p
        PC_INC_MODIFIED : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        RET_RTI_ADDRESS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        FLAGS_POPPED : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY PUSH_POP_FLAGS;

ARCHITECTURE PUSH_POP_FLAGS_arch OF PUSH_POP_FLAGS IS

BEGIN

    -- PC increment value
    PC_INC_MODIFIED(11 DOWNTO 0) <= PC_INC(11 DOWNTO 0);
    PC_INC_MODIFIED(15) <= PC_INC(15);

    -- Push Flags to PC increment unused bits
    PC_INC_MODIFIED(14 DOWNTO 12) <= FLAGS WHEN ADD_FLAGS = '1' ELSE
    PC_INC(14 DOWNTO 12);

    -- Pop flags from DM_DATA 
    FLAGS_POPPED <= DM_DATA(14 DOWNTO 12);
    RET_RTI_ADDRESS(15) <= DM_DATA(15); -- may be unnecessary but just in case the return PC is erroneous
    RET_RTI_ADDRESS(14 DOWNTO 12) <= (OTHERS => '0');
    RET_RTI_ADDRESS(11 DOWNTO 0) <= DM_DATA(11 DOWNTO 0);

END ARCHITECTURE;