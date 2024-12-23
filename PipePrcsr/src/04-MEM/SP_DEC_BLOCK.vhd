LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SP_DEC_BLOCK IS
    PORT (
        -- Control Signals i/p
        SP_DEC_SIG : IN STD_LOGIC;
        -- Data i/p
        SP_INC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- Data o/p
        SP_WRITE_DATA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY SP_DEC_BLOCK;

ARCHITECTURE SP_DEC_BLOCK_arch OF SP_DEC_BLOCK IS

    SIGNAL SP_INC_VAL : INTEGER := 2 ** 12 - 1;

BEGIN
    SP_INC_VAL <= to_integer(unsigned(SP_INC));

    SP_WRITE_DATA <= STD_LOGIC_VECTOR(to_unsigned(SP_INC_VAL - 1, 16)) WHEN SP_DEC_SIG = '1' ELSE
        SP_INC; -- Stack Pointer Decrement.

END ARCHITECTURE;