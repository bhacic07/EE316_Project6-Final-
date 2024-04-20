LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY vga_sync IS
	PORT (
		clk, reset       : IN std_logic;
        I_CLK_50MHZ      : IN std_logic;
        bram_data_in     : IN std_logic_vector(31 downto 0);
        bram_addr_out    : OUT std_logic_vector(15 downto 0):="0000";
		hsync, vsync     : OUT std_logic;
        vga_r            : OUT std_logic_vector(3 downto 0);
        vga_g            : OUT std_logic_vector(3 downto 0);
        vga_b            : OUT std_logic_vector(3 downto 0)
--		video_on         : OUT std_logic
--		p_tick           : OUT std_logic;
--		pixel_x, pixel_y : OUT std_logic_vector (9 DOWNTO 0)
	);
END vga_sync;

ARCHITECTURE arch OF vga_sync IS
	-- VGA 640-by-480 sync parameters
	CONSTANT HD : INTEGER := 640; --horizontal display area
	CONSTANT HF : INTEGER := 16; --h. front porch
	CONSTANT HR : INTEGER := 96; --h. retrace
	CONSTANT HB : INTEGER := 48; --h. back porch
	CONSTANT VD : INTEGER := 480; --vertical display area
	CONSTANT VF : INTEGER := 10; --v. front porch
	CONSTANT VR : INTEGER := 2; --v. retrace
	CONSTANT VB : INTEGER := 33; --v. back porch

	-- mod-2 counter
	SIGNAL mod2_reg, mod2_next : std_logic;

	-- sync counters
	SIGNAL v_count_reg, v_count_next : unsigned(9 DOWNTO 0);
	SIGNAL h_count_reg, h_count_next : unsigned(9 DOWNTO 0);

	-- output buffer
	SIGNAL v_sync_reg, h_sync_reg : std_logic;
	SIGNAL v_sync_next, h_sync_next : std_logic;

	-- status signal
	SIGNAL h_end, v_end, pixel_tick : std_logic;
	
	SIGNAL video_on : std_logic;
	signal pixel_x : std_logic_vector(9 DOWNTO 0);
    signal pixel_y : std_logic_vector(9 DOWNTO 0);
    signal Sig_bram_addr_out: std_logic_vector(9 downto 0);
    signal index :integer;
    signal sigR, sigB, sigG: std_logic_vector(3 downto 0);

BEGIN

	PROCESS (clk, reset)
BEGIN
	IF reset = '1' THEN
		mod2_reg <= '0';
		v_count_reg <= (OTHERS => '0');
		h_count_reg <= (OTHERS => '0');
		v_sync_reg <= '0';
		h_sync_reg <= '0';
	ELSIF (clk'EVENT AND clk = '1') THEN
		mod2_reg <= mod2_next;
		v_count_reg <= v_count_next;
		h_count_reg <= h_count_next;
		v_sync_reg <= v_sync_next;
		h_sync_reg <= h_sync_next;
	END IF;
END PROCESS;

-- mod-2 circuit to generate 25 MHz enable tick
mod2_next <= NOT mod2_reg;

-- 25 MHz pixel tick
pixel_tick <= '1' WHEN mod2_reg = '1' ELSE '0';

-- status
h_end <= -- end of horizontal counter
	'1' WHEN h_count_reg = (HD + HF + HR + HB - 1) ELSE --799
	'0';

	v_end <= -- end of vertical counter
		'1' WHEN v_count_reg = (VD + VF + VR + VB - 1) ELSE --524
		'0';

		-- mod-800 horizontal sync counter
		PROCESS (h_count_reg, h_end, pixel_tick)
	BEGIN
		IF pixel_tick = '1' THEN -- 25 MHz tick
			IF h_end = '1' THEN
				h_count_next <= (OTHERS => '0');
			ELSE
				h_count_next <= h_count_reg + 1;
			END IF;
		ELSE
			h_count_next <= h_count_reg;
		END IF;
	END PROCESS;

	-- mod-525 vertical sync counter
	PROCESS (v_count_reg, h_end, v_end, pixel_tick)
		BEGIN
			IF pixel_tick = '1' AND h_end = '1' THEN
				IF (v_end = '1') THEN
					v_count_next <= (OTHERS => '0');
				ELSE
					v_count_next <= v_count_reg + 1;
				END IF;
			ELSE
				v_count_next <= v_count_reg;
			END IF;
		END PROCESS;

		-- horizontal and vertical sync, buffered to avoid glitch
		h_sync_next <= 
			'0' WHEN (h_count_reg >= (HD + HF)) --656
			AND (h_count_reg <= (HD + HF + HR - 1)) ELSE --751
			'1';
			v_sync_next <= 
				'0' WHEN (v_count_reg >= (VD + VF)) --490
				AND (v_count_reg <= (VD + VF + VR - 1)) ELSE --491
				'1';
				-- video on/off
				video_on <= 
					'1' WHEN (h_count_reg < HD) AND (v_count_reg < VD) ELSE
					'0';

					-- output signal
					hsync <= h_sync_reg;
					vsync <= v_sync_reg;
					pixel_x <= std_logic_vector(h_count_reg);
					pixel_y <= std_logic_vector(v_count_reg);
					
					--BRAM ADDR LOGIC
					--calculate the address to access based on the pixel
					bram_addr_out <= std_logic_vector( to_unsigned( ((TO_INTEGER(unsigned(pixel_x))/8) + (TO_INTEGER(unsigned(pixel_y))) *80),Sig_bram_addr_out'length) );
					
					--BRAM DATA LOGIC
					--defines how to handle the bram data in
					index <= to_integer(unsigned(pixel_x)) mod 8;
					process(clk,reset) 
					   begin
					       if bram_data_in(index) = '1' then -- If text is received,
                               sigR <= (others=>'0'); --make it black
                               sigG <= (others=>'0'); --make it black
                               sigB <= (others=>'0'); --make it black
					       else if bram_data_in(index) = '0' then -- if no text is received, make the background
                               sigR <= (others=>'1'); --make it white
                               sigG <= (others=>'1'); --make it white
                               sigB <= (others=>'1'); --make it white
                           else
                           end if;
					--p_tick <= pixel_tick;
                           vga_r <= sigR when video_on = '1' ELSE "0000";
                           vga_g <= sigG when video_on = '1' ELSE "0000";
                           vga_b <= sigB when video_on = '1' ELSE "0000";
                    end process;
                           
END arch;