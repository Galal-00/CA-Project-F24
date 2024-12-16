LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY EX_tb IS
END ENTITY EX_tb;

ARCHITECTURE behavior OF EX_tb IS

    COMPONENT EX
        PORT (
            Clk : IN STD_LOGIC;
            Rst : IN STD_LOGIC;
            Mem_Control_Sigs : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            Wb_Control_Sigs : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            Reset_Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Jump_Cond : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            Jump_Uncond : IN STD_LOGIC;
            SP_INC : IN STD_LOGIC;
            Set_Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ALU_Src1 : IN STD_LOGIC;
            ALU_Src2 : IN STD_LOGIC;
            Ex_Flush : IN STD_LOGIC;
            Update_Flags : IN STD_LOGIC;
            Branch : IN STD_LOGIC;
            SP_EN : IN STD_LOGIC;
            RegWrite_Ex_Mem : IN STD_LOGIC;
            RegWrite_Mem_Wb : IN STD_LOGIC;
            ReadData1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            ReadData2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IMM : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            PC_inc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Fwd_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Fwd_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst_Ex_Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdst_Mem_Wb : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            OpCode_Mem : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            OpCode_Wb : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            Flags_Popped : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            SP_Write_Data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_Port : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Jump_Addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            PCSrc : OUT STD_LOGIC;
            ALU_Result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_inc_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            ReadData1_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            OpCode_Out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            IN_Port_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            SP_inc_data_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Flags_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Mem_Control_Sigs_Out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            Wb_Control_Sigs_Out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL Clk : STD_LOGIC := '0';
    SIGNAL Rst : STD_LOGIC := '0';
    SIGNAL Mem_Control_Sigs : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Wb_Control_Sigs : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Reset_Flags : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Jump_Cond : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Jump_Uncond : STD_LOGIC := '0';
    SIGNAL SP_INC : STD_LOGIC := '0';
    SIGNAL Set_Flags : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ALU_Src1 : STD_LOGIC := '0';
    SIGNAL ALU_Src2 : STD_LOGIC := '0';
    SIGNAL Ex_Flush : STD_LOGIC := '0';
    SIGNAL Update_Flags : STD_LOGIC := '0';
    SIGNAL Branch : STD_LOGIC := '0';
    SIGNAL SP_EN : STD_LOGIC := '0';
    SIGNAL RegWrite_Ex_Mem : STD_LOGIC := '0';
    SIGNAL RegWrite_Mem_Wb : STD_LOGIC := '0';
    SIGNAL ReadData1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ReadData2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IMM : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rdst : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rsrc1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rsrc2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL OpCode : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_inc : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Fwd_Ex_Mem : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Fwd_Mem_WB : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IN_Ex_Mem : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IN_Mem_WB : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rdst_Ex_Mem : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Rdst_Mem_Wb : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL OpCode_Mem : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL OpCode_Wb : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Flags_Popped : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL SP_Write_Data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IN_Port : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Jump_Addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL PCSrc : STD_LOGIC;
    SIGNAL ALU_Result : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL PC_inc_Out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ReadData1_Out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Rdst_Out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL OpCode_Out : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL IN_Port_Out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL SP_inc_data_Out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Flags_Out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL Mem_Control_Sigs_Out : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL Wb_Control_Sigs_Out : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    uut : EX PORT MAP(
        Clk => Clk,
        Rst => Rst,
        Mem_Control_Sigs => Mem_Control_Sigs,
        Wb_Control_Sigs => Wb_Control_Sigs,
        Reset_Flags => Reset_Flags,
        Jump_Cond => Jump_Cond,
        Jump_Uncond => Jump_Uncond,
        SP_INC => SP_INC,
        Set_Flags => Set_Flags,
        ALU_Src1 => ALU_Src1,
        ALU_Src2 => ALU_Src2,
        Ex_Flush => Ex_Flush,
        Update_Flags => Update_Flags,
        Branch => Branch,
        SP_EN => SP_EN,
        RegWrite_Ex_Mem => RegWrite_Ex_Mem,
        RegWrite_Mem_Wb => RegWrite_Mem_Wb,
        ReadData1 => ReadData1,
        ReadData2 => ReadData2,
        IMM => IMM,
        Rdst => Rdst,
        Rsrc1 => Rsrc1,
        Rsrc2 => Rsrc2,
        OpCode => OpCode,
        PC_inc => PC_inc,
        Fwd_Ex_Mem => Fwd_Ex_Mem,
        Fwd_Mem_WB => Fwd_Mem_WB,
        IN_Ex_Mem => IN_Ex_Mem,
        IN_Mem_WB => IN_Mem_WB,
        Rdst_Ex_Mem => Rdst_Ex_Mem,
        Rdst_Mem_Wb => Rdst_Mem_Wb,
        OpCode_Mem => OpCode_Mem,
        OpCode_Wb => OpCode_Wb,
        Flags_Popped => Flags_Popped,
        SP_Write_Data => SP_Write_Data,
        IN_Port => IN_Port,
        Jump_Addr => Jump_Addr,
        PCSrc => PCSrc,
        ALU_Result => ALU_Result,
        PC_inc_Out => PC_inc_Out,
        ReadData1_Out => ReadData1_Out,
        Rdst_Out => Rdst_Out,
        OpCode_Out => OpCode_Out,
        IN_Port_Out => IN_Port_Out,
        SP_inc_data_Out => SP_inc_data_Out,
        Flags_Out => Flags_Out,
        Mem_Control_Sigs_Out => Mem_Control_Sigs_Out,
        Wb_Control_Sigs_Out => Wb_Control_Sigs_Out
    );
    Clk_process : PROCESS
    BEGIN
        Clk <= '0';
        WAIT FOR 10 ns;
        Clk <= '1';
        WAIT FOR 10 ns;
    END PROCESS;

    stim_proc : PROCESS
    BEGIN
        Rst <= '1';
        WAIT FOR 100 ns;
        Rst <= '0';

        Mem_Control_Sigs <= "0000000000";
        Wb_Control_Sigs <= "0000";
        Reset_Flags <= "001";
        Jump_Cond <= "01";
        Jump_Uncond <= '0';
        SP_INC <= '0';
        Set_Flags <= "000";
        ALU_Src1 <= '0';
        ALU_Src2 <= '0';
        Ex_Flush <= '0';
        Update_Flags <= '0';
        Branch <= '0';
        SP_EN <= '0';
        RegWrite_Ex_Mem <= '0';
        RegWrite_Mem_Wb <= '0';
        ReadData1 <= x"1234";
        ReadData2 <= x"5678";
        IMM <= x"9ABC";
        Rdst <= "001";
        Rsrc1 <= "010";
        Rsrc2 <= "011";
        OpCode <= "01000";
        PC_inc <= x"0001";
        Fwd_Ex_Mem <= x"1111";
        Fwd_Mem_WB <= x"2222";
        IN_Ex_Mem <= x"3333";
        IN_Mem_WB <= x"4444";
        Rdst_Ex_Mem <= "100";
        Rdst_Mem_Wb <= "101";
        OpCode_Mem <= "11000";
        OpCode_Wb <= "11001";
        Flags_Popped <= "011";
        SP_Write_Data <= x"5555";
        IN_Port <= x"6666";

        WAIT FOR 200 ns;
        WAIT;
    END PROCESS;

END ARCHITECTURE;