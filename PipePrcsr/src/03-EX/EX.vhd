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
        Jump_Uncond :  IN STD_LOGIC;
        SP_INC : IN STD_LOGIC;
        Set_Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ALU_Src1 : IN STD_LOGIC;
        ALU_Src2 : IN STD_LOGIC;
        Ex_Flush : IN STD_LOGIC;
        Update_Flags : IN STD_LOGIC; -- recieved from mem stage
        Branch : IN STD_LOGIC;
        SP_EN : IN STD_LOGIC; -- comes form the mem stage Mem_Control_Sigs(6)

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
        IN_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst_Ex_Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rdst_Mem_Wb : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        OpCode_Mem : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- for Forwarding unit to know the instruction was IN
        OpCode_Wb : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- for Forwarding unit to know the instruction was IN

        -- input data from mem stage
        Flags_Popped : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        SP_Write_Data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- in Port from outside will connect to EX/MEM reg
        IN_Port : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- Output data
        Jump_Addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        PCSrc : OUT STD_LOGIC;
        -- Output data from the Ex/Mem reg
        ALU_Result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_inc_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        ReadData1_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Rdst_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        OpCode_Out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        IN_Port_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        SP_inc_data_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Flags_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- Output control signals
        Mem_Control_Sigs_Out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        Wb_Control_Sigs_Out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY EX;

ARCHITECTURE Ex_arch OF EX IS

    SIGNAL Src1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Src2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ForwardA : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ForwardB : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL Flags_Reg_Out : STD_LOGIC_VECTOR(2 DOWNTO 0); -- from flag reg to branch unit and EX/MEM reg
    SIGNAL ALU_Result_Sig : STD_LOGIC_VECTOR(15 DOWNTO 0); --from alu to EX/MEM reg
    SIGNAL SP_inc_data_Sig : STD_LOGIC_VECTOR(15 DOWNTO 0); -- from the sp_inc_block adder to the EX/MEM reg
    SIGNAL Flags_ALU_TO_Reg : STD_LOGIC_VECTOR(2 DOWNTO 0); -- from ALU to flag reg
    SIGNAL MEM_CONTROL_FLUSH_MUX : STD_LOGIC_VECTOR(9 DOWNTO 0); -- from flush mux to EX/MEM reg
    SIGNAL WB_CONTROL_FLUSH_MUX : STD_LOGIC_VECTOR(3 DOWNTO 0); -- from flush mux to EX/MEM reg
    component EX_FLUSH_MUX is
        port (
            EX_MEM_FLUSH : IN STD_LOGIC;
            MEM_SIGNALS_IN : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            WB_SIGNALS_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            MEM_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            WB_SIGNALS_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
            
        );
    end component;
    
    COMPONENT Src_Mux IS
        PORT (
            ReadData1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            ReadData2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IMM : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Fwd_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Fwd_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_Ex_Mem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            IN_Mem_WB : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            ALU_Src1 : IN STD_LOGIC;
            ALU_Src2 : IN STD_LOGIC;
            ForwardA : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ForwardB : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Src1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Src2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)

        );
    END COMPONENT;

    COMPONENT ALU IS
        PORT (
            operand1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- src1
            operand2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- src2
            OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            ALU_Result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)

        );
    END COMPONENT;

    COMPONENT Flags_reg IS
        PORT (
            Clk : IN STD_LOGIC;
            Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- from ALU
            Flags_Popped : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- received from mem stage
            Set_Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Update_Flags : IN STD_LOGIC; -- received from mem stage
            Reset_Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Flags_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)

        );
    END COMPONENT;

    COMPONENT Branch_Unit IS
        PORT (
            Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Condition flags (C, N, Z)
            Jump_Condition : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            Jump_Unconditional : IN STD_LOGIC;
            Branch_Enable : IN STD_LOGIC;
            PC_inc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Target_Address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

            PCSrc : OUT STD_LOGIC;
            Jump_Address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)

        );
    END COMPONENT;

    COMPONENT ForwardingUnit IS
        PORT (
            -- input data
            EX_MEM_RegWrite : IN STD_LOGIC;
            MEM_WB_RegWrite : IN STD_LOGIC;
            Rdst_Ex_Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdst_Mem_Wb : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc1_ID_EX : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2_ID_EX : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            OpCode_Mem : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            OpCode_Wb : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

            -- output signals
            ForwardA : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            ForwardB : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)

        );
    END COMPONENT;

    COMPONENT EX_MEM_reg IS
        PORT (
            Clk : IN STD_LOGIC;
            Rst : IN STD_LOGIC;

            Mem_Control_Sigs : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            Wb_Control_Sigs : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

            Mem_Control_Sigs_Out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            Wb_Control_Sigs_Out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

            -- input data
            ALU_Result_In : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_inc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- from flag reg
            ReadData1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            OpCode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            IN_Port : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            SP_inc_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

            -- Output data from the Ex/Mem reg
            ALU_Result_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_inc_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Flags_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            ReadData1_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Rdst_Out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            OpCode_Out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            IN_Port_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            SP_inc_data_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)

        );
    END COMPONENT;

    COMPONENT SP_Inc_Block IS
        PORT (
            Clk : IN STD_LOGIC;
            Rst : IN STD_LOGIC;
            SP_EN : IN STD_LOGIC;
            SP_INC : IN STD_LOGIC;
            SP_Write_Data : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- comes from the mem stage
            SP_inc_data_Out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- goes to the mem stage

        );
    END COMPONENT;
BEGIN
    Src_Mux_Inst : Src_Mux
    PORT MAP(
        ReadData1 => ReadData1,
        ReadData2 => ReadData2,
        IMM => IMM,
        Fwd_Ex_Mem => Fwd_Ex_Mem,
        Fwd_Mem_WB => Fwd_Mem_WB,
        IN_Ex_Mem => IN_Ex_Mem,
        IN_Mem_WB => IN_Mem_WB,
        ALU_Src1 => ALU_Src1,
        ALU_Src2 => ALU_Src2,
        ForwardA => ForwardA,
        ForwardB => ForwardB,
        Src1 => Src1,
        Src2 => Src2
    );

    ALU_Inst : ALU
    PORT MAP(
        operand1 => Src1,
        operand2 => Src2,
        OpCode => OpCode,
        ALU_Result => ALU_Result_Sig,
        Flags => Flags_ALU_TO_Reg
    );

    Flags_reg_Inst : Flags_reg
    PORT MAP(
        Clk => Clk,
        Flags => Flags_ALU_TO_Reg,
        Flags_Popped => Flags_Popped,
        Set_Flags => Set_Flags,
        Update_Flags => Update_Flags,
        Reset_Flags => Reset_Flags,
        Flags_Out => Flags_Reg_Out
    );

    Branch_Unit_Inst : Branch_Unit
    PORT MAP(
        Flags => Flags_Reg_Out,
        Jump_Condition => Jump_Cond,
        Jump_Unconditional => Jump_Uncond,
        Branch_Enable => Branch,
        PC_inc => PC_inc,
        Target_Address => IMM,
        PCSrc => PCSrc,
        Jump_Address => Jump_Addr
    );

    ForwardingUnit_Inst : ForwardingUnit
    PORT MAP(
        EX_MEM_RegWrite => RegWrite_Ex_Mem,
        MEM_WB_RegWrite => RegWrite_Mem_Wb,
        Rdst_Ex_Mem => Rdst_Ex_Mem,
        Rdst_Mem_Wb => Rdst_Mem_Wb,
        Rsrc1_ID_EX => Rsrc1,
        Rsrc2_ID_EX => Rsrc2,
        OpCode_Mem => OpCode_Mem,
        OpCode_Wb => OpCode_Wb,
        ForwardA => ForwardA,
        ForwardB => ForwardB
    );

    EX_MEM_reg_Inst : EX_MEM_reg
    PORT MAP(
        Clk => Clk,
        Rst => Rst,
        Mem_Control_Sigs => MEM_CONTROL_FLUSH_MUX, -- theses are the output signals from the flush mux
        Wb_Control_Sigs => WB_CONTROL_FLUSH_MUX,-- theses are the output signals from the flush mux
        ALU_Result_In => ALU_Result_Sig,
        PC_inc => PC_inc,
        Flags => Flags_Reg_Out,
        ReadData1 => ReadData1,
        Rdst => Rdst,
        OpCode => OpCode,
        IN_Port => IN_Port,
        SP_inc_data => SP_inc_data_Sig,
        Mem_Control_Sigs_Out => Mem_Control_Sigs_Out,
        Wb_Control_Sigs_Out => Wb_Control_Sigs_Out,
        ALU_Result_Out => ALU_Result,
        PC_inc_Out => PC_inc_Out,
        Flags_Out => Flags_Out,
        ReadData1_Out => ReadData1_Out,
        Rdst_Out => Rdst_Out,
        OpCode_Out => OpCode_Out,
        IN_Port_Out => IN_Port_Out,
        SP_inc_data_Out => SP_inc_data_Out
    );

    SP_Inc_Block_Inst : SP_Inc_Block
    PORT MAP(
        Clk => Clk,
        Rst => Rst,
        SP_EN => SP_EN,
        SP_INC => SP_INC,
        SP_Write_Data => SP_Write_Data,
        SP_inc_data_Out => SP_inc_data_Sig
    );

    EX_FLUSH_MUX_Inst : EX_FLUSH_MUX
    PORT MAP(
        EX_MEM_FLUSH => Ex_Flush,
        MEM_SIGNALS_IN => Mem_Control_Sigs,
        WB_SIGNALS_IN => Wb_Control_Sigs,
        MEM_SIGNALS_OUT => MEM_CONTROL_FLUSH_MUX,
        WB_SIGNALS_OUT => WB_CONTROL_FLUSH_MUX
    );
END ARCHITECTURE;