----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:46:35 10/09/2018 
-- Design Name: 
-- Module Name:    sram_cnt - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sram_cnt is
		
		port(	
				clk			:	in		std_logic;
				reset			:	in		std_logic;
				mem			:	in		std_logic;
				rw				:	in		std_logic;
				addr				:	in 	std_logic_vector(17 downto 0);
				data_f2s		:	in		std_logic_vector(7 downto 0);
				ready			:	out	std_logic;
				data_s2f_r	:	out	std_logic_vector(7 downto 0);
				data_s2f_ur	:	out	std_logic_vector(7 downto 0);
				ad				:	out	std_logic_vector(17 downto 0);
				we_n			:	out 	std_logic;
				oe_n			:	out	std_logic;
				ce_n			:	out	std_logic;
				dio_a			:	inout	std_logic_vector(7 downto 0)
				);
	
end sram_cnt;

architecture Behavioral of sram_cnt is

	type state_type is (idle,wr1,wr2,rd1,rd2);
	signal state_next , state_reg : state_type;
	signal data_s2f_next 	: std_logic_vector(7 downto 0);
	signal data_f2s_next 	: std_logic_vector(7 downto 0);
	signal data_s2f_reg	 	: std_logic_vector(7 downto 0);
	signal data_f2s_reg		: std_logic_vector(7 downto 0);
	signal addr_reg			: std_logic_vector(17 downto 0);
	signal addr_next			: std_logic_vector(17 downto 0);
	signal we_buf				:std_logic;
	signal we_reg				:std_logic;
	signal tri_buf				:std_logic;
	signal tri_reg				:std_logic;
	signal oe_reg				:std_logic :='1';
	signal oe_buf				:std_logic :='1';
	
begin

	data_s2f_r		<=		data_s2f_reg;
	data_s2f_ur		<=		dio_a;
	
	we_n				<=		we_reg;
	oe_n				<=		oe_reg;
	ad					<=		addr_reg;
	
	ce_n				<=		'0';
	dio_a				<= 	data_f2s_reg when tri_reg = '0' else (others=>'Z');
	ready				<=		'1';
	
	process(clk , reset)
	begin
	
		if(reset = '1') then
			state_reg 		<= idle;
			addr_reg 		<= (others=>'0');
			data_s2f_reg	<=	(others=>'0');
			data_f2s_reg	<=	(others=>'0');
			tri_reg			<= '1';
			we_reg			<= '1';
			oe_reg			<= '1';
		elsif (clk'event and clk = '1') then
			state_reg		<= state_next;
			addr_reg			<= addr_next;
			data_f2s_reg	<= data_f2s_next;
			data_s2f_reg	<= data_s2f_next;
			tri_reg			<= tri_buf;
			we_reg			<= we_buf;
			oe_reg			<= oe_buf;
		end if;
	end process;
	
	
	process(state_reg,mem,rw,dio_a,addr,data_f2s,data_f2s_reg,data_s2f_reg,addr_reg)
	begin
		addr_next 		<= addr_reg;
		data_s2f_next	<= data_s2f_reg;
		data_f2s_next	<= data_f2s_reg;
		
		case state_reg is
			when idle =>
				if mem = '0' then
					state_next 	<= idle;
				else
					addr_next 	<= addr;
					if rw = '0' then     --write
						state_next		<= wr1;
						data_f2s_next	<= data_f2s;
					else
						state_next 		<= rd1;
					end if;
				end if;
			
			when wr1	=>
				state_next <= wr2;
			when wr2 =>
				state_next <= idle;
			when rd1 =>
				state_next <= rd2;
			when rd2 =>
				data_s2f_next 	<= dio_a;
				state_next 		<= idle;
			
		end case;
			
	end process;
	
	process(state_next)
	begin
	
	tri_buf 	<= '1';
	we_buf	<= '1';
	oe_buf	<= '1';
	
	case state_next is
		when idle =>
		
		when wr1 =>
			tri_buf 	<= '0';
			we_buf	<= '0';
			oe_buf	<= '1';
		when wr2 =>
			tri_buf <= '0';
		when rd1 =>
			oe_buf	<= '0';
			we_buf	<= '1';
		when rd2 =>
			oe_buf	<= '0';
		
	end case;
	
	end process;

end Behavioral;

