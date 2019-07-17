--Author: Mehran Goli
--Version: 1.0
--Date: 17-8-2019
LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL,ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;


ENTITY AFP_testbench IS
END;
ARCHITECTURE my_test OF AFP_testbench IS
SIGNAL clk_tb :std_logic :='0';
SIGNAL x1_tb,x2_tb,y_tb    : std_logic_vector (31 DOWNTO 0) ;
BEGIN
AFP1:  ENTITY work. fp_adder PORT MAP(y_tb,x1_tb,x2_tb,clk_tb);
 clk_tb <= NOT (clk_tb) AFTER 5 ns; 
 x1_tb <= "00000000100100000000000000000000","00000000100000000000000000000000" AFTER 70 ns ;
 x2_tb <= "00000001100110000000000000000000","00000000100000000000000000000000" AFTER 70 ns;
END my_test;
