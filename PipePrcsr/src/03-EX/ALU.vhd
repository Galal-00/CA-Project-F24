LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY ALU IS
    PORT (
        -- Inputs
        operand1 : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        operand2 : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        OpCode : IN STD_ULOGIC_VECTOR(4 DOWNTO 0);
        -- Outputs
        ALU_Result : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0)

    );
END ENTITY ALU;