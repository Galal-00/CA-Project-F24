-- Instruction Memory
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Instruction_Memory IS
  PORT (
    -- Address input for the instruction memory (16 bits) PC
    address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    -- Output data (32 bits = 16x2) for the instruction memory
    data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- Reset signal PC ← IM[0]
    reset : IN STD_LOGIC;
    -- Control signals --
    -- exeption signals -> IM[1] pop empty stack and IM[2] address exceeds 0x0FFF
    exp_sig : IN STD_LOGIC;
    exp_num : IN STD_LOGIC;
    -- Interrupt index is either 0 or 1 -> IM[3] or IM[4]
    int_sig : IN STD_LOGIC;
    int_index : IN STD_LOGIC
  );
END Instruction_Memory;

ARCHITECTURE Instruction_Memory_arch OF Instruction_Memory IS
  TYPE mem_type IS ARRAY (2 ** 12 - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL memory : mem_type := (
    -- Initialized to testcase 1
    0 => "0000001000000000",
    1 => "0000010000000000",
    2 => "0000011000000000",
    3 => "0000100000000000",
    4 => "0000101000000000",
    1024 => "0000000000000000",
    1025 => "0000100000000000",
    1536 => "0000000000000000",
    1537 => "0000100000000000",
    2048 => "0000000000000000",
    2049 => "1100000000000000",
    2560 => "0000000000000000",
    2561 => "1100000000000000",
    512 => "0011000000000000",
    513 => "0010000000000100",
    514 => "0001100100000100",
    515 => "0010100100000000",
    516 => "0101100000000000",
    517 => "0000000000010000",
    518 => "0100000000110000",
    519 => "0100100000110100",
    520 => "0101000000111000",
    521 => "0111000000001000",
    522 => "0000001100000000",
    523 => "0001000000000000",
    524 => "1001101000000000",
    525 => "0111000000001100",
    526 => "0000001000000000",
    527 => "1010001100000000",
    768 => "0111000000001100",
    769 => "0000001000000000",
    770 => "1001101100000000",
    771 => "0001000000000000",
    772 => "0011111000011100",
    773 => "0000000000000000",
    774 => "0000000000000000",
    775 => "0000000000000000",
    776 => "0000000000000000",
    777 => "1000101000000000",
    778 => "0000100000000000",
    OTHERS => (OTHERS => '0') -- All other positions are set to 0
  );
  SIGNAL data_out_sig : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
  -- Output data (32 bits = 16x2) for the instruction memory
  -- Reset signal PC ← IM[0]
  PROCESS (reset, address, exp_num, exp_sig, int_sig, int_index, memory)
  BEGIN
    IF reset = '1' THEN
      -- On reset, load the first instruction from memory
      -- lower 16 bits
      data_out_sig(15 DOWNTO 0) <= memory(0);
      -- upper 16 bits
      data_out_sig(31 DOWNTO 16) <= (OTHERS => '0');
    ELSIF exp_sig = '1' THEN
      -- Check for exceptions
      IF exp_num = '0' THEN
        -- lower 16 bits
        data_out_sig(15 DOWNTO 0) <= memory(1);
        -- upper 16 bits
        data_out_sig(31 DOWNTO 16) <= (OTHERS => '0');

      ELSE
        -- lower 16 bits
        data_out_sig(15 DOWNTO 0) <= memory(2);
        -- upper 16 bits
        data_out_sig(31 DOWNTO 16) <= (OTHERS => '0');
      END IF;
    ELSIF int_sig = '1' THEN
      -- Check for interrupts
      IF int_index = '0' THEN
        -- Check for interrupts
        -- lower 16 bits
        data_out_sig(15 DOWNTO 0) <= memory(3);
        -- upper 16 bits
        data_out_sig(31 DOWNTO 16) <= (OTHERS => '0');

      ELSE
        -- lower 16 bits
        data_out_sig(15 DOWNTO 0) <= memory(4);
        -- upper 16 bits
        data_out_sig(31 DOWNTO 16) <= (OTHERS => '0');
      END IF;
    ELSE
      -- Normal operation
      -- lower 16 bits
      data_out_sig(15 DOWNTO 0) <= memory(to_integer(unsigned(address(11 DOWNTO 0))));
      -- upper 16 bits
      data_out_sig(31 DOWNTO 16) <= memory(to_integer(unsigned(address(11 DOWNTO 0)) + 1));
    END IF;
  END PROCESS;

  data_out <= data_out_sig;

END ARCHITECTURE;