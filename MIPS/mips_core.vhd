--Author: Mehran Goli
--Version: 1.0
--Date: 17-8-2019
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY mips_core IS
    PORT (  alu_result,regtomem  : OUT std_logic_vector(31 DOWNTO 0);
            reg_out      : OUT std_logic_vector(31 DOWNTO 0);
            pc_out       : OUT std_logic_vector(4  DOWNTO 0);
            mem_rw       : OUT std_logic;
            mem_data_out : IN  std_logic_vector(31 DOWNTO 0);
            instruction  : IN  std_logic_vector(31 DOWNTO 0);
            clk,nrst     : IN  std_logic
         );
END mips_core;

ARCHITECTURE behavioural OF mips_core IS
     
     SIGNAL sel,sel2,sel3,sel4,sel5       : std_logic;
     SIGNAL reg_write,clr_reg,zero        : std_logic;     
     SIGNAL Rs,Rt,Rd                      : std_logic_vector(4  DOWNTO 0);     
     SIGNAL alu_func                      : std_logic_vector(4  DOWNTO 0);
     SIGNAL pc,nxt_pc                     : std_logic_vector(31 DOWNTO 0); 
     SIGNAL address,branch_addr,jmp_addr  : std_logic_vector(31 DOWNTO 0);
     SIGNAL extend_imm                    : std_logic_vector(31 DOWNTO 0);
     SIGNAL Ra,Rb,Rc   : std_logic_vector(31 DOWNTO 0);
     SIGNAL reg_result,result             : std_logic_vector(31 DOWNTO 0);         
    -- SIGNAL Ra_fp,Rb_fp  : std_logic_vector(31 DOWNTO 0);         
     
     
