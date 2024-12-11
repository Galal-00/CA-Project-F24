LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY EX IS
    PORT (
        Clk : IN STD_ULOGIC;
        Rst : IN STD_ULOGIC;
       
        -- Input control signals
        MemRead : IN STD_ULOGIC;
        MemWrite : IN STD_ULOGIC;
        MemToReg : IN STD_ULOGIC;
        SP_INC : IN STD_ULOGIC;
        SP_DEC : IN STD_ULOGIC;
        SP_EN : IN STD_ULOGIC;
        Set_Flags : IN STD_ULOGIC_VECTOR(2 DOWNTO 0);
        Reset_Flags : IN STD_ULOGIC_VECTOR(2 DOWNTO 0);
        Add_Flags : IN STD_ULOGIC;
        Jump_Cond : IN STD_ULOGIC_VECTOR(1 DOWNTO 0);
        Jump_Uncond : IN STD_ULOGIC_VECTOR(1 DOWNTO 0);
        ALU_Src1 : IN STD_ULOGIC;
        ALU_Src2 : IN STD_ULOGIC;
        CallSig : IN STD_ULOGIC;
        RegWrite : IN STD_ULOGIC;
        DM_Addr : IN STD_ULOGIC;
        OutSig : IN STD_ULOGIC;
        InSig : IN STD_ULOGIC;
        Ex_Flush : IN STD_ULOGIC;
        ALU_OP : IN STD_ULOGIC_VECTOR(1 DOWNTO 0); -- change its size later!!
        Is_RET_RTI : IN STD_ULOGIC;

        -- Input control signals from next stages
        RegWrite_Ex_Mem : IN STD_ULOGIC;
        RegWrite_Mem_Wb : IN STD_ULOGIC;
        Update_Flags : IN STD_ULOGIC; -- from EX/MEM reg

        -- Input data 
        ReadData1 : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        ReadData2 : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        IMM : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Rdst : IN STD_ULOGIC_VECTOR(2 DOWNTO 0);
        Rsrc1 : IN STD_ULOGIC_VECTOR(2 DOWNTO 0);
        Rsrc2 : IN STD_ULOGIC_VECTOR(2 DOWNTO 0);
        OpCode : IN STD_ULOGIC_VECTOR(4 DOWNTO 0);
        PC_inc : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);

        -- input data forwarded from the next stages registers
        Fwd_Ex_Mem : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Fwd_Mem_WB : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        IN_Ex_Mem : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        IN_Mem_Wb : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Rdst_Ex_Mem : IN STD_ULOGIC_VECTOR(2 DOWNTO 0);
        Rdst_Mem_Wb : IN STD_ULOGIC_VECTOR(2 DOWNTO 0);

        -- input data from mem stage
        Flags : IN STD_ULOGIC_VECTOR(2 DOWNTO 0);
        SP_Write_Data : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        -- in Port from outside will connect to EX/MEM reg
        IN_Port : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);

        -- Output data from the Ex/Mem reg
        Jump : OUT STD_ULOGIC;
        ALU_Result : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        PC_inc_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Flags_Out : OUT STD_ULOGIC_VECTOR(2 DOWNTO 0); -- from flag reg
        ReadData1_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Rdst_Out : OUT STD_ULOGIC_VECTOR(2 DOWNTO 0);
        OpCode_Out : OUT STD_ULOGIC_VECTOR(4 DOWNTO 0);
        IN_Port_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        SP_inc_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);

        -- Output control signals
        Flush : OUT STD_ULOGIC; -- goes to flush unit
        MemRead_Out : OUT STD_ULOGIC;
        MemWrite_Out : OUT STD_ULOGIC;
        MemToReg_Out : OUT STD_ULOGIC;
        DM_Addr_Out : OUT STD_ULOGIC;
        CallSig_Out : OUT STD_ULOGIC;
        Add_Flags_Out : OUT STD_ULOGIC;
        SP_DEC_Out : OUT STD_ULOGIC;
        SP_EN_Out : OUT STD_ULOGIC;
        OutSig_Out : OUT STD_ULOGIC;
        Is_RET_RTI_Out : OUT STD_ULOGIC;
        Update_Flags_Out : OUT STD_ULOGIC; -- from EX/MEM reg
        InSig_Out : OUT STD_ULOGIC
    );
END ENTITY EX;

ARCHITECTURE Rtl OF EX IS
  
BEGIN
 
END ARCHITECTURE;