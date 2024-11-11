module tb_pdds();


reg    sys_clk;
reg    rst_n;
reg     uart_rx ;
reg      irq_5  ;
reg      irq_6  ;
reg      irq_7  ;
reg            key0_in;	
reg            key1_in;	
reg            key2_in;
wire           uart_tx ;
wire   [13:0]  DataA;
wire     CLKA	    ;
wire     WRTA	    ;
wire   [13:0]  DataB;
wire     CLKB	    ;
wire     WRTB	    ; 
   
wire GRS_N;
GTP_GRS GRS_INST (

.GRS_N(1'b1)

);
initial
  begin 
uart_rx <= 1'b1;
sys_clk <= 1'b1;
rst_n   <= 1'b0;
irq_5   <= 1'b1;
irq_6   <= 1'b1;
irq_7   <= 1'b1;
key0_in <= 1'b1;
key1_in <= 1'b1;
key2_in <= 1'b1;
#200     
rst_n   <= 1'b1;  
key0_in <= 1'b0;
key1_in <= 1'b1;
key2_in <= 1'b1;

#300000000     
key0_in <= 1'b1;
key1_in <= 1'b1;
key2_in <= 1'b0;
#300000000        
key0_in <= 1'b1;
key1_in <= 1'b0;
key2_in <= 1'b1;

end
always# 10 sys_clk <= ~sys_clk;

 picorc32_dds_top   picorc32_dds_top_isnt(
                  . sys_clk0 (sys_clk )   ,  //50M 用于PLL 产生各个模块的时钟
                  . rst_n1   (rst_n)   ,
                  . uart_rx ( uart_rx )    ,
                  . uart_tx ( uart_tx )    ,
                  .  irq_5  (  irq_5  )    ,
                  .  irq_6  (  irq_6  )    ,
                  .  irq_7  (  irq_7  )    ,
                  . key0_in(key0_in),
                  . key1_in(key1_in),
                  . key2_in(key2_in),                   
                  . DataA(	DataA )   ,
                  . CLKA	  ( CLKA)	   ,
                  . WRTA	  ( WRTA)	   ,
                  . DataB     (	DataB )   ,
                  . CLKB	  ( CLKB)	   ,
                  . WRTB	  ( WRTB  )	     

   );



endmodule