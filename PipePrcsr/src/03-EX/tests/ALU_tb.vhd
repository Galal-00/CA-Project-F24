LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU_tb IS
END ENTITY;

ARCHITECTURE Behavioral OF ALU_tb IS
    -- Component declaration for the Unit Under Test (UUT)
    COMPONENT ALU IS
        PORT (
            operand1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            operand2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            ALU_Result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals for UUT
    SIGNAL operand1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL operand2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL OpCode : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ALU_Result : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Flags : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- Clock period (for timing if needed)
    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    UUT : ALU
    PORT MAP(
        operand1 => operand1,
        operand2 => operand2,
        OpCode => OpCode,
        ALU_Result => ALU_Result,
        Flags => Flags
    );
  
    -- Stimulus process
    Stimulus : PROCESS
    BEGIN
        -- Test SETC, operands should be irrelevant (00010)
        OpCode <= "00010";
        operand1 <= X"1234";
        operand2 <= (OTHERS => '0');
        WAIT FOR clk_period;
        ASSERT ALU_Result = X"0000" AND Flags = "011" REPORT "SETC failed" SEVERITY ERROR;

        -- Test MOV (00111)
        OpCode <= "00111";
        operand1 <= X"1234";
        operand2 <= (OTHERS => '0');
        WAIT FOR clk_period;
        ASSERT ALU_Result = X"1234" REPORT "MOV failed" SEVERITY ERROR;

        -- Test ADD (01000)
        OpCode <= "01000";
        operand1 <= X"0003";
        operand2 <= X"0004";
        WAIT FOR clk_period;
        ASSERT ALU_Result = X"0007" REPORT "ADD failed" SEVERITY ERROR;
       
        -- Test ADD carry flag and zero flag (01000)
        OpCode <= "01000";
        operand1 <= X"FFFF";
        operand2 <= X"0001";
        WAIT FOR clk_period;
        ASSERT ALU_Result = X"0000" and Flags = "011" REPORT "ADD failed" SEVERITY ERROR;

        -- Test SUB (01001)
        OpCode <= "01001";
        operand1 <= X"0007";
        operand2 <= X"0003";
        WAIT FOR clk_period;
        ASSERT ALU_Result = X"0004" REPORT "SUB failed" SEVERITY ERROR;
   
        -- Test SUB and neg flag  and carry flag (in this case it represents borrow)(01001)
        OpCode <= "01001";
        operand1 <= X"0003";
        operand2 <= X"0007";
        WAIT FOR clk_period;
        ASSERT ALU_Result = X"0004" and Flags = "110" REPORT "SUB failed" SEVERITY ERROR;

        -- Test AND (01010)
        OpCode <= "01010";
        operand1 <= X"F0F0";
        operand2 <= X"0F0F";
        WAIT FOR clk_period;
        ASSERT ALU_Result = X"0000" REPORT "AND failed" SEVERITY ERROR;

        -- Test undefined OpCode (default case)
        OpCode <= "11111";
        operand1 <= X"ABCD";
        operand2 <= X"1234";
        WAIT FOR clk_period;
        -- ASSERT ALU_Result = (OTHERS => '0') REPORT "Undefined OpCode failed" SEVERITY ERROR;

        -- End simulation
        WAIT;
    END PROCESS;
END ARCHITECTURE;