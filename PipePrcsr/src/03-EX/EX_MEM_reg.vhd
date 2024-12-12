LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY EX_MEM_reg IS
    PORT (
        Clk : IN STD_ULOGIC;
        Rst : IN STD_ULOGIC;

        -- input control signals
        Mem_Control_Sigs : IN STD_ULOGIC_VECTOR(9 DOWNTO 0);
        Wb_Control_Sigs : IN STD_ULOGIC_VECTOR(3 DOWNTO 0);
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
        -- Mem_Control_Sigs(9) : RegWrite for forwarding

        Mem_Control_Sigs_Out : OUT STD_ULOGIC_VECTOR(9 DOWNTO 0);

        -- Control signals vector for WB

        -- Wb_Control_Sigs(0) : MemToReg
        -- Wb_Control_Sigs(1) : RegWrite
        -- Wb_Control_Sigs(2) : OutSig
        -- Wb_Control_Sigs(3) : InSig
        Wb_Control_Sigs_Out : OUT STD_ULOGIC_VECTOR(3 DOWNTO 0);

        -- input data
        ALU_Result_In : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        PC_inc : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Flags : IN STD_ULOGIC_VECTOR(2 DOWNTO 0); -- from flag reg
        ReadData1 : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Rdst : IN STD_ULOGIC_VECTOR(2 DOWNTO 0);
        OpCode : IN STD_ULOGIC_VECTOR(4 DOWNTO 0);
        IN_Port : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);
        SP_inc_data : IN STD_ULOGIC_VECTOR(15 DOWNTO 0);

        -- Output data from the Ex/Mem reg
        ALU_Result_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        PC_inc_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Flags_Out : OUT STD_ULOGIC_VECTOR(2 DOWNTO 0); -- from flag reg
        ReadData1_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        Rdst_Out : OUT STD_ULOGIC_VECTOR(2 DOWNTO 0);
        OpCode_Out : OUT STD_ULOGIC_VECTOR(4 DOWNTO 0);
        IN_Port_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0);
        SP_inc_data_Out : OUT STD_ULOGIC_VECTOR(15 DOWNTO 0)

    );
END ENTITY EX_MEM_reg;

ARCHITECTURE EX_MEM_reg_arch OF EX_MEM_reg IS

BEGIN
    PROCESS (Clk, Rst)
    BEGIN
        IF Rst = '1' THEN
            Mem_Control_Sigs_Out <= (OTHERS => '0');
            Wb_Control_Sigs_Out <= (OTHERS => '0');

            ALU_Result_Out <= (OTHERS => '0');
            PC_inc_Out <= (OTHERS => '0');
            Flags_Out <= (OTHERS => '0');
            ReadData1_Out <= (OTHERS => '0');
            Rdst_Out <= (OTHERS => '0');
            OpCode_Out <= (OTHERS => '0');
            IN_Port_Out <= (OTHERS => '0');
            SP_inc_data_Out <= (OTHERS => '0');
        ELSIF rising_edge(Clk) THEN
            -- Update Mem_Control_Sigs_Out
            Mem_Control_Sigs_Out <= Mem_Control_Sigs;

            -- Update Wb_Control_Sigs_Out
            Wb_Control_Sigs_Out <= Wb_Control_Sigs;

            ALU_Result_Out <= ALU_Result_In;
            PC_inc_Out <= PC_inc;
            Flags_Out <= Flags;
            ReadData1_Out <= ReadData1;
            Rdst_Out <= Rdst;
            OpCode_Out <= OpCode;
            IN_Port_Out <= IN_Port;
            SP_inc_data_Out <= SP_inc_data;
        END IF;
    END PROCESS;

END ARCHITECTURE;