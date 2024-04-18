--testbench
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;

entity vga_sync_tb is
end vga_sync_tb;
-----------------------------------------------------
architecture behavior of vga_sync_tb is
-----------------------------------------------------
component vga_sync is
	PORT (
        clk, reset       : IN std_logic;
        I_CLK_50MHZ      : IN std_logic;
        bram_data_in     : IN std_logic_vector(31 downto 0);
        bram_addr_out     : OUT std_logic_vector(15 downto 0);
		hsync, vsync     : OUT std_logic;
        vga_r            : OUT std_logic_vector(3 downto 0);
        vga_g            : OUT std_logic_vector(3 downto 0);
        vga_b            : OUT std_logic_vector(3 downto 0)
	);
end component;
-----------------------------------------------------
signal clk, reset,I_CLK_50MHZ : std_logic:='0';
signal bram_data_in        : std_logic_vector(31 downto 0);
signal bram_addr_out       : std_logic_vector(15 downto 0);
signal hsync, vsync        : std_logic;
signal vga_r, vga_g, vga_b : std_logic_vector(3 downto 0);
--signal video_on            : std_logic;
-----------------------------------------------------
begin

DUT: vga_sync
port map(
		clk           =>clk,
		reset         =>reset,
		I_CLK_50MHZ   =>I_CLK_50MHZ,
		bram_data_in  => bram_data_in,
		bram_addr_out => bram_addr_out,
		hsync         =>hsync, 
		vsync         =>vsync,
        vga_r         =>vga_r,
        vga_g         =>vga_g,
        vga_b         =>vga_b
);
-----------------------------------------------------
clk <= not clk after 10 ns;
-----------------------------------------------------
process
	begin
reset <= '1';
wait for 10 us;

reset <= '0';
wait for 10us;

wait;
end process;
end behavior;