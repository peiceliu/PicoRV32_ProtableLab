module la_top (
    input                           clk                 ,
    input                           in_rst_n            ,
    input   [5:0]                   din                 ,
    input                           sample_run_in       ,
    output                          ddr_init_done       ,
    output                          ethernet_read_done  ,
    output                          dout_done           ,
    output                          ddrout_almost_full  ,
    output                          almost_empty        ,
    output                          led4                ,
    output                          led5                ,
    output                          led6                ,
           //hdmi + ADC部分
    output                          iic_tx_scl          ,
    inout                           iic_tx_sda          ,
    // output                          led_int             ,
    input  [11:0]                   ad_data_outa        ,
    input  [11:0]                   ad_data_outb        ,
    input                           OTRA                ,
    input                           OTRB                ,
    output                          clkA                ,//adc时钟 65m
    output                          clkB                ,//adc时钟 65m
   //hdmi_out 
    output                          rstn_out            ,
    output                          pix_clk             ,//pixclk                           
    output                          vs_out              , //列
    output                          hs_out              , //行
    output                          de_out              ,
    output     [7:0]                r_out               , 
    output     [7:0]                g_out               , 
    output     [7:0]                b_out               ,

    output                          mem_rst_n           ,
    output                          mem_ck              ,
    output                          mem_ck_n            ,
    output                          mem_cke             ,
    output                          mem_ras_n           ,
    output                          mem_cas_n           ,
    output                          mem_we_n            ,
    output                          mem_odt             ,
    output                          mem_cs_n            ,
    output  [14:0]                  mem_a               ,
    output  [2:0]                   mem_ba              ,
    inout   [3:0]                   mem_dqs             ,
    inout   [3:0]                   mem_dqs_n           ,
    inout   [31:0]                  mem_dq              ,
    output  [3:0]                   mem_dm              ,

    input                           rgmii_rxc           ,
    input                           rgmii_rx_ctl        ,
    input   [3:0]                   rgmii_rxd           ,
    output                          rgmii_txc           ,
    output                          rgmii_tx_ctl        ,
    output  [3:0]                   rgmii_txd           ,    

    input           uart_rx ,
    output          uart_tx ,
    input           irq_5   ,
    input           irq_6   ,
    input           irq_7
);


wire            rst_n               ;
wire            sample_run          ;
wire    [31:0]  sample_num          ;
wire    [3:0]   sample_clk_cfg      ;
wire    [1:0]   triger_type        ;
wire    [2:0]   trigger_channel     ;
wire            core_clk_125M       ;
wire            pll_lock1           ; 
wire            pll_lock2           ; 
wire            clkout0             ; 
wire            clkout1             ; 
wire            clkout2             ; 
wire            sample_run_risc     ;
wire            ad_clk              ;
wire            clk_fs              ;
wire            cfg_clk             ;
wire            pix_clk0            ;
 

wire   [11:0]    deci_rate_A         ;    
wire   [11:0]   trig_level_A        ;    
wire   [11:0]   trig_line_A         ;    
wire            trig_edge_A         ;    
wire            wave_run_A          ;    
wire   [9:0]    h_shift_A           ;    
wire   [9:0]    v_shift_A           ;    
wire   [4:0]    v_scale_A           ;    
wire            ad_outrange_A       ; 

wire   [11:0]    deci_rate_B         ;    
wire   [11:0]   trig_level_B        ;    
wire   [11:0]   trig_line_B         ;    
wire            trig_edge_B         ;    
wire            wave_run_B          ;    
wire   [9:0]    h_shift_B           ;    
wire   [9:0]    v_shift_B           ;    
wire   [4:0]    v_scale_B           ;    
wire            ad_outrange_B       ;    
wire   [2:0]    display_mode        ;    

wire            grid_change;

//DDS
wire [13:0]   vol_bias_B;                                 
wire [13:0]   vol_bias_A;                                                                                                                                     
wire [31:0]  div_fractor_A;                               
wire [31:0]  div_fractor_B;                               
wire [1:0]     dds_pwm_choose   ;                      
wire [7:0]     duty_cycle_A     ;                         
wire [7:0]     duty_cycle_B     ;                                                                                 
wire   [31:0]  dds_frequency_A  ;                         
wire   [13:0]     dds_phase_A   ;                                                  
wire   [4:0] dds_Amplitude_A    ;                         
wire   [2:0] dds_wave_type_A    ;                         
wire   [31:0] dds_frequency_B   ;                         
wire   [13:0] dds_phase_B       ;                         
wire   [4:0] dds_Amplitude_B    ;                                               
wire          dds_choose_en_A;//判断数据是本地还是上位机              
wire          dds_choose_en_B;                            
wire   [2:0]    dds_wave_type_B     ;                           

