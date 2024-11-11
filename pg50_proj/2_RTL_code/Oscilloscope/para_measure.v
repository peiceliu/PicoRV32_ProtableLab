module para_measure(
    input               clk ,       // 时钟     50M
    input               rst_n  ,    // 复位信号
    input  wire         clk_fs, //100M基准时钟
    /*input      [7:0]    trig_level, // 触发电平
    
    input               ad_clk,     // AD时钟
    input      [7:0]    ad_data,    // AD输入数据
    
    output              ad_pulse,   //pulse_gen模块输出的脉冲信号,仅用于调试
    
    output     [19:0]   ad_freq,    // 被测时钟频率输出
    output     [7:0]    ad_vpp,     // AD峰峰值 
    output     [7:0]    ad_max,     // AD最大值
    output     [7:0]    ad_min      // AD最小值
*/
    input      [11:0]    trig_level, // 触发电平
    
    input               ad_clk,     // AD时钟  暂定65M
    input      [11:0]    ad_data,    // AD输入数据
    
    output              ad_pulse,   //pulse_gen模块输出的脉冲信号,仅用于调试
    
    //output     [19:0]   ad_freq,    // 被测时钟频率输出
    //output     [11:0]    ad_vpp,     // AD峰峰值 
    output     [11:0]    ad_max,     // AD最大值
    output     [11:0]    ad_min,      // AD最小值
    output     [35:0]    bcd_data,    //所测频率值 经过BCD转化那些 
 
    input             ad_otr        ,  //0:在量程范围 1:超出量程
  //电压表
    output         data_symbol      ,//电压值符号位，负电压最高位显示负号,正电压显示空格
	output  [7:0]  data_percentiles ,//电压值小数点后第二位      
	output  [7:0]  data_decile      ,//电压值小数点后第一位     
	output  [7:0]  data_units       ,//电压值的个位数        
	output  [7:0]  data_tens       ,  //电压值的十位数    
  //vpp
    output  [7:0]  data_percentilesvpp ,//电压值小数点后第二位      
	output  [7:0]  data_decilevpp      ,//电压值小数点后第一位     
	output  [7:0]  data_unitsvpp       ,//电压值的个位数        
	output  [7:0]  data_tensvpp         //电压值的十位数  
);

//parameter define
//parameter CLK_FS = 26'd50_000_000;  // 基准时钟频率值  此处修改为100M 利用PLL来产生
//wire clk_fs; //100M基准时钟
//wire pll_lock;
//wire rst_n;
//wire ad_clk;//ad时钟 一般在顶层就一个时钟
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
    parameter       DIV_N        = 26'd10_000_000   ;   // 分频系数
   // parameter       CHAR_POS_X   = 11'd1            ,   // 字符区域起始点横坐标
  //  parameter       CHAR_POS_Y   = 11'd1            ,   // 字符区域起始点纵坐标
   // parameter       CHAR_WIDTH   = 11'd88           ,   // 字符区域宽度
   // parameter       CHAR_HEIGHT  = 11'd16           ,   // 字符区域高度
   // parameter       WHITE        = 24'hFFFFFF       ,   // 背景色，白色
   // parameter       BLACK        = 24'h0            ,   // 字符颜色，黑色
    parameter       CNT_GATE_MAX = 28'd75_000_000   ;   // 测频周期时间为1.5s  
    parameter       CNT_GATE_LOW = 28'd12_500_000   ;   // 闸门为低的时间0.25s
    parameter       CNT_TIME_MAX = 28'd80_000_000   ;   // 测频周期时间为1.6s
    parameter       CLK_FS_FREQ  = 28'd100_000_000  ;
    parameter       DATAWIDTH    = 8'd57            ;
    parameter       WIDTH        = 12               ;      //输入去测电压的ad_data位宽
//脉冲生成模块
pulse_gen u_pulse_gen_isnt(
    .rst_n          (rst_n),        //系统复位，低电平有效
    
    .trig_level     (trig_level),   // 触发电平
    .ad_clk         (ad_clk),       //AD9280驱动时钟
    .ad_data        (ad_data),      //AD输入数据

    .ad_pulse       (ad_pulse)      //输出的脉冲信号
    );

//等精度频率计模块

top_cymometer#(
    .   DIV_N(DIV_N )       ,   // 分频系数
  //  .   CHAR_POS_X(CHAR_POS_X)  ,   // 字符区域起始点横坐标
   // .   CHAR_POS_Y(CHAR_POS_Y)   ,   // 字符区域起始点纵坐标
   // .   CHAR_WIDTH(CHAR_WIDTH)   ,   // 字符区域宽度
  //  .   CHAR_HEIGHT(CHAR_HEIGHT)  ,   // 字符区域高度
    .   CNT_GATE_MAX(CNT_GATE_MAX) ,   // 测频周期时间为1.5s  
    .   CNT_GATE_LOW(CNT_GATE_LOW) ,   // 闸门为低的时间0.25s
    .   CNT_TIME_MAX(CNT_TIME_MAX) ,   // 测频周期时间为1.6s
    .   CLK_FS_FREQ(CLK_FS_FREQ)  ,
    .   DATAWIDTH(DATAWIDTH)   
)
top_cymometer_inst(
    . sys_clk(clk)      ,             // 时钟信号
    . sys_rst_n(rst_n)  ,             // 复位信号
    . clk_fx(ad_pulse)    ,             // 被测时钟
    . clk_fs(clk_fs)    ,
    . data_fx(data_fx)  
);

b2bcd_fre b2bcd_fre_inst(
    .sys_clk(clk),
    .sys_rst_n(rst_n),
    .data(data_fx),            //对应频率
    .bcd_data(bcd_data)       //9位十进制数的值  这个值就可以对应送到dispay模块去显示
);


//计算峰峰值
vpp_measure u_vpp_measure(
    .rst_n          (rst_n),
    
    .ad_clk         (ad_clk), 
    .ad_data        (ad_data),
    .ad_pulse       (ad_pulse),
    .ad_vpp         (ad_vpp),
    .ad_max         (ad_max),
    .ad_min         (ad_min)
    );

//对输入的电压数据进行处理并转换成实际的值给lcd显示
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
	.voc_finish       (voc_finish      ), //0v校准完成标志
    .voc_data         (voc_data        )    //校准后0v对应的ad数值
);
//0v电压校准
voltage_calibrator #(
	.WIDTH (WIDTH)
)
u_voltage_calibrator
(
	.clk              (ad_clk          ),
	.rst_n            (rst_n       ),		  
	.ad_data          (ad_data         ), 
    .voc_finish       (voc_finish      ), //0v校准完成标志
    .voc_data         (voc_data        )  //校准后0v对应的ad数值
);
//显示ad_vpp做准备
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
	.voc_finish       (voc_finish      ) //0v校准完成标志
);
endmodule 