LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY EX IS
    PORT (
        Clk : IN STD_LOGIC;
        Rst : IN STD_LOGIC;
       
        -- Input control signals
     
        -- Mem_Control_Sigs(0) : MemRead
        -- Mem_Control_Sigs(1) : MemWrite
        -- Mem_Control_Sigs(2) : DM_Addr
        -- Mem_Control_Sigs(3) : CallSig
        -- Mem_Control_Sigs(4) : Add_Flags
        -- Mem_Control_Sigs(5) : SP_DEC
        -- Mem_Control_Sigs(6) : SP_EN
        -- Mem_Control_Sigs(7) : Is_RET_RTI
        -- Mem_Control_Sigs(8) : Update_Flags
        -- Mem_Control_Sigs(9) : RegWrite for forwarding

        Mem_Control_Sigs : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        
      
        -- Wb_Control_Sigs(0) : MemToReg
        -- Wb_Control_Sigs(1) : RegWrite
        -- Wb_Control_Sigs(2) : OutSig
        -- Wb_Control_Sigs(3) : InSig
        Wb_Control_Sigs : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        -- Ex control sigs
        Reset_Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Jump_Cond : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        Jump_Uncond : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        SP_INC : IN STD_LOGIC;
        Set_Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ALU_Src1 : IN STD_LOGIC;
        ALU_Src2 : IN STD_LOGIC;
        Ex_Flush : IN STD_LOGIC;
        ALU_OP : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- change its size later!!

        -- Input control signals from next stages
        RegWrite_Ex_Mem : IN STD_LOGIC;
        RegWrite_Mem_Wb : IN STD_LOGIC;

        -- Input data 
        ReadData1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        ReadData2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        IMM : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        PC_inc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- input data forwarded from the next stages registers
        Fwd_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Fwd_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        IN_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        IN_Mem_Wb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst_Ex_Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rdst_Mem_Wb : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- input data from mem stage
        Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        SP_Write_Data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- in Port from outside will connect to EX/MEM reg
        IN_Port : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- Output data from the Ex/Mem reg
        Jump : OUT STD_LOGIC;
        ALU_Result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_inc_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Flags_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- from flag reg
        ReadData1_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        OpCode_Out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        IN_Port_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        SP_inc_data_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- Output control signals
        Mem_Control_Sigs_Out : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
        Wb_Control_Sigs_Out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY EX;

ARCHITECTURE Rtl OF EX IS
  
BEGIN
 
END ARCHITECTURE;