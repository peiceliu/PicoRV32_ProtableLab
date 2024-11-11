module picorc32_dds_top(
        input               sys_clk0,  //50M ����PLL ��������ģ���ʱ��
        input               rst_n1,
//���
        input             uart_rx       ,
        output            uart_tx       ,
        input              irq_5        ,
        input              irq_6        ,
        input              irq_7        ,
 //DDS
	input					key0_in		,
	input					key1_in		,
	input					key2_in		,

	output	wire	      [13:0]  DataA	    ,
    output	wire	        CLKA	    ,
    output	wire	        WRTA	    ,
    output	wire	      [13:0]  DataB	    ,
    output	wire	        CLKB	    ,
    output	wire	        WRTB	    

   );

wire          dds_choose_en_A;//�ж������Ǳ��ػ�����λ��
wire          dds_choose_en_B;
//DDS
wire   [31:0] dds_frequency_A; 
wire   [13:0]     dds_phase_A; 
wire   [4:0] dds_Amplitude_A ; 
wire   [2:0] dds_wave_type_A ; 
wire   [31:0] dds_frequency_B; 
wire   [13:0] dds_phase_B    ; 
wire   [4:0] dds_Amplitude_B ; 
wire   [2:0] dds_wave_type_B ; //����FFT����ѡ�� FFTĿǰ�ߵ���ʾ����ͨ��b
//ʾ����
wire   [11:0]       deci_rate_A ; 
wire   [11:0]       trig_level_A; 
wire   [11:0]       trig_line_A ; 
wire                trig_edge_A; 
wire                wave_run_A ; 
wire   [9:0]        h_shift_A  ; 
wire   [9:0]        v_shift_A  ; 
wire   [4:0]        v_scale_A  ; 
wire                ad_outrange_A; 

wire   [11:0]       deci_rate_B ; 
wire   [11:0]       trig_level_B; 
wire   [11:0]       trig_line_B ; 
wire                trig_edge_B ; 
wire                wave_run_B  ; 
wire   [9:0]        h_shift_B   ; 
wire   [9:0]        v_shift_B   ; 
wire   [4:0]        v_scale_B   ; 
wire                ad_outrange_B; 
wire   [2:0]        display_mode; 

wire [13:0]   vol_bias_B;
wire [13:0]   vol_bias_A;

wire [1:0]  dds_pwm_choose;
wire [7:0]   duty_cycle_A ; 
wire [7:0]   duty_cycle_B ; 
wire [31:0]  div_fractor_A; 
wire [31:0]  div_fractor_B; 

wire            sample_run     ;//�߼������ǲ�������
wire     [31:0] sample_num     ;//�߼������ǲ������
wire     [3:0] sample_clk_cfg  ;//�߼������ǲ���������
wire     [1:0] trigger_edge    ;//�߼������Ǵ�����������
wire     [2:0] trigger_channel ;//�߼������Ǵ���ͨ������   


 wire pll_lock;
 wire clk_125m;
 wire sys_clk;
 wire sys_rst_n;
 assign sys_rst_n = pll_lock & rst_n1;


pll1 pll1_inst (
  .pll_rst(~rst_n1),      // input
  .clkin1(sys_clk0),        // input
  .pll_lock(pll_lock),    // output
  .clkout0(sys_clk),      // output
  .clkout1(clk_125m)       // output
);


picorc32_soc picorc32_soc_inst(
    .clk_50M(sys_clk),
    .resetn(sys_rst_n),
    .uart_rx(uart_rx),
    .core_clk_125M(sys_clk),
    .pll_lock(pll_lock),
    . uart_tx(uart_tx),
    . led(),//����ָʾuart���ܵ�������
    .irq_5(irq_5),
    .irq_6(irq_6),
    .irq_7(irq_7),
    // input rst_n,//��λ�ź�
    // input [7:0] parameter_id,//����ID
    // input [31:0] parameter_value,//����ֵ
    //�źŷ�����
    .dds_frequency_A  (dds_frequency_A)          ,//����Ƶ��
    .dds_phase_A      (dds_phase_A    )          ,//������λ
    .dds_Amplitude_A  (dds_Amplitude_A)          ,//���η���
    .dds_wave_type_A  (dds_wave_type_A)          ,//��������
    . dds_frequency_B ( dds_frequency_B )                         ,//����Ƶ��
    . dds_phase_B     ( dds_phase_B     )                         ,//������λ
    .dds_Amplitude_B  (dds_Amplitude_B  )                         ,//���η���
    .dds_wave_type_B  (dds_wave_type_B  )                         ,//��������

    .dds_choose_en_A(dds_choose_en_A),
    .vol_bias_A (vol_bias_A),
    .duty_cycle_A(duty_cycle_A),
    .div_fractor_A(div_fractor_A),

    .dds_choose_en_B(dds_choose_en_B),
    .vol_bias_B (vol_bias_B),
    .duty_cycle_B(duty_cycle_B),
    .div_fractor_B(div_fractor_B),
    .dds_pwm_choose(dds_pwm_choose),

    //ʾ����
    .deci_rate_A    (deci_rate_A   )              ,//������
    .trig_level_A   (trig_level_A )              ,//������ƽ
    .trig_line_A    (trig_line_A  )              ,//������λ��
    . trig_edge_A   (trig_edge_A)            ,//��������
    . wave_run_A    (wave_run_A)            ,//run or stop
    . h_shift_A     ( h_shift_A),//ˮƽƫ�� bit[9]=0/1 ����/����
    . v_shift_A     ( v_shift_A),//��ֱƫ�� bit[9]=0/1 ����/����
    . v_scale_A     ( v_scale_A),//��ֱ���ű��� bit[4]=0/1 ��С/�Ŵ�
    .ad_outrange_A  (ad_outrange_A)           ,//AD����Χ

    .deci_rate_B   (deci_rate_B  )                ,//������
    .trig_level_B  (trig_level_B )                ,//������ƽ
    .trig_line_B   (trig_line_B  )                ,//������λ��
    .trig_edge_B   (trig_edge_B  )                ,//��������
    .wave_run_B    (wave_run_B   )                ,//run or stop
    .h_shift_B     (h_shift_B    )                 ,//ˮƽƫ�� bit[9]=0/1 ����/����
    .v_shift_B     (v_shift_B    )                 ,//��ֱƫ�� bit[9]=0/1 ����/����
    .v_scale_B     (v_scale_B    )                 ,//��ֱ���ű��� bit[4]=0/1 ��С/�Ŵ�
    .ad_outrange_B  (ad_outrange_B )                ,//AD����Χ

    .display_mode  (display_mode )                , //��ʾģʽ
   //�߼�������
    .sample_run    (sample_run),
    .sample_num    (sample_num),
    .sample_clk_cfg (sample_clk_cfg ),
    .trigger_edge   (trigger_edge   ),
    .trigger_channel(trigger_channel) 
);


DDS_shuangtondao_top DDS_shuangtondao_top_inst(
	.clk(clk_125m)	 	,
	.rst_n	(sys_rst_n	)	    ,
	.key0_in(key0_in)		,
	.key1_in(key1_in)		,
	.key2_in(key2_in)		,
    .  f_word_A_reg    ( dds_frequency_A),
    . dds_phase_A_reg  (  dds_phase_A),
    .amplitude_A_reg  (dds_Amplitude_A ),
    . wave_A_reg      (dds_wave_type_A ),
    . f_word_B_reg   ( dds_frequency_B),
    . dds_phase_B_reg( dds_phase_B    ),
    .amplitude_B_reg (dds_Amplitude_B ),
    .wave_B_reg      (dds_wave_type_B ),
    .vol_bias_B_reg(vol_bias_B)            ,
    .vol_bias_A_reg(vol_bias_A)            ,
    .dds_choose_en_A_reg   (dds_choose_en_A)   ,
    . dds_choose_en_B_reg(dds_choose_en_B),      
    .dds_pwm_choose_reg  (dds_pwm_choose),
    .duty_cycle_A_reg    (duty_cycle_A  ),
    .duty_cycle_B_reg    (duty_cycle_B  ),
    . div_fractor_A_reg  (div_fractor_A ),
    . div_fractor_B_reg  (div_fractor_B ),
	. DataA	(DataA	)    ,
    . CLKA	(CLKA	)    ,
    . WRTA	(WRTA	)    ,
    . DataB	(DataB	)    ,
    . CLKB	(CLKB	)    ,
    . WRTB	(WRTB	)  
	);



endmodule