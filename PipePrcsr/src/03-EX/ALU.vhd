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

-- MOV  00111 Rsrc1  Rdst   
-- ADD  01000 Rsrc1 Rsrc2 Rdst   
-- SUB  01001 Rsrc1 Rsrc2 Rdst   
-- AND  01010 Rsrc1 Rsrc2 Rdst   
-- IADD Imm 01011 Rsrc1  Rdst 

-- PUSH  01100 Rsrc1     
-- POP  01101   Rdst   
-- LDM Imm 01110   Rdst   
-- LDD Offset 01111 Rsrc1 Rdst
-- STD  Offset 10000 Rsrc1 Rsrc2  
ENTITY ALU IS
    PORT (
        -- Inputs
        operand1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        operand2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- Outputs
        ALU_Result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY ALU;

ARCHITECTURE ALU_arch OF ALU IS
    SIGNAL temp1 : STD_LOGIC_VECTOR(16 DOWNTO 0);
    SIGNAL temp2 : STD_LOGIC_VECTOR(16 DOWNTO 0);
    SIGNAL tempRes : STD_LOGIC_VECTOR(16 DOWNTO 0);

BEGIN
    -- Assign operands to temp signals
    temp1 <= '0' & operand1;
    temp2 <= '0' & operand2;

    tempRes <= temp1 WHEN OpCode = "00111" ELSE -- Mov
        STD_LOGIC_VECTOR(unsigned(temp1) + unsigned(temp2)) WHEN OpCode = "01000" OR OpCode = "01011" ELSE -- ADD
        STD_LOGIC_VECTOR(unsigned(temp1) - unsigned(temp2)) WHEN OpCode = "01001" ELSE -- SUB
        temp1 AND temp2 WHEN OpCode = "01010" ELSE -- AND
        (OTHERS => '0'); -- Default case

    -- Assign the result to ALU_Result
    ALU_Result <= tempRes(15 DOWNTO 0);

    -- Update the flags
    Flags(0) <= '1' WHEN ALU_Result = "0000000000000000" ELSE
    '0'; -- Zero flag
    Flags(1) <= tempRes(16); -- Carry Flag
    Flags(2) <= ALU_Result(15); -- Negative Flag
END ARCHITECTURE;