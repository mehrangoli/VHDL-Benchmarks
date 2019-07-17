--Author: Mehran Goli
--Version: 1.0
--Date: 17-8-2019
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mips_tb IS
END mips_tb;

ARCHITECTURE mips_test OF mips_tb IS

     ---------------------------- instantiation ( memories ) -----------------------------------
     
     COMPONENT instruction_memory 
            PORT(
                      addr         : IN  std_logic_vector(4  DOWNTO 0);
                      clk, nrst    : IN  std_logic;
                      instr        : OUT std_logic_vector(31 DOWNTO 0)
                );    
     END COMPONENT;
        
     COMPONENT data_memory 
            PORT (                 
                      address      : IN  std_logic_vector(4  DOWNTO 0);
                      data_in      : IN  std_logic_vector(31 DOWNTO 0);
                      mem_rw       : IN  std_logic;
                      clk, nrst    : IN  std_logic;       
                      data_out     : OUT std_logic_vector(31 DOWNTO 0)
                 );
     END COMPONENT;     
     
     COMPONENT mips_core
            PORT (  
                      alu_result,regtomem   : OUT std_logic_vector(31 DOWNTO 0);
                      reg_out      : OUT std_logic_vector(31 DOWNTO 0);
                      pc_out       : OUT std_logic_vector(4  DOWNTO 0);
                      mem_rw       : OUT std_logic;
                      mem_data_out : IN  std_logic_vector(31 DOWNTO 0);
                      instruction  : IN  std_logic_vector(31 DOWNTO 0);
                      clk,nrst     : IN  std_logic
         );   
     END COMPONENT;
     
     -------------------------------- signals declaration --------------------------------------
     
     SIGNAL alu_result_tb, mem_data_out_tb, instruction_tb, data_in_tb, regtomem_tb : std_logic_vector(31 DOWNTO 0);
     SIGNAL address_tb : std_logic_vector(4  DOWNTO 0);
     SIGNAL clk_tb : std_logic := '0' ;
     SIGNAL nrst_tb, mem_rw_tb : std_logic;
     
     
BEGIN                                              
    
     ----------------------------- port mapping for instances ----------------------------------
        
       core      :   mips_core        PORT MAP(
                                                alu_result   => alu_result_tb,
												regtomem     => regtomem_tb,
                                                reg_out      => data_in_tb,
                                                pc_out       => address_tb,
                                                mem_rw       => mem_rw_tb,
                                                mem_data_out => mem_data_out_tb,
                                                instruction  => instruction_tb,
                                                clk          => clk_tb,
                                                nrst         => nrst_tb
                                              );
       
       
       instr_mem : instruction_memory PORT MAP( 
                                                addr       => address_tb,
                                                clk        => clk_tb,
                                                nrst       => nrst_tb,
                                                instr      => instruction_tb 
                                               );
                                               
       data_mem  :    data_memory     PORT MAP(   
                                                address    => alu_result_tb(4 DOWNTO 0),
                                                data_in    => regtomem_tb,
                                                mem_rw     => mem_rw_tb,
                                                clk        => clk_tb,
                                                nrst       => nrst_tb,
                                                data_out   => mem_data_out_tb
                                             
                                              ); 
                                              
     --------------------------------- value assigning ----------------------------------------- 
     
        clk_tb      <=  NOT(clk_tb) AFTER 5  ns;
        nrst_tb     <= '0', '1'     AFTER 10 ns;
     -------------------------------------------------------------------------------------------
     
END mips_test;     