wire [31:0]pinlv_a;
wire [31:0]xiangwei_a;
wire [31:0]v_max_a;
wire [31:0]v_min_a;
wire [31:0]v_bias_a;
wire [31:0]pinlv_b;
wire [31:0]xiangwei_b;
wire [31:0]v_max_b;
wire [31:0]v_min_b;
wire [31:0]v_bias_b;





// wire grid_change;


picorv32_soc u_picorv32_soc(
    .clk_50M            (clk                )       ,
    .resetn             (rst_n              )       ,
    .uart_rx            (uart_rx            )       ,
//    .core_clk_125M      (clkout2            )       ,

    .uart_tx            (uart_tx            )       ,
    .led                (                   )       ,//用来指示uart接受到的数据
    .irq_5              (irq_5              )       ,
    .irq_6              (irq_6              )       ,
    .irq_7              (irq_7              )       ,
    //信号发生器  
    .dds_frequency_A    (dds_frequency_A    )       ,//波形频率
    .dds_phase_A        (dds_phase_A        )       ,//波形相位
    .dds_Amplitude_A    (dds_Amplitude_A    )       ,//波形幅度
    .dds_wave_type_A    (dds_wave_type_A    )       ,//波形类型
    .dds_choose_en_A(dds_choose_en_A),//上位机控制or本地按键控制
    .vol_bias_A(vol_bias_A),//电压偏置
    .duty_cycle_A(duty_cycle_A),//占空比
    .div_fractor_A(div_fractor_A),//分频系数
    
    .dds_frequency_B    (dds_frequency_B    )       ,//波形频率
    .dds_phase_B        (dds_phase_B        )       ,//波形相位
    .dds_Amplitude_B    (dds_Amplitude_B    )       ,//波形幅度
    .dds_wave_type_B    (dds_wave_type_B    )       ,//波形类型
    .dds_choose_en_B(dds_choose_en_B),//上位机控制or本地按键控制
    .vol_bias_B(vol_bias_B),//电压偏置
    .duty_cycle_B(duty_cycle_B),//占空比
    .div_fractor_B(div_fractor_B),//分频系数
    .dds_pwm_choose(dds_pwm_choose),
    .pinlv_a(pinlv_a),
    .xiangwei_a(xiangwei_a),
    .v_max_a(v_max_a),
    .v_min_a(v_min_a),
    .v_bias_a(v_bias_a),
    
    .pinlv_b(pinlv_b),
    .xiangwei_b(xiangwei_b),
    .v_max_b(v_max_b),
    .v_min_b(v_min_b),
    .v_bias_b(v_bias_b),

    .grid_change(grid_change),

    //示波器 
    .deci_rate_A        (deci_rate_A        )       ,//抽样率
    .trig_level_A       (trig_level_A       )       ,//触发电平
    .trig_line_A        (trig_line_A        )       ,//触发线位置
    .trig_edge_A        (trig_edge_A        )       ,//触发边沿
    .wave_run_A         (wave_run_A         )       ,//run or stop
    .h_shift_A          (h_shift_A          )       ,//水平偏移 bit[9]=0/1 左移/右移
    .v_shift_A          (v_shift_A          )       ,//垂直偏移 bit[9]=0/1 上移/下移
    .v_scale_A          (v_scale_A          )       ,//垂直缩放比例 bit[4]=0/1 缩小/放大
    .ad_outrange_A      (ad_outrange_A      )       ,//AD超范围

    .deci_rate_B        (deci_rate_B        )       ,//抽样率
    .trig_level_B       (trig_level_B       )       ,//触发电平
    .trig_line_B        (trig_line_B        )       ,//触发线位置
    .trig_edge_B        (trig_edge_B        )       ,//触发边沿
    .wave_run_B         (wave_run_B         )       ,//run or stop
    .h_shift_B          (h_shift_B          )       ,//水平偏移 bit[9]=0/1 左移/右移
    .v_shift_B          (v_shift_B          )       ,//垂直偏移 bit[9]=0/1 上移/下移
    .v_scale_B          (v_scale_B          )       ,//垂直缩放比例 bit[4]=0/1 缩小/放大
    .ad_outrange_B      (ad_outrange_B      )       ,//AD超范围
    .display_mode       (display_mode       )       ,//显示模式

    .sample_run         (sample_run_risc    )       ,//逻辑分析仪采样运行
    .sample_num         (sample_num         )       ,//逻辑分析仪采样深度
    .sample_clk_cfg     (sample_clk_cfg     )       ,//逻辑分析仪采样率配置
    .trigger_edge       (triger_type       )       ,//逻辑分析仪触发边沿配置
    .trigger_channel    (trigger_channel    )           //逻辑分析仪触发通道配置
);

la_net_top #(
    .MEM_DQ_WIDTH           (32                 )   ,
    .INPUT_WIDTH            (6                  )   ,
    .MEM_ROW_WIDTH          (15                 )   ,
    .MEM_BANK_WIDTH         (3                  )   ,
    .MEM_DQS_WIDTH          (4                  )   ,
    .MEM_DM_WIDTH           (4                  )          
) u_la_net_top (
    .clk                    (clk                )   ,
    .clkout1                (clkout1            )   , 
    .rst_n                  (rst_n              )   ,
    .sample_clk_cfg         (sample_clk_cfg     )   ,
    .sample_num             (sample_num         )   ,
    .triger_type           (triger_type       )   ,
    .trigger_channel        (trigger_channel    )   ,
    .sample_run             (sample_run         )   ,
    .din                    (din                )   ,  
    .ddr_init_done          (ddr_init_done      )   ,
    .ethernet_read_done     (ethernet_read_done )   ,
    .dout_done              (dout_done          )   ,
    .ddrout_almost_full     (ddrout_almost_full )   ,
    .almost_empty           (almost_empty       )   ,
    .led4                   (led4               )   ,
    .led5                   (led5               )   ,
    .led6                   (led6               )   ,
    .mem_rst_n              (mem_rst_n          )   ,
    .mem_ck                 (mem_ck             )   ,
    .mem_ck_n               (mem_ck_n           )   ,
    .mem_cke                (mem_cke            )   ,
    .mem_ras_n              (mem_ras_n          )   ,
    .mem_cas_n              (mem_cas_n          )   ,
    .mem_we_n               (mem_we_n           )   ,
    .mem_odt                (mem_odt            )   ,
    .mem_cs_n               (mem_cs_n           )   ,
    .mem_a                  (mem_a              )   ,
    .mem_ba                 (mem_ba             )   ,
    .mem_dqs                (mem_dqs            )   ,
    .mem_dqs_n              (mem_dqs_n          )   ,
    .mem_dq                 (mem_dq             )   ,
    .mem_dm                 (mem_dm             )   ,
    .rgmii_rxc              (rgmii_rxc          )   ,
    .rgmii_rx_ctl           (rgmii_rx_ctl       )   ,
    .rgmii_rxd              (rgmii_rxd          )   ,
    .rgmii_txc              (rgmii_txc          )   ,
    .rgmii_tx_ctl           (rgmii_tx_ctl       )   ,
    .rgmii_txd              (rgmii_txd          )      
);



