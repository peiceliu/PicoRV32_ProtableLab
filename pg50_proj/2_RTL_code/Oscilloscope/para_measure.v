module para_measure(
    input               clk ,       // ʱ��     50M
    input               rst_n  ,    // ��λ�ź�
    input  wire         clk_fs, //100M��׼ʱ��
    /*input      [7:0]    trig_level, // ������ƽ
    
    input               ad_clk,     // ADʱ��
    input      [7:0]    ad_data,    // AD��������
    
    output              ad_pulse,   //pulse_genģ������������ź�,�����ڵ���
    
    output     [19:0]   ad_freq,    // ����ʱ��Ƶ�����
    output     [7:0]    ad_vpp,     // AD���ֵ 
    output     [7:0]    ad_max,     // AD���ֵ
    output     [7:0]    ad_min      // AD��Сֵ
*/
    input      [11:0]    trig_level, // ������ƽ
    
    input               ad_clk,     // ADʱ��  �ݶ�65M
    input      [11:0]    ad_data,    // AD��������
    
    output              ad_pulse,   //pulse_genģ������������ź�,�����ڵ���
    
    //output     [19:0]   ad_freq,    // ����ʱ��Ƶ�����
    //output     [11:0]    ad_vpp,     // AD���ֵ 
    output     [11:0]    ad_max,     // AD���ֵ
    output     [11:0]    ad_min,      // AD��Сֵ
    output     [35:0]    bcd_data,    //����Ƶ��ֵ ����BCDת����Щ 
 
    input             ad_otr        ,  //0:�����̷�Χ 1:��������
  //��ѹ��
    output         data_symbol      ,//��ѹֵ����λ������ѹ���λ��ʾ����,����ѹ��ʾ�ո�
	output  [7:0]  data_percentiles ,//��ѹֵС�����ڶ�λ      
	output  [7:0]  data_decile      ,//��ѹֵС������һλ     
	output  [7:0]  data_units       ,//��ѹֵ�ĸ�λ��        
	output  [7:0]  data_tens       ,  //��ѹֵ��ʮλ��    
  //vpp
    output  [7:0]  data_percentilesvpp ,//��ѹֵС�����ڶ�λ      
	output  [7:0]  data_decilevpp      ,//��ѹֵС������һλ     
	output  [7:0]  data_unitsvpp       ,//��ѹֵ�ĸ�λ��        
	output  [7:0]  data_tensvpp         //��ѹֵ��ʮλ��  
);

//parameter define
//parameter CLK_FS = 26'd50_000_000;  // ��׼ʱ��Ƶ��ֵ  �˴��޸�Ϊ100M ����PLL������
//wire clk_fs; //100M��׼ʱ��
//wire pll_lock;
//wire rst_n;
//wire ad_clk;//adʱ�� һ���ڶ����һ��ʱ��
wire [29:0] data_fx;

wire [11:0] voc_data;
wire       voc_finish;

wire [11:0]    ad_vpp;
/*pll_clk pll_clk_isnt (
  .pll_rst(~rst_n1),      // input
  .clkin1(clk),        // input
  .pll_lock(pll_lock),    // output
  .clkout0(ad_clk),      // output
  .clkout1(clk_fs)       // output
);
*/
//assign rst_n = pll_lock&rst_n1;
 //parameter define
    parameter       DIV_N        = 26'd10_000_000   ;   // ��Ƶϵ��
   // parameter       CHAR_POS_X   = 11'd1            ,   // �ַ�������ʼ�������
  //  parameter       CHAR_POS_Y   = 11'd1            ,   // �ַ�������ʼ��������
   // parameter       CHAR_WIDTH   = 11'd88           ,   // �ַ�������
   // parameter       CHAR_HEIGHT  = 11'd16           ,   // �ַ�����߶�
   // parameter       WHITE        = 24'hFFFFFF       ,   // ����ɫ����ɫ
   // parameter       BLACK        = 24'h0            ,   // �ַ���ɫ����ɫ
    parameter       CNT_GATE_MAX = 28'd75_000_000   ;   // ��Ƶ����ʱ��Ϊ1.5s  
    parameter       CNT_GATE_LOW = 28'd12_500_000   ;   // բ��Ϊ�͵�ʱ��0.25s
    parameter       CNT_TIME_MAX = 28'd80_000_000   ;   // ��Ƶ����ʱ��Ϊ1.6s
    parameter       CLK_FS_FREQ  = 28'd100_000_000  ;
    parameter       DATAWIDTH    = 8'd57            ;
    parameter       WIDTH        = 12               ;      //����ȥ���ѹ��ad_dataλ��
//��������ģ��
pulse_gen u_pulse_gen_isnt(
    .rst_n          (rst_n),        //ϵͳ��λ���͵�ƽ��Ч
    
    .trig_level     (trig_level),   // ������ƽ
    .ad_clk         (ad_clk),       //AD9280����ʱ��
    .ad_data        (ad_data),      //AD��������

    .ad_pulse       (ad_pulse)      //����������ź�
    );

//�Ⱦ���Ƶ�ʼ�ģ��

top_cymometer#(
    .   DIV_N(DIV_N )       ,   // ��Ƶϵ��
  //  .   CHAR_POS_X(CHAR_POS_X)  ,   // �ַ�������ʼ�������
   // .   CHAR_POS_Y(CHAR_POS_Y)   ,   // �ַ�������ʼ��������
   // .   CHAR_WIDTH(CHAR_WIDTH)   ,   // �ַ�������
  //  .   CHAR_HEIGHT(CHAR_HEIGHT)  ,   // �ַ�����߶�
    .   CNT_GATE_MAX(CNT_GATE_MAX) ,   // ��Ƶ����ʱ��Ϊ1.5s  
    .   CNT_GATE_LOW(CNT_GATE_LOW) ,   // բ��Ϊ�͵�ʱ��0.25s
    .   CNT_TIME_MAX(CNT_TIME_MAX) ,   // ��Ƶ����ʱ��Ϊ1.6s
    .   CLK_FS_FREQ(CLK_FS_FREQ)  ,
    .   DATAWIDTH(DATAWIDTH)   
)
top_cymometer_inst(
    . sys_clk(clk)      ,             // ʱ���ź�
    . sys_rst_n(rst_n)  ,             // ��λ�ź�
    . clk_fx(ad_pulse)    ,             // ����ʱ��
    . clk_fs(clk_fs)    ,
    . data_fx(data_fx)  
);

b2bcd_fre b2bcd_fre_inst(
    .sys_clk(clk),
    .sys_rst_n(rst_n),
    .data(data_fx),            //��ӦƵ��
    .bcd_data(bcd_data)       //9λʮ��������ֵ  ���ֵ�Ϳ��Զ�Ӧ�͵�dispayģ��ȥ��ʾ
);


//������ֵ
vpp_measure u_vpp_measure(
    .rst_n          (rst_n),
    
    .ad_clk         (ad_clk), 
    .ad_data        (ad_data),
    .ad_pulse       (ad_pulse),
    .ad_vpp         (ad_vpp),
    .ad_max         (ad_max),
    .ad_min         (ad_min)
    );

//������ĵ�ѹ���ݽ��д���ת����ʵ�ʵ�ֵ��lcd��ʾ
voltage_data #(
	.WIDTH (WIDTH)
) 
u_voltage_data
(
    .clk              (ad_clk          ),  
    .rst_n            (rst_n       ),  		     
    .ad_data          (ad_data         ),  
    .ad_otr           (ad_otr          ),  		     
    .data_tens        (data_tens       ),  
    .data_units       (data_units      ),  
    .data_decile      (data_decile     ),  
    .data_percentiles (data_percentiles),
    .data_symbol      (data_symbol     ),
	.voc_finish       (voc_finish      ), //0vУ׼��ɱ�־
    .voc_data         (voc_data        )    //У׼��0v��Ӧ��ad��ֵ
);
//0v��ѹУ׼
voltage_calibrator #(
	.WIDTH (WIDTH)
)
u_voltage_calibrator
(
	.clk              (ad_clk          ),
	.rst_n            (rst_n       ),		  
	.ad_data          (ad_data         ), 
    .voc_finish       (voc_finish      ), //0vУ׼��ɱ�־
    .voc_data         (voc_data        )  //У׼��0v��Ӧ��ad��ֵ
);
//��ʾad_vpp��׼��
voltage_vpp #(
	.WIDTH (WIDTH)
) 
u_voltage_vpp
(
    .clk              (ad_clk          ),  
    .rst_n            (rst_n       ),  		     
    .ad_vpp          (ad_vpp         ),  
    .ad_otr           (ad_otr          ),  		     
    .data_tens        (data_tensvpp       ),  
    .data_units       (data_unitsvpp      ),  
    .data_decile      (data_decilevpp     ),  
    .data_percentiles (data_percentilesvpp),
	.voc_finish       (voc_finish      ) //0vУ׼��ɱ�־
);
endmodule 