LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY EX_MEM_reg IS
    PORT (
        Clk : IN STD_ULOGIC;
        Rst : IN STD_ULOGIC;

        -- input control signals
        MemRead : IN STD_ULOGIC;
        MemWrite : IN STD_ULOGIC;
        MemToReg : IN STD_ULOGIC;
        DM_Addr : IN STD_ULOGIC;
        CallSig : IN STD_ULOGIC;
        Add_Flags : IN STD_ULOGIC;
        SP_DEC : IN STD_ULOGIC;
        SP_EN : IN STD_ULOGIC;
        OutSig : IN STD_ULOGIC;
        Is_RET_RTI : IN STD_ULOGIC;
        Update_Flags : IN STD_ULOGIC;
        InSig : IN STD_ULOGIC;

        -- Output control signals
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
        Update_Flags_Out : OUT STD_ULOGIC;
        InSig_Out : OUT STD_ULOGIC;

        -- input data
        ALU_Result_In : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        PC_inc : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Flags : IN STD_ULOGIC_VECTOR(2 DOWNTO 0); -- from flag reg
        ReadData1 : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Rdst : IN STD_ULOGIC_VECTOR(2 DOWNTO 0);
        OpCode : IN STD_ULOGIC_VECTOR(4 DOWNTO 0);
        IN_Port : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        SP_inc : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);

        -- Output data from the Ex/Mem reg
        ALU_Result_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        PC_inc_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Flags_Out : OUT STD_ULOGIC_VECTOR(2 DOWNTO 0); -- from flag reg
        ReadData1_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Rdst_Out : OUT STD_ULOGIC_VECTOR(2 DOWNTO 0);
        OpCode_Out : OUT STD_ULOGIC_VECTOR(4 DOWNTO 0);
        IN_Port_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        SP_inc_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0)

    );
END ENTITY EX_MEM_reg;

ARCHITECTURE EX_MEM_reg_arch OF EX_MEM_reg IS

BEGIN
    PROCESS (Clk, Rst)
    BEGIN
        IF Rst = '1' THEN
            MemRead_Out <= '0';
            MemWrite_Out <= '0';
            MemToReg_Out <= '0';
            DM_Addr_Out <= '0';
            CallSig_Out <= '0';
            Add_Flags_Out <= '0';
            SP_DEC_Out <= '0';
            SP_EN_Out <= '0';
            OutSig_Out <= '0';
            Is_RET_RTI_Out <= '0';
            Update_Flags_Out <= '0';
            InSig_Out <= '0';
            ALU_Result_Out <= (OTHERS => '0');
            PC_inc_Out <= (OTHERS => '0');
            Flags_Out <= (OTHERS => '0');
            ReadData1_Out <= (OTHERS => '0');
            Rdst_Out <= (OTHERS => '0');
            OpCode_Out <= (OTHERS => '0');
            IN_Port_Out <= (OTHERS => '0');
            SP_inc_Out <= (OTHERS => '0');
        ELSIF rising_edge(Clk) THEN
            MemRead_Out <= MemRead;
            MemWrite_Out <= MemWrite;
            MemToReg_Out <= MemToReg;
            DM_Addr_Out <= DM_Addr;
            CallSig_Out <= CallSig;
            Add_Flags_Out <= Add_Flags;
            SP_DEC_Out <= SP_DEC;
            SP_EN_Out <= SP_EN;
            OutSig_Out <= OutSig;
            Is_RET_RTI_Out <= Is_RET_RTI;
            Update_Flags_Out <= Update_Flags;
            InSig_Out <= InSig;
            ALU_Result_Out <= ALU_Result_In;
            PC_inc_Out <= PC_inc;
            Flags_Out <= Flags;
            ReadData1_Out <= ReadData1;
            Rdst_Out <= Rdst;
            OpCode_Out <= OpCode;
            IN_Port_Out <= IN_Port;
            SP_inc_Out <= SP_inc;
        END IF;
    END PROCESS;

END ARCHITECTURE;