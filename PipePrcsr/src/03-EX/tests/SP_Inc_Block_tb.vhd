LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SP_Inc_Block_tb IS
END ENTITY;

ARCHITECTURE Behavioral OF SP_Inc_Block_tb IS
    -- Component Declaration
    COMPONENT SP_Inc_Block IS
        PORT (
            Clk : IN STD_ULOGIC;
            Rst : IN STD_ULOGIC;
            SP_EN : IN STD_ULOGIC;
            SP_INC : IN STD_ULOGIC;
            SP_Write_Data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            SP_inc_data_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals for testing
    SIGNAL Clk : STD_ULOGIC := '0';
    SIGNAL Rst : STD_ULOGIC := '0';
    SIGNAL SP_EN : STD_ULOGIC := '0';
    SIGNAL SP_INC : STD_ULOGIC := '0';
    SIGNAL SP_Write_Data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL SP_inc_data_Out : STD_LOGIC_VECTOR(15 DOWNTO 0);

    -- Clock period
    CONSTANT clk_period : time := 10 ns;

BEGIN
    -- DUT Instantiation
    DUT: SP_Inc_Block
        PORT MAP (
            Clk => Clk,
            Rst => Rst,
            SP_EN => SP_EN,
            SP_INC => SP_INC,
            SP_Write_Data => SP_Write_Data,
            SP_inc_data_Out => SP_inc_data_Out
        );

    -- Clock generation process
    Clk_process: PROCESS
    BEGIN
        Clk <= '0';
        WAIT FOR clk_period / 2;
        Clk <= '1';
        WAIT FOR clk_period / 2;
    END PROCESS;

    -- Stimulus process
    Stimulus: PROCESS
    BEGIN
        -- Reset
        Rst <= '1';
        WAIT FOR clk_period;
        Rst <= '0';

        -- Test 1: Load value into SP_reg
        SP_EN <= '1';
        SP_Write_Data <= X"FFF0"; -- Write a known value
        WAIT FOR clk_period;

        -- Test 2: Increment the stack pointer
        SP_EN <= '0';
        SP_INC <= '1';
        WAIT FOR clk_period;

        -- Test 3: Disable increment
        SP_INC <= '0';
        WAIT FOR clk_period;


        -- Test completed
        WAIT;
    END PROCESS;
END ARCHITECTURE;
