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
wire            pll_lock            ; 
wire            clkout0             ; 
wire            clkout1             ; 
wire            clkout2             ; 
wire            sample_run_risc     ;

picorv32_soc u_picorv32_soc(
    .clk_50M            (clk                )       ,
    .resetn             (rst_n              )       ,
    .uart_rx            (uart_rx            )       ,
    .core_clk_125M      (clkout2            )       ,

    .uart_tx            (uart_tx            )       ,
    .led                (                   )       ,//用来指示uart接受到的数据
    .irq_5              (irq_5              )       ,
    .irq_6              (irq_6              )       ,
    .irq_7              (irq_7              )       ,
    //信号发生器  
    .dds_frequency_A    (                   )       ,//波形频率
    .dds_phase_A        (                   )       ,//波形相位
    .dds_Amplitude_A    (                   )       ,//波形幅度
    .dds_wave_type_A    (                   )       ,//波形类型
    
    .dds_frequency_B    (                   )       ,//波形频率
    .dds_phase_B        (                   )       ,//波形相位
    .dds_Amplitude_B    (                   )       ,//波形幅度
    .dds_wave_type_B    (                   )       ,//波形类型
    //示波器 
    .deci_rate_A        (                   )       ,//抽样率
    .trig_level_A       (                   )       ,//触发电平
    .trig_line_A        (                   )       ,//触发线位置
    .trig_edge_A        (                   )       ,//触发边沿
    .wave_run_A         (                   )       ,//run or stop
    .h_shift_A          (                   )       ,//水平偏移 bit[9]=0/1 左移/右移
    .v_shift_A          (                   )       ,//垂直偏移 bit[9]=0/1 上移/下移
    .v_scale_A          (                   )       ,//垂直缩放比例 bit[4]=0/1 缩小/放大
    .ad_outrange_A      (                   )       ,//AD超范围

    .deci_rate_B        (                   )       ,//抽样率
    .trig_level_B       (                   )       ,//触发电平
    .trig_line_B        (                   )       ,//触发线位置
    .trig_edge_B        (                   )       ,//触发边沿
    .wave_run_B         (                   )       ,//run or stop
    .h_shift_B          (                   )       ,//水平偏移 bit[9]=0/1 左移/右移
    .v_shift_B          (                   )       ,//垂直偏移 bit[9]=0/1 上移/下移
    .v_scale_B          (                   )       ,//垂直缩放比例 bit[4]=0/1 缩小/放大
    .ad_outrange_B      (                   )       ,//AD超范围
    .display_mode       (                   )       ,//显示模式

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

pll_ip u_pll_ip (
  	.pll_rst    (~in_rst_n),      // input
  	.clkin1     (clk),        // input
  	.pll_lock   (pll_lock   ),    // output
  	.clkout0    (clkout0    ),      // output
  	.clkout1    (clkout1    ),       // output
    .clkout2    (clkout2    )       // output
);
assign rst_n = pll_lock & in_rst_n;

assign sample_run = sample_run_risc | ~sample_run_in;

endmodule