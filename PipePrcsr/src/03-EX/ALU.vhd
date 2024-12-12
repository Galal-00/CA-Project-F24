LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

-- NOP  00000      
-- HLT  00001      
-- SETC  00010      
-- NOT  00011 Rsrc1  Rdst   
-- INC  00100 Rsrc1  Rdst   
-- OUT  00101 Rsrc1     
-- IN  00110   Rdst   

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

ARCHITECTURE ALU_arch OF ALU IS
    SIGNAL temp1 : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL temp2 : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL tempRes : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0)

BEGIN

    WITH OpCode SELECT
        tempRes <= < value > WHEN < sel_value >,
        < value > WHEN OTHERS;

END ARCHITECTURE;