BEGIN                                          
    regunit_ut : ENTITY work.reg_unit PORT MAP(Rs,Rt,Rd,reg_result,reg_write,clk,clr_reg,Ra,Rb);
    --fpdiv_ut : ENTITY work.fp_divide PORT MAP(Ra_fp,Rb_fp,reg_result,clk);
    --fpaddsub_ut : ENTITY work.fp_adder PORT MAP(reg_result,Ra_fp,Rb_fp,clk);
        
                           
        ------------------------------- PC -----------------------------------------------------
    
        seq : PROCESS (nrst, clk)
         BEGIN
             IF nrst = '0' THEN
                pc  <= (OTHERS => '0');
             ELSIF clk'EVENT AND clk='1' THEN
                 pc <= nxt_pc;
             END IF;    
         END PROCESS seq;
         
        comb : PROCESS (sel, pc, address)
         BEGIN
             IF sel = '1' THEN
                 nxt_pc <= pc + '1';
             ELSE  
                 nxt_pc <= address;
             END IF;
         END PROCESS comb;    
         
        ------------------------------ DECODER -------------------------------------------------
    
    
        controler_decoder: PROCESS (instruction)
        BEGIN                        
    
            Rs          <= instruction(25 DOWNTO 21);
            Rt          <= instruction(20 DOWNTO 16);
            Rd          <= instruction(15 DOWNTO 11);
            extend_imm  <= X"00000000";
            reg_write   <= '1';  
            mem_rw      <= '0';
            sel2        <= '0';
            sel3        <= '1';
            sel4        <= '0';
            sel5        <= '1';
            alu_func    <= "11111"; -- No function
            
        
            CASE instruction(31 DOWNTO 26) IS 
            
              WHEN "000000" => 
                      
                             CASE instruction(10 DOWNTO 0) IS    
                                
                                -- ADD
                                WHEN "00000100000" => alu_func <= "00000";
                        
                                -- ADDU
                                WHEN "00000100001" => alu_func <= "00000";
                                
                                -- SUB
                                WHEN "00000100010" => alu_func <= "00001";
                        
                                -- SUBU
                                WHEN "00000100011" => alu_func <= "00001";
                        
                                -- AND
                                WHEN "00000100100" => alu_func <= "00010"; 
                        
                                -- OR
                                WHEN "00000100101" => alu_func <= "00011";
                                
                                -- XOR
                                WHEN "00000100110" => alu_func <= "00100";
                                
                                -- SLT (set on less than) signed
                                WHEN "00000101010" => alu_func <= "00101";
                                
                                -- SLTU (set on less than) unsigned
                                WHEN "00000101011" => alu_func <= "00101";
                                
                                -- SRLV (shift right logical variable)
                                WHEN "00000000110" => alu_func <= "00110";
                                                      Rt <= instruction(25 DOWNTO 21);
                                                      Rs <= instruction(20 DOWNTO 16);                 
                                
                                -- SLLV (shift left logical variable)
                                WHEN "00000000100" => alu_func <= "00111";
                                                      Rt <= instruction(25 DOWNTO 21);
                                                      Rs <= instruction(20 DOWNTO 16);
                                
                                -- Jump register
                                WHEN "00000001000" => alu_func <= "01000";
                                                      reg_write <= '0';
                                                      sel4 <= '1';                                            
                                -- Noop
								WHEN "10000000000" =>  --- float point
                                WHEN "00000000000" => null;
                        
                                WHEN OTHERS =>  extend_imm  <=  X"00000" & '0' & instruction(10 DOWNTO 6) & "000000";
                                                Rs <= instruction(20 DOWNTO 16); 
                                                sel2 <= '1';
                                
                                                -- SLL (shift left logical)
                                                IF  instruction(5 DOWNTO 0)="000000" THEN      
                                                    alu_func <= "01011";
                                                    
                                                -- SRL (shift right logical)    
                                                ELSIF instruction(5 DOWNTO 0)="000010" THEN                                                           
                                                    alu_func <= "01100";
                                                      
                                                -- SRA (shift right arithmetic)
                                                ELSIF instruction(5 DOWNTO 0)="000011" THEN                                                            
                                                    alu_func <= "01101";
                                                                                                                                                   
                                                ELSE  
                                                    null;
                                                    
                                                END IF;    
                                                
                        
                             END CASE;
            
            
              -- ADDI 
              WHEN "001000" =>                    
                    Rs      <= instruction(25 DOWNTO 21);
                    Rd      <= instruction(20 DOWNTO 16);   
                    IF instruction(15) = '0' THEN 
                        extend_imm  <=  X"0000" & instruction(15 DOWNTO 0);
                    ELSE
                        extend_imm  <=  X"FFFF" & instruction(15 DOWNTO 0);
                    END IF;
                    alu_func    <= "00000";                                     
                    sel2        <= '1';

              -- ADDIU 
              WHEN "001001" =>                    
                    Rs      <= instruction(25 DOWNTO 21);
                    Rd      <= instruction(20 DOWNTO 16);
                    extend_imm  <=  X"0000" & instruction(15 DOWNTO 0);
                    alu_func    <= "00000";                                     
                    sel2        <= '1';           
            
              -- ANDI
              WHEN "001100" =>
                    Rs      <= instruction(25 DOWNTO 21);
                    Rd      <= instruction(20 DOWNTO 16);
                    extend_imm  <=  X"0000" & instruction(15 DOWNTO 0);           
                    alu_func    <= "00010";         
                    sel2        <= '1';       
            
              -- BEQ
              WHEN "000100" =>
                    Rs      <= instruction(25 DOWNTO 21);
                    Rt      <= instruction(20 DOWNTO 16);
                    extend_imm  <=  X"0000" & instruction(15 DOWNTO 0);           
                    reg_write   <= '0';
                    alu_func    <= "01001";
                    sel5        <= '0';
                    
              -- BNE
              WHEN "000101" =>
                    Rs      <= instruction(25 DOWNTO 21);
                    Rt      <= instruction(20 DOWNTO 16);
                    extend_imm  <=  X"0000" & instruction(15 DOWNTO 0);           
                    reg_write   <= '0';
                    alu_func    <= "01010"; 
                    sel5        <= '0';                   
                    
              -- Jump
              WHEN "000010" =>
                    extend_imm  <= "000000" & instruction(25 DOWNTO 0);           
                    reg_write   <= '0';
                    alu_func    <= "01000";  
                    
              -- Load byte
              WHEN "100000" =>
                    Rs          <= instruction(25 DOWNTO 21);
                    Rd          <= instruction(20 DOWNTO 16);  
                    extend_imm  <=  X"0000" & instruction(15 DOWNTO 0); 
                    sel2        <= '1';
                    alu_func    <= "00000";
                    mem_rw      <= '1';
                    sel3        <= '0';    
                    
              -- Load word
              WHEN "100011" =>
                    Rs          <= instruction(25 DOWNTO 21);
					Rt          <= "00001";
                    Rd          <= instruction(20 DOWNTO 16);  
                    extend_imm  <=  X"0000" & instruction(15 DOWNTO 0); 
                    sel2        <= '1';
                    alu_func    <= "00000";
                    mem_rw      <= '1';
                    sel3        <= '0';      
                    
              -- ORI 
              WHEN "001101" =>
                    Rs          <= instruction(25 DOWNTO 21);
                    Rd          <= instruction(20 DOWNTO 16);
                    extend_imm  <=  X"0000" & instruction(15 DOWNTO 0);           
                    reg_write   <= '1';
                    alu_func    <= "00011";         
                    sel2        <= '1';   

              -- Store byte
              WHEN "101000" =>
                    Rs          <= instruction(25 DOWNTO 21);
                    Rt          <= instruction(20 DOWNTO 16);
                    extend_imm  <=  X"0000" & instruction(15 DOWNTO 0); 
                    sel2        <= '1';
                    alu_func    <= "00000";
                    mem_rw      <= '0';
                               
              -- SLTI (set on less than immediate)-signed
              WHEN "001010" =>
                    Rs          <= instruction(25 DOWNTO 21);
                    Rd          <= instruction(20 DOWNTO 16);
                    IF instruction(15) = '0' THEN 
                        extend_imm  <=  X"0000" & instruction(15 DOWNTO 0);
                    ELSE
                        extend_imm  <=  X"FFFF" & instruction(15 DOWNTO 0);
                    END IF; 
                    sel2        <= '1';
                    alu_func    <= "00101";
                    
              -- SLTIU (set on less than immediate)-unsigned
              WHEN "001011" =>
                    Rs          <= instruction(25 DOWNTO 21);
                    Rd          <= instruction(20 DOWNTO 16);
                    extend_imm  <=  X"0000" & instruction(15 DOWNTO 0);
                    sel2        <= '1';
                    alu_func    <= "00101";          
            
              -- Store word
              WHEN "101011" =>
                    Rs          <= instruction(25 DOWNTO 21);
                    Rt          <= instruction(20 DOWNTO 16);
                    extend_imm  <=  X"0000" & instruction(15 DOWNTO 0); 
                    sel2        <= '1';
                    alu_func    <= "00000";
                    mem_rw      <= '0';       
                    
              -- XORI
              WHEN "001110" =>
                    Rs      <= instruction(25 DOWNTO 21);
                    Rd      <= instruction(20 DOWNTO 16);
                    extend_imm  <=  X"0000" & instruction(15 DOWNTO 0);           
                    reg_write   <= '1';
                    alu_func    <= "00100";         
                    sel2        <= '1';
     
            
              WHEN OTHERS => null;
              
            END CASE;                   
        END PROCESS controler_decoder;        
        
        -------------------------------------------- ALU --------------------------------------
        alu:PROCESS(Ra,Rc,alu_func)   
            VARIABLE result_var :std_logic_vector(31 DOWNTO 0);		
            BEGIN
                result <= (OTHERS => '0');
                sel    <= '1';
                CASE alu_func IS 
                    WHEN "00000" => result_var := Ra + Rc;              -- Handle overflow                           
                    WHEN "00001" => result_var := Ra - Rc;                          
                    WHEN "00010" => result_var := NOT(Ra AND Rc);
                    WHEN "00011" => result_var := (OTHERS => '0');--Ra OR Rc;
                    WHEN "00100" => result_var := Ra(30 DOWNTO 0) & '0';--Ra XOR Rc;
                    WHEN "00101" => result_var := '0' & Ra(31 DOWNTO 1);
                    WHEN "00110" => result_var := Ra OR Rc;
                    WHEN "00111" => result_var := Ra XOR Rc;
                    WHEN "01000" => sel <= '0';
                    WHEN "01001" =>
                                    IF Ra=Rc THEN
                                        sel <= '0';
                                    ELSE
                                        sel <= '1';
                                    END IF;     
                    WHEN "01010" =>
                                    IF Ra=Rc THEN
                                        sel <= '1';
                                    ELSE
                                        sel <= '0';
                                    END IF;         
                    --WHEN "01011" => 
				       -- Ra_fp <= Ra;
				       -- Rb_fp <= Rb;
                    --WHEN "01100" => 
                        --Radiv_fp <= Ra;				  
                        --Rbdiv_fp <= Rb;				  
--                  WHEN "01101" => result <= Ra >> conv_integer(Rc);   --   SRA  (arithmetic)                
                    WHEN OTHERS  => result_var := Ra;
                END CASE;  
                IF result_var = 0 THEN 
				    zero <= '1';
                ELSE		
                    zero <= '0';
                END IF;					
				result <= result_var;
            END PROCESS alu;            
            alu_result <= result;
            
        ----------------------------- branch address calculation -------------------------------
        
        branch_addr <= (pc + '1') + extend_imm;
            
        ---------------------------- MUXes for Rc and reg_result -------------------------------
        
        Rc          <= Rb          WHEN sel2='0' ELSE extend_imm;
        reg_result  <= result      WHEN sel3='1' ELSE mem_data_out;
        jmp_addr    <= extend_imm  WHEN sel4='0' ELSE Ra;
        address     <= branch_addr WHEN sel5='0' ELSE jmp_addr;
        
        ----------------------------------------------------------------------------------------
        regtomem <= reg_result;
        reg_out <= Rb;
        pc_out  <= pc(4 DOWNTO 0);
      
        
        
        

END behavioural;
