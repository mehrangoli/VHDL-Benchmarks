--Author: Mehran Goli
--Version: 1.0
--Date: 17-8-2019
LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL,ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY expdiff IS
            PORT (flag           : OUT std_logic;
			      diff           : OUT std_logic_vector (7 DOWNTO 0);
		          exp_a,exp_b    : IN std_logic_vector (7 DOWNTO 0);
				  en             : IN std_logic
				  );
END;
ARCHITECTURE my_diff OF expdiff IS
BEGIN
    comb_diff: PROCESS (exp_a,exp_b,en)
	BEGIN 
	    IF en = '1' THEN
			IF   exp_a > exp_b THEN
				diff <= exp_a - exp_b ;
				flag <= '1';
			ELSIF exp_a < exp_b THEN
				diff <= exp_b - exp_a ;
				flag <= '0';		
			ELSE 
				diff <= ("00000000");
			END IF ;
		-- ELSE
            -- diff <= (OTHERS => 'Z') ;
			-- flag <= 'Z';		
		END IF;	
	END PROCESS comb_diff; 

END my_diff;
