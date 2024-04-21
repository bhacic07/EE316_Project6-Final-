LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ps2_keyboard_tb IS
END ps2_keyboard_tb;

ARCHITECTURE behavior OF ps2_keyboard_tb IS

  -- Component declaration for the DUT (Design Under Test)
  COMPONENT ps2_keyboard
    PORT(
      clk          : IN  STD_LOGIC;
      ps2_clk      : IN  STD_LOGIC;
      ps2_data     : IN  STD_LOGIC;
      ps2_code_new : OUT STD_LOGIC
    );
  END COMPONENT;

  -- Constants
  CONSTANT c_SIM_TIME : TIME := 3000 ms; -- Simulation time in milliseconds

  -- Signals
  SIGNAL s_clk          : STD_LOGIC := '0';
  SIGNAL s_ps2_clk      : STD_LOGIC := '0';
  SIGNAL s_ps2_data     : STD_LOGIC := '0';
  SIGNAL s_ps2_code_new : STD_LOGIC := '0';

BEGIN

  -- Instantiate the DUT
  dut : ps2_keyboard
    PORT MAP(
      clk          => s_clk,
      ps2_clk      => s_ps2_clk,
      ps2_data     => s_ps2_data,
      ps2_code_new => s_ps2_code_new
    );

  -- Clock process
  clk_process: PROCESS
  BEGIN
    WHILE NOW < c_SIM_TIME LOOP
      s_clk <= NOT s_clk;
      WAIT FOR 10 ns; -- Adjust this for your specific clock period
    END LOOP;
    WAIT;
  END PROCESS;

  -- Stimulus process
  stimulus_process: PROCESS
  BEGIN
    -- Transition PS/2 data from '1' to '0' and then back to '1'
    s_ps2_data <= '1';
    s_ps2_clk <= '0'; -- Start with ps2_clk low
    WAIT FOR 5 ns;
    s_ps2_clk <= '1'; -- Toggle ps2_clk
    WAIT FOR 5 ns;
    s_ps2_data <= '0';
    s_ps2_clk <= '0';
    WAIT FOR 5 ns;
    s_ps2_clk <= '1';
    WAIT FOR 5 ns;
    s_ps2_data <= '1';
    s_ps2_clk <= '0';
    WAIT FOR 5 ns;
    s_ps2_clk <= '1';
    WAIT FOR 5 ns;
    WAIT;
  END PROCESS;

  -- Process to set ps2_code_new signal
  ps2_code_new_process: PROCESS
  BEGIN
    WAIT UNTIL falling_edge(s_ps2_data); -- Wait for falling edge of ps2_data
    s_ps2_code_new <= '1';  -- Set ps2_code_new to '1' when ps2_data transitions from '1' to '0'
    WAIT FOR 10 ns;         -- Hold ps2_code_new high for a short duration
    s_ps2_code_new <= '0';  -- Reset ps2_code_new to '0' after holding
    WAIT;
  END PROCESS;

END behavior;
