LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Branch_Unit_tb IS
END ENTITY;

ARCHITECTURE Behavioral OF Branch_Unit_tb IS
    -- Component declaration for the Unit Under Test (UUT)
    COMPONENT Branch_Unit IS
        PORT (
            Flags           : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);  -- Condition flags (C, N, Z)
            Jump_Condition  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            Jump_Unconditional : IN  STD_LOGIC;
            Branch_Enable    : IN  STD_LOGIC;
            PC_inc     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            Target_Address      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    
            PCSrc     : OUT STD_LOGIC;
            Jump_Address  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals for UUT
    
    -- Note: Flags(0): Z, Flags(1): N, Flags(2): C
    SIGNAL Flags : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_increment : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ReadData1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Jump_Cond : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Jump_Uncond : STD_LOGIC := '0';
    SIGNAL Branch : STD_LOGIC := '0';

    SIGNAL Final_Jump : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL PC_Source : STD_LOGIC;

    -- Clock period (for timing if needed)
    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    UUT : Branch_Unit
    PORT MAP(
        Flags => Flags,
        Jump_Condition => Jump_Cond,
        Jump_Unconditional => Jump_Uncond,
        Branch_Enable => Branch,
        PC_inc => PC_increment,
        Target_Address => ReadData1,

        PCSrc => PC_Source,
        Jump_Address => Final_Jump
    );
  
    -- Stimulus process
    Stimulus : PROCESS
    BEGIN
        -- Test with Branch signal = 0 but all other possible conditions satisified
        Branch <= '0';
        Jump_Uncond <= '1';
        Flags <= "111";
        PC_increment <= X"1234";
        ReadData1 <= X"9999";
        WAIT FOR clk_period;
        ASSERT Final_Jump = X"1234" AND PC_Source = '0' REPORT "Branch signal = 0 failed" SEVERITY ERROR;

        -- Test with JZ but Z = 0
        Branch <= '1';
        Jump_Cond <= "00";
        Jump_Uncond <= '0';
        Flags <= "000";
        PC_increment <= X"1234";
        ReadData1 <= X"9999";
        WAIT FOR clk_period;
        ASSERT Final_Jump = X"1234" AND PC_Source = '0' REPORT "JZ (Z = 0) failed" SEVERITY ERROR;

        -- Test with JZ but Z = 1
        Branch <= '1';
        Jump_Cond <= "00";
        Jump_Uncond <= '0';
        Flags <= "001";
        PC_increment <= X"1234";
        ReadData1 <= X"9999";
        WAIT FOR clk_period;
        ASSERT Final_Jump = X"9999" AND PC_Source = '1' REPORT "JZ (Z = 1) failed" SEVERITY ERROR;

        -- Test with JN but N = 0
        Branch <= '1';
        Jump_Cond <= "01";
        Jump_Uncond <= '0';
        Flags <= "001";
        PC_increment <= X"1234";
        ReadData1 <= X"9999";
        WAIT FOR clk_period;
        ASSERT Final_Jump = X"1234" AND PC_Source = '0' REPORT "JN (N = 0) failed" SEVERITY ERROR;
        
        -- Test with JN but N = 1
        Branch <= '1';
        Jump_Cond <= "01";
        Jump_Uncond <= '0';
        Flags <= "011";
        PC_increment <= X"1234";
        ReadData1 <= X"9999";
        WAIT FOR clk_period;
        ASSERT Final_Jump = X"9999" AND PC_Source = '1' REPORT "JN (N = 1) failed" SEVERITY ERROR;

        -- Test with JC but C = 0
        Branch <= '1';
        Jump_Cond <= "10";
        Jump_Uncond <= '0';
        Flags <= "011";
        PC_increment <= X"1234";
        ReadData1 <= X"9999";
        WAIT FOR clk_period;
        ASSERT Final_Jump = X"1234" AND PC_Source = '0' REPORT "JC (C = 0) failed" SEVERITY ERROR;

        -- Test with JC but C = 1
        Branch <= '1';
        Jump_Cond <= "10";
        Jump_Uncond <= '0';
        Flags <= "111";
        PC_increment <= X"1234";
        ReadData1 <= X"9999";
        WAIT FOR clk_period;
        ASSERT Final_Jump = X"9999" AND PC_Source = '1' REPORT "JC (C = 1) failed" SEVERITY ERROR;

        -- Test with Unconditional Jump
        Branch <= '1';
        Jump_Cond <= "00";
        Jump_Uncond <= '1';
        Flags <= "000";
        PC_increment <= X"1234";
        ReadData1 <= X"9999";
        WAIT FOR clk_period;
        ASSERT Final_Jump = X"9999" AND PC_Source = '1' REPORT "Unconditional Jump failed" SEVERITY ERROR;

        WAIT FOR clk_period;

        -- End simulation
        WAIT;
    END PROCESS;
END ARCHITECTURE;