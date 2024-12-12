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
        RegWrite : IN STD_ULOGIC;
        -- Output control signals

        -- Control signals vector for Mem

        -- Mem_Control_Sigs(0) : MemRead
        -- Mem_Control_Sigs(1) : MemWrite
        -- Mem_Control_Sigs(2) : DM_Addr
        -- Mem_Control_Sigs(3) : CallSig
        -- Mem_Control_Sigs(4) : Add_Flags
        -- Mem_Control_Sigs(5) : SP_DEC
        -- Mem_Control_Sigs(6) : SP_EN
        -- Mem_Control_Sigs(7) : Is_RET_RTI
        -- Mem_Control_Sigs(8) : Update_Flags

        Mem_Control_Sigs : OUT STD_ULOGIC_VECTOR(8 DOWNTO 0)

        -- Control signals vector for WB

        -- Wb_Control_Sigs(0) : MemToReg
        -- Wb_Control_Sigs(1) : RegWrite
        -- Wb_Control_Sigs(2) : OutSig
        -- Wb_Control_Sigs(3) : InSig
        Wb_Control_Sigs : OUT STD_ULOGIC_VECTOR(3 DOWNTO 0)

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
            Mem_Control_Sigs <= (OTHERS => '0');
            Wb_Control_Sigs <= (OTHERS => '0');

            ALU_Result_Out <= (OTHERS => '0');
            PC_inc_Out <= (OTHERS => '0');
            Flags_Out <= (OTHERS => '0');
            ReadData1_Out <= (OTHERS => '0');
            Rdst_Out <= (OTHERS => '0');
            OpCode_Out <= (OTHERS => '0');
            IN_Port_Out <= (OTHERS => '0');
            SP_inc_Out <= (OTHERS => '0');
        ELSIF rising_edge(Clk) THEN
            -- Update Mem_Control_Sigs
            Mem_Control_Sigs(0) <= MemRead;
            Mem_Control_Sigs(1) <= MemWrite;
            Mem_Control_Sigs(2) <= DM_Addr;
            Mem_Control_Sigs(3) <= CallSig;
            Mem_Control_Sigs(4) <= Add_Flags;
            Mem_Control_Sigs(5) <= SP_DEC;
            Mem_Control_Sigs(6) <= SP_EN;
            Mem_Control_Sigs(7) <= Is_RET_RTI;
            Mem_Control_Sigs(8) <= Update_Flags;

            -- Update Wb_Control_Sigs
            Wb_Control_Sigs(0) <= MemToReg;
            Wb_Control_Sigs(1) <= RegWrite;
            Wb_Control_Sigs(2) <= OutSig;
            Wb_Control_Sigs(3) <= InSig;
            
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