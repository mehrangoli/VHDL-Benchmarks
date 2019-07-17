--Author: Mehran Goli
--Version: 1.0
--Date: 17-8-2019
LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
USE work.to_std_pack.ALL; 

ENTITY fp_divide IS
            PORT (sum    : OUT std_logic_vector (63 DOWNTO 0);
		          a,b    : IN std_logic_vector (31 DOWNTO 0) ;
				  clk    : IN std_logic
				  );
END;
ARCHITECTURE my_fpdiv OF fp_divide IS
SIGNAL sum_temp :std_logic_vector (63 DOWNTO 0)  ;
SIGNAL a_int ,b_int : integer;
TYPE mystate IS (s0,s1,s2);
SIGNAL current_state,next_state :mystate := s0;
BEGIN
    seq:PROCESS(clk)
	BEGIN
	    IF clk'EVENT AND clk ='1' THEN
		    -- IF nrst = '0' THEN
        	    -- current_state <= s0 ;
		    -- ELSE
			current_state <= next_state;	
		END IF ;
	END PROCESS seq ;

	
    comb_div:PROCESS (a,b,current_state)
	VARIABLE b_var, a_var : std_logic_vector (22 DOWNTO 0);
	VARIABLE i : std_logic_vector (22 DOWNTO 0) := "00000000000000000010110";
    VARIABLE j : std_logic_vector (22 DOWNTO 0) :=(OTHERS => '0');
	BEGIN
	CASE current_state IS				
	    WHEN s0 =>  -----------------------------------------------------------------sub expo
			i:= "00000000000000000101101";
			j:=(OTHERS => '0');
			IF a'EVENT OR b'EVENT THEN
			    a_int <= conv_integer('1' & a(22 DOWNTO 1));
			    b_int <= conv_integer('1' & b(22 DOWNTO 1));
				sum_temp(62 DOWNTO 52) <= "000" &((a(30 DOWNTO 23) - b(30 DOWNTO 23)) + "01111111"); 
		        sum_temp(63)<= a(31) XOR b(31);
			    next_state <= s1 ;
			ELSE
			    next_state <= s0 ;
			END IF;	
		WHEN s1 =>    -------------------------------------------------------------- divide mantisa
		    a_var:= to_stdlogic(a_int / b_int);
		    b_var:= to_stdlogic(a_int MOD b_int);
			sum_temp (51 DOWNTO 0)<= "000000" &(a_var & b_var) ;
            next_state <= s2 ;			
		WHEN s2 =>	 ----------------------------------------------------------------normalize  
            IF 	sum_temp(51 DOWNTO 0) = 0 THEN 
                sum_temp(51 DOWNTO 0) <= sum_temp(50 DOWNTO 0) & '1';
                i:= (OTHERS => '0');	
			ELSIF sum_temp (45)= '1' THEN
                sum_temp(51 DOWNTO 0) <= sum_temp(44 DOWNTO 0) & "0000000";
                sum_temp (62 DOWNTO 52) <= sum_temp (62 DOWNTO 52) - "00000000111";	
            ELSE
                WHILE (sum_temp(conv_integer(i)) /= '1') AND (i > 0) LOOP
				    i := i -'1' ;
				END LOOP;	
				IF i/= 0 THEN
					j := "00000000000000000101110" - i;
					sum_temp(51 DOWNTO (conv_integer(j))) <= sum_temp((51- conv_integer(j)) DOWNTO 0);
					sum_temp((conv_integer(j)-1) DOWNTO 0) <= (OTHERS => '0');
					sum_temp (62 DOWNTO 52) <= sum_temp (62 DOWNTO 52) - j(10 DOWNTO 0);						
				END IF;
            END IF; 				 
				next_state <= s0;				
        END CASE ;			
        sum <= sum_temp; 
	END PROCESS comb_div; 

END my_fpdiv;
