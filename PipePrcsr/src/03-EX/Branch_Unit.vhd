LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Branch_Unit IS
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
END entity Branch_Unit;

ARCHITECTURE BU OF Branch_Unit IS
    SIGNAL Selected_Flag : STD_LOGIC;
    SIGNAL Branch_Confirmed     : STD_LOGIC;
BEGIN
    -- Select the appropriate condition flag based on Jump_Condition
    Selected_Flag <= Flags(0) WHEN Jump_Condition = "00" ELSE -- JZ
                     Flags(1) WHEN Jump_Condition = "01" ELSE -- JN
                     Flags(2);  -- JC

    Branch_Confirmed <= Branch_Enable AND (Jump_Unconditional OR Selected_Flag);

    -- MUX: Jump to next instruction or to target address?
    Jump_Address <= PC_inc WHEN Branch_Confirmed = '0' ELSE Target_Address;

    -- Generate Flush / Next PC Unit signal
    PCSrc <= Branch_Confirmed;

END BU;
