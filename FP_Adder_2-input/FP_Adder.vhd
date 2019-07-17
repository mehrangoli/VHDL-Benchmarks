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

ENTITY fp_adder IS
            PORT (sum    : OUT std_logic_vector (31 DOWNTO 0);
		          a,b    : IN std_logic_vector (31 DOWNTO 0) ;
				  clk    : IN std_logic
				  );
END;
ARCHITECTURE my_fpadd OF fp_adder IS
SIGNAL temp_diff :std_logic_vector (7 DOWNTO 0);
SIGNAL comp_flag,c_out,en,test:std_logic;
SIGNAL sum_temp :std_logic_vector (31 DOWNTO 0)  ;
SIGNAL i_sig : std_logic_vector (22 DOWNTO 0) := "00000000000000000010110";
TYPE mystate IS (s0,s1,s2,s3);
SIGNAL current_state,next_state :mystate := s0;
BEGIN
    diff_1: ENTITY work.expdiff PORT MAP(comp_flag,temp_diff,a(30 DOWNTO 23),b(30 DOWNTO 23),en);

    seq:PROCESS(clk)
	BEGIN
	    IF clk'EVENT AND clk ='1' THEN
		    -- IF nrst = '0' THEN
        	    -- current_state <= s0 ;
		    -- ELSE
			current_state <= next_state;	
		END IF ;
	END PROCESS seq ;

	
    comb_add:PROCESS (a,b,current_state)
	VARIABLE b_var, a_var : std_logic_vector (22 DOWNTO 0);
	VARIABLE i : std_logic_vector (22 DOWNTO 0) := "00000000000000000010110";
    VARIABLE j : std_logic_vector (22 DOWNTO 0) :=(OTHERS => '0');
	BEGIN
	CASE current_state IS				
	    WHEN s0 =>  --shift expo
            en <='1';
			i:= "00000000000000000010110";
			j:=(OTHERS => '0');
			IF a'EVENT OR b'EVENT THEN
			    next_state <= s1 ;
			ELSE
			    next_state <= s0 ;
			END IF;	
		WHEN s1 => 
			IF (comp_flag = '1') AND (temp_diff /= "00000000") THEN
				b_var := ('1' & b_var(22 DOWNTO 1));
				b_var((22 - conv_integer (temp_diff))  DOWNTO 0 ) := b_var(22 DOWNTO conv_integer(temp_diff));
                b_var (22 DOWNTO (23 - conv_integer (temp_diff))) := (OTHERS => '0');				
		        sum_temp (30 DOWNTO 23) <= a(30 DOWNTO 23);
			ELSIF (comp_flag = '0') AND (temp_diff /= "00000000") THEN
				a_var := ('1' & b_var(22 DOWNTO 1));
				a_var((22 - conv_integer (temp_diff))  DOWNTO 0 ) := a_var(22 DOWNTO conv_integer(temp_diff));
                a_var (22 DOWNTO (23 - conv_integer (temp_diff))) := (OTHERS => '0');
                sum_temp (30 DOWNTO 23) <= b(30 DOWNTO 23);	
              				
			END IF;
            next_state <= s2 ;	
            en <='0';			
		 WHEN s2 =>	   --- add mantis
		    en <='0';
		    IF a(31) = b (31) THEN
		        sum_temp (22 DOWNTO 0) <=  a(22 DOWNTO 0) + b(22 DOWNTO 0) ;
				sum_temp (31) <= a(31); 
			ELSIF a(31)='1' AND b(31)='0' THEN
			    IF a(22 DOWNTO 0) > b(22 DOWNTO 0) THEN
			        sum_temp (22 DOWNTO 0) <=  a(22 DOWNTO 0) - b(22 DOWNTO 0) ;
					sum_temp (31) <= a(31);
                ELSE
                    sum_temp (22 DOWNTO 0) <=  b(22 DOWNTO 0) - a(22 DOWNTO 0) ;
					sum_temp (31) <= b(31);			
                END IF; 					
			ELSIF a(31)='0' AND b(31)='1' THEN	
			    IF b(22 DOWNTO 0) > a(22 DOWNTO 0) THEN
			        sum_temp (22 DOWNTO 0) <=  b(22 DOWNTO 0) - a(22 DOWNTO 0) ;
					sum_temp (31) <= b(31);
                ELSE
                    sum_temp (22 DOWNTO 0) <=  a(22 DOWNTO 0) - b(22 DOWNTO 0) ;
					sum_temp (31) <= a(31);						
                END IF; 	
            END IF;
			-- IF sum_temp (22 DOWNTO 0) = 0 THEN
			-- END IF;	
            next_state <= s3;
		 WHEN s3 =>	 --normalize
		    en <='0';  
            IF 	sum_temp(22 DOWNTO 0) = 0 THEN 
                sum_temp(22 DOWNTO 0) <= sum_temp(21 DOWNTO 0) & '1';
                i:= (OTHERS => '0');	
			ELSIF sum_temp (22)= '1' THEN
                sum_temp(22 DOWNTO 0) <= sum_temp(21 DOWNTO 0) & '0';
                sum_temp (30 DOWNTO 23) <= sum_temp (30 DOWNTO 23) -'1';	
            ELSE
                WHILE (sum_temp(conv_integer(i)) /= '1') AND (i > 0) LOOP
				    i := i -'1' ;
				END LOOP;	
				IF i/= 0 THEN
					j := "00000000000000000010111" - i;
					sum_temp(22 DOWNTO (conv_integer(j))) <= sum_temp((22- conv_integer(j)) DOWNTO 0);
					sum_temp((conv_integer(j)-1) DOWNTO 0) <= (OTHERS => '0');
					sum_temp (30 DOWNTO 23) <= sum_temp (30 DOWNTO 23) - j(7 DOWNTO 0);						
				END IF;
            END IF; 				
			i_sig <= i; 
			--IF a'EVENT OR b'EVENT THEN
				next_state <= s0;
			--ELSE
                --next_state <= s3;			
			--END IF;	
        END CASE ;			
        sum <= sum_temp; 
	END PROCESS comb_add; 

END my_fpadd;