shiboqiRSICV_top shiboqiRSICV_top_inst (
    .   sys_clk         (clk            ),  
    .   ad_clk          (ad_clk         ),
    .   cfg_clk         (cfg_clk        ),
    .   pix_clk0        (pix_clk0       ),
    .   clk_fs          (clk_fs         ),
    .   pll_lock        (pll_lock2       ),
    .   sys_rst_n       (rst_n          ),
    .   clkA            (clkA           )      ,//adc时钟 65m
    .   clkB            (clkB           )      ,//adc时钟 65m
    . iic_tx_scl        (iic_tx_scl     )    ,
    . iic_tx_sda        (iic_tx_sda     )    ,
    . led_int           (               )    ,
    . ad_data_outa      (ad_data_outa   )            ,
    . ad_data_outb      (ad_data_outb   )            ,
    . OTRA              (OTRA           )            ,
    . OTRB              (OTRB           )            ,
    .rstn_out           (rstn_out       )      ,
    .pix_clk            (pix_clk        )      ,//pixclk                           
    .vs_out             (vs_out         )      , //列
    .hs_out             (hs_out         )      , //行
    .de_out             (de_out         )      ,
    .r_out              (r_out          )      , 
    .g_out              (g_out          )      , 
    .b_out              (b_out          )      ,

 //示波器
    .deci_rate          (deci_rate_A   )              ,//抽样率
    .trig_level         (trig_level_A )              ,//触发电平
    .trig_line          (trig_line_A[8:0]  )              ,//触发线位置
    . trig_edge         (trig_edge_A)            ,//触发边沿
    . wave_run          (wave_run_A)            ,//run or stop
    . h_shift           ( h_shift_A),//水平偏移 bit[9]=0/1 左移/右移
    . v_shift           ( v_shift_A),//垂直偏移 bit[9]=0/1 上移/下移
    . v_scale           ( v_scale_A),//垂直缩放比例 bit[4]=0/1 缩小/放大
    .ad_outrange        (ad_outrange_A)           ,//AD超范围

    .grid_change        (grid_change ),

    .deci_rate_b        (deci_rate_B  )                ,//抽样率
    .trig_level_b       (trig_level_B )                ,//触发电平
    .trig_line_b        (trig_line_B[8:0]  )                ,//触发线位置
    .trig_edge_b        (trig_edge_B  )                ,//触发边沿
    .wave_run_b         (wave_run_B   )                ,//run or stop
    .h_shift_b          (h_shift_B    )                 ,//水平偏移 bit[9]=0/1 左移/右移
    .v_shift_b          (v_shift_B    )                 ,//垂直偏移 bit[9]=0/1 上移/下移
    .v_scale_b          (v_scale_B    )                 ,//垂直缩放比例 bit[4]=0/1 缩小/放大
    .ad_outrange_b      (ad_outrange_B )                ,//AD超范围
    .ch_choose          (display_mode )   ,              //显示模式
    .fft_boxing    (dds_wave_type_B[1:0]),
//dds
     .dds_pwm_choose  (  dds_pwm_choose  ),
     .duty_cycle_A    (  duty_cycle_A    ),
     .duty_cycle_B    (  duty_cycle_B    ),
     .dds_frequency_A (  dds_frequency_A ),
     .dds_phase_A  (     dds_phase_A  ),
     .dds_Amplitude_A (dds_Amplitude_A   ) , 
     .dds_wave_type_A (dds_wave_type_A   ) , 
     .dds_frequency_B ( dds_frequency_B  ) ,
     .dds_phase_B     ( dds_phase_B      ) ,
     .dds_choose_en_A(dds_choose_en_A),
     .dds_choose_en_B(dds_choose_en_B), 
     .dds_bias_A(vol_bias_A),
     .dds_bias_B(vol_bias_B), 
     .dds_Amplitude_B (dds_Amplitude_B   ) , 
     .dds_wave_type_B (dds_wave_type_B   ),

    //   .pinlv_a(32'd12345678),    
    //  .xiangwei_a(32'd0), 
    //  .v_max_a(32'd1000),    
    //  .v_min_a(32'd1000),    
    //  .v_bias_a(32'd60),  
    //  .pinlv_b(32'd23456),    
    //  .xiangwei_b(32'd0), 
    //  .v_max_b(32'd2000),    
    //  .v_min_b(32'd2000),    
    //  .v_bias_b(32'd0)
     .pinlv_a(pinlv_a),
     .xiangwei_a(xiangwei_a),
     .v_max_a(v_max_a),
     .v_min_a(v_min_a),
     .v_bias_a(v_bias_a),
     
     .pinlv_b(pinlv_b),
     .xiangwei_b(xiangwei_b),
     .v_max_b(v_max_b),
     .v_min_b(v_min_b),
     .v_bias_b(v_bias_b)
    );

pll_ip u_pll_ip (
  	.pll_rst    (~in_rst_n  ),      // input
  	.clkin1     (clk        ),        // input
  	.pll_lock   (pll_lock1  ),    // output
  	.clkout0    (clkout0    ),      // output  50
  	.clkout1    (clkout1    ),       // output  200
    .clkout2    (clkout2    )       // output  125
);

PLL_ad u_PLL_ad(
    .clkin1     (clk     ),
    .pll_rst    (~in_rst_n  ),
    .clkout0    (           ),
    .clkout1    (ad_clk     ),      //65
    .clkout2    (clk_fs     ),      //100
    .clkout3    (cfg_clk    ),      //10
    .clkout4    (pix_clk0   ),      //32
    .pll_lock   (pll_lock2  )
    );

assign rst_n = (pll_lock1 | pll_lock2) & in_rst_n;

assign sample_run = sample_run_risc | ~sample_run_in;

endmodule