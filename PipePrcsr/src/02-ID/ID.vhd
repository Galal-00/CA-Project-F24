LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ID IS
    GENERIC (
        reg_addr_bits : INTEGER := 3;
        op_code_bits : INTEGER := 3;
        alu_op_bits : INTEGER := 2;
        reg_data_width : INTEGER := 8
    );
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;

        OP_CODE : IN STD_LOGIC_VECTOR(op_code_bits - 1 DOWNTO 0);
        Rs : IN STD_LOGIC_VECTOR(reg_addr_bits - 1 DOWNTO 0);
        Rt : IN STD_LOGIC_VECTOR(reg_addr_bits - 1 DOWNTO 0);
        Rd : IN STD_LOGIC_VECTOR(reg_addr_bits - 1 DOWNTO 0);

        -- coming from the write back stage
        WE_WB : IN STD_LOGIC;
        Wr_addr_WB : IN STD_LOGIC_VECTOR(reg_addr_bits - 1 DOWNTO 0);
        Wr_data_WB : IN STD_LOGIC_VECTOR(reg_data_width - 1 DOWNTO 0);
        ------------------------------

        OP_CODE_OUT : OUT STD_LOGIC_VECTOR(alu_op_bits - 1 DOWNTO 0);
        DATA1_OUT : OUT STD_LOGIC_VECTOR(reg_data_width - 1 DOWNTO 0);
        DATA2_OUT : OUT STD_LOGIC_VECTOR(reg_data_width - 1 DOWNTO 0);
        Wr_addr_OUT : OUT STD_LOGIC_VECTOR(reg_addr_bits - 1 DOWNTO 0);
        WE_OUT : OUT STD_LOGIC

    );
END ENTITY ID;

ARCHITECTURE ID_arch OF ID IS

    COMPONENT reg_file IS
        GENERIC (
            address_bits : INTEGER := 3;
            word_width : INTEGER := 8
        );
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            WE : IN STD_LOGIC;

            wr_address_bus : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
            wr_data_in : IN STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);

            rd_address_bus_1 : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
            rd_data_out_1 : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);

            rd_address_bus_2 : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
            rd_data_out_2 : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT CU IS
        GENERIC (
            word_width : INTEGER := 3
        );
        PORT (
            inst_data : IN STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);
            ALU_OP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            WE : OUT STD_LOGIC

        );
    END COMPONENT;
    COMPONENT D_EX_reg IS
        GENERIC (
            address_bits : INTEGER := 3;
            word_width : INTEGER := 8;
            op_code_bits : INTEGER := 2
        );
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            OP_CODE_IN : IN STD_LOGIC_VECTOR(op_code_bits - 1 DOWNTO 0);
            DATA1_IN : IN STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);
            DATA2_IN : IN STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);
            Wr_addr_IN : IN STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
            WE_IN : IN STD_LOGIC;
            OP_CODE_OUT : OUT STD_LOGIC_VECTOR(op_code_bits - 1 DOWNTO 0);
            DATA1_OUT : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);
            DATA2_OUT : OUT STD_LOGIC_VECTOR(word_width - 1 DOWNTO 0);
            Wr_addr_OUT : OUT STD_LOGIC_VECTOR(address_bits - 1 DOWNTO 0);
            WE_OUT : OUT STD_LOGIC

        );
    END COMPONENT;

    SIGNAL OP_CODE_D : STD_LOGIC_VECTOR(alu_op_bits - 1 DOWNTO 0);
    SIGNAL DATA1_D : STD_LOGIC_VECTOR(reg_data_width - 1 DOWNTO 0);
    SIGNAL DATA2_D : STD_LOGIC_VECTOR(reg_data_width - 1 DOWNTO 0);
    SIGNAL WE_D : STD_LOGIC;
BEGIN

    CU_inst : CU
    GENERIC MAP(
        word_width => op_code_bits
    )
    PORT MAP(
        inst_data => OP_CODE,
        ALU_OP => OP_CODE_D,
        WE => WE_D
    );

    reg_file_inst : reg_file
    GENERIC MAP(
        address_bits => reg_addr_bits,
        word_width => reg_data_width
    )
    PORT MAP(
        CLK => CLK,
        RST => RST,
        WE => WE_WB,
        wr_address_bus => Wr_addr_WB,
        wr_data_in => Wr_data_WB,
        rd_address_bus_1 => Rs,
        rd_data_out_1 => DATA1_D,
        rd_address_bus_2 => Rt,
        rd_data_out_2 => DATA2_D
    );

    D_EX_reg_inst : D_EX_reg
    GENERIC MAP(
        address_bits => reg_addr_bits,
        word_width => reg_data_width,
        op_code_bits => alu_op_bits
    )
    PORT MAP(
        CLK => CLK,
        RST => RST,
        OP_CODE_IN => OP_CODE_D,
        DATA1_IN => DATA1_D,
        DATA2_IN => DATA2_D,
        Wr_addr_IN => Rd,
        WE_IN => WE_D,
        OP_CODE_OUT => OP_CODE_OUT,
        DATA1_OUT => DATA1_OUT,
        DATA2_OUT => DATA2_OUT,
        Wr_addr_OUT => Wr_addr_OUT,
        WE_OUT => WE_OUT
    );
END ARCHITECTURE ID_arch;