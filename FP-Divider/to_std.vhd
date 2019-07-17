--Author: Mehran Goli
--Version: 1.0
--Date: 17-8-2019
LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
-- USE ieee.math_real.ALL;
 USE ieee.std_logic_arith.ALL;
 PACKAGE to_std_pack IS
    FUNCTION to_stdlogic(input: IN integer) RETURN STD_LOGIC_VECTOR;
 END PACKAGE ;
 PACKAGE BODY to_std_pack IS
  
FUNCTION to_stdlogic(input: IN integer) RETURN STD_LOGIC_VECTOR IS
    VARIABLE array_temp:std_logic_vector(22 DOWNTO 0);
    VARIABLE in_temp ,i:integer :=0;
    BEGIN
	    i:= 0;
	    in_temp := input;
		array_temp := (OTHERS => '0');
	    WHILE (((in_temp) / 2) /= 1 ) AND i < 23 LOOP
		    IF in_temp MOD 2 = 1 THEN
		        array_temp(i) := '1';
			ELSE
                array_temp(i) := '0';
            END IF;				
			in_temp := (in_temp) / 2;
			i := i +1 ;
			IF ((in_temp) / 2) = 1 THEN 
			   array_temp(i) := '1'; 
			END IF;
		END LOOP;
		RETURN (array_temp);
	END to_stdlogic;
END PACKAGE BODY;	
