library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instr_mem is
    Port (
        addr    : in  STD_LOGIC_VECTOR(31 downto 0);
        instr   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end instr_mem;

-- Note: the Real RISC-V uses the ADDI for the NOP instruction, but I'm pretending 0x0000000000000000 is a NOP
-- inserting NOPs to avoid hazards
architecture Behavioral of instr_mem is
    type memory_array is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    signal memory : memory_array := (
        0 => x"00900293", -- addi x5, x0, 9         000000001001 00000 000 00101 0010011
        
        1 => x"00000317",                  -- load_addr x6, array (custom instruction), where array is 0x10000000
        --2 => x"00000000", --- STALL
        --3 => x"00000000", --- STALL
        --4 => x"00000000", --- STALL
        2 => x"00032383", -- lw x7, 0(x6)           
        3 => x"00430313", -- loop: addi x6, x6, 4   
        --7 => x"00000000", -- STALL
        --8 => x"00000000", -- STALL
        --9 => x"00000000", -- STALL
        4 => x"00032503", -- lw x10, 0(x6)    
        --11 => x"00000000", -- STALL
        --12 => x"00000000", -- STALL
        --13 => x"00000000", -- STALL
        5 => x"007503B3", -- add x7, x10, x7
        6 => x"FFF28293",
        --6 => x"00129293", -- subi x5, x5, 1 (or addi x5, x5, -1)
        --16 => x"00000000", -- STALL
        --17 => x"00000000", -- STALL
        --18 => x"00000000", -- STALL
        7 => x"FA0298E3",
        --7 => x"F20290E3", --x"F80298E3", --  bne x5, x0, loop    -56   originl: -- x"F20290E3"
        --8 => x"00000000", -- STALL
        --9 => x"00000000", -- STALL
        --10 => x"00000000", -- STALL
        8 => x"FF9FF06F", -- done: j done [-4; note: assumes PC is already incremented by 4] -- original: x"FF9FF06F", new: x"FFDFF06F"
        others => (others => '0')
    );
begin
    process(addr)
    begin
        instr <= memory(to_integer(unsigned(addr(7 downto 0))));
    end process;
end Behavioral;
