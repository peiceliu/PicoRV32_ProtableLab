

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:Meyesemi 
// Engineer: Will
// 
// Create Date: 2023-01-29 20:31  
// Design Name:  
// Module Name: 
// Project Name: 
// Target Devices: Pango
// Tool Versions: 
// Description: 
//      
// Dependencies: 
// 
// Revision:
// Revision 1.0 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//MS7200 和 MS7210 的 IIC 配置接口与 FPGA 的 IO 相连，通过 FPGA 的编程来对芯片进行初始化和配置操作。MES50HP 开发板上将 MS7200 的 SA 管脚下拉到地，故 IIC 的 ID 地址为 0x56，将 MS7210 的SA 管脚上拉到电源电压，故 IIC 的 ID 地址为 0xB2

`define UD #1

module hdmi_top(
    input wire        sys_clk       ,// input system clock 50MHz  
    input             locked        ,  
    output            rstn_out      ,
    output            iic_tx_scl    ,
    inout             iic_tx_sda    ,
    output            led_int       ,
    input             cfg_clk       ,// 10M 来顶层的PLL产生
    input             pix_clk0      ,// 800X480 设定位32m 直接assign 给pix_clk
//hdmi_out 
    output            pix_clk       ,//pixclk                           
    output  reg           vs_out        , //列
    output  reg          hs_out        , //行
    output  reg          de_out        ,
    output  reg   [7:0]  r_out         , 
    output  reg   [7:0]  g_out         , 
    output  reg   [7:0]  b_out         ,
//频谱仪
    input         [11:0] FREQ_ADJ ,
    output       out_vsync           ,
    output       wave_done           ,
    output       data_req            ,
    input   [35:0]    bcd_data_fft   ,
    input  [7:0]    fft_point_cnt        ,
    input    [11:0]  fft_data_out         ,
    output       fft_point_done       ,

 //电压表 要显示这些数据 是需要输入HDMI顶层的 来自于para_measure
    input         data_symbol      ,//电压值符号位，负电压最高位显示负号,正电压显示空格
	input  [7:0]  data_percentiles ,//电压值小数点后第二位      
	input  [7:0]  data_decile      ,//电压值小数点后第一位     
	input  [7:0]  data_units       ,//电压值的个位数        
	input  [7:0]  data_tens       ,  //电压值的十位数    
 //频率
    input [35:0]    bcd_data,    //所测频率值 经过BCD转化那些 
  //vpp
    input  [7:0]  data_percentilesvpp ,//电压值小数点后第二位      
	input  [7:0]  data_decilevpp      ,//电压值小数点后第一位     
	input  [7:0]  data_unitsvpp       ,//电压值的个位数        
	input  [7:0]  data_tensvpp        , //电压值的十位数  
 //显示和控制波形需要的端口
 //自己加的部分    还有就是参考历程是16位像素数据 与此处rgb888不同  这些端口添加是用于波形显示部分的代码  要去对应示波器上面的那条路的整体模块包括采样存储读取
    input      [11:0]  wave_data,       //波形(AD数据)    上述诸多端口在存储触发部分出现 
input      [11:0]  wave_data_c,       //波形(AD数据)    上述诸多端口在存储触发部分出现 
input      [11:0]  wave_data_d,       //波形(AD数据)    上述诸多端口在存储触发部分出现 
    output     [9:0]  wave_addr_a,       // 显示点数，对应ram地址 之前ram是9位宽 需要修改  主要是看设计的横坐标像素个数
    input             outrange,           
    output            wave_data_req_a,   //请求波形（AD）数据
    output            wr_over_a,         //绘制波形完成
    input      [9:0]  v_shift,         //波形竖直偏移量，bit[9]=0/1:上移/下移 
    input      [4:0]  v_scale,         //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
    input      [11:0] deci_rate,
    input      [2:0]  ch_choose,
    input      [9:0] h_shift,
    input             trig_edge,
    input      [11:0] trig_level,
    input             wave_run,
    input      [8:0]  trig_line,        //触发电平  这个是对应于像素纵坐标  此处最多480 暂时修改为9位宽

 //电压表 要显示这些数据 是需要输入HDMI顶层的 来自于para_measure
    input         data_symbol_b      ,//电压值符号位，负电压最高位显示负号,正电压显示空格
	input  [7:0]  data_percentiles_b ,//电压值小数点后第二位      
	input  [7:0]  data_decile_b      ,//电压值小数点后第一位     
	input  [7:0]  data_units_b       ,//电压值的个位数        
	input  [7:0]  data_tens_b       ,  //电压值的十位数    
 //频率
    input [35:0]    bcd_data_b,    //所测频率值 经过BCD转化那些 
  //vpp
    input  [7:0]  data_percentilesvpp_b ,//电压值小数点后第二位      
	input  [7:0]  data_decilevpp_b      ,//电压值小数点后第一位     
	input  [7:0]  data_unitsvpp_b       ,//电压值的个位数        
	input  [7:0]  data_tensvpp_b        , //电压值的十位数  
 //显示和控制波形需要的端口
 //自己加的部分    还有就是参考历程是16位像素数据 与此处rgb888不同  这些端口添加是用于波形显示部分的代码  要去对应示波器上面的那条路的整体模块包括采样存储读取
    input      [11:0]  wave_data_b,       //波形(AD数据)    上述诸多端口在存储触发部分出现 
    output     [9:0]  wave_addr_b,       // 显示点数，对应ram地址 之前ram是9位宽 需要修改  主要是看设计的横坐标像素个数
    output     [9:0]  wave_addr_c,
    output     [9:0]  wave_addr_d    ,
    output            wave_data_req_d,
    output            wr_over_d      , 
    input             outrange_b,        
 input             outrange_c,   
 input             outrange_d,     
    output            wave_data_req_c,   //请求波形（AD）数据
    output            wr_over_c,         //绘制波形完成   
    output            wave_data_req_b,   //请求波形（AD）数据
    output            wr_over_b,         //绘制波形完成
    input      [9:0]  v_shift_b,         //波形竖直偏移量，bit[9]=0/1:上移/下移 
    input      [4:0]  v_scale_b,         //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
    input      [11:0] deci_rate_b,
    input      [9:0]  h_shift_b,
    input             trig_edge_b,
    input      [11:0] trig_level_b,
    input             wave_run_b,
    input      [8:0]  trig_line_b ,       //触发电平  这个是对应于像素纵坐标  此处最多480 暂时修改为9位宽
    input             grid_choose ,
//dds
    input           dds_choose_en_A,
    input           dds_choose_en_B,
    input      [1:0]     dds_pwm_choose  ,
    input      [7:0]     duty_cycle_A   , 
    input      [7:0]     duty_cycle_B    ,
    input      [31:0]  dds_frequency_A ,
    input      [13:0]     dds_phase_A  ,
    input      [4:0] dds_Amplitude_A   ,
    input      [2:0] dds_wave_type_A  , 
    input      [31:0] dds_frequency_B  ,
    input      [13:0] dds_phase_B    ,  
input   [13:0]   dds_bias_B,
input   [13:0]   dds_bias_A,
    input      [4:0] dds_Amplitude_B ,  
    input      [2:0] dds_wave_type_B  ,

input [31:0] pinlv_a,//频率
    input [31:0] xiangwei_a,//相位
    input [31:0] v_max_a,//幅度
    input [31:0] v_min_a,//幅度
    input [31:0] v_bias_a,//电压偏置

    input [31:0] pinlv_b,//频率    
    input [31:0] xiangwei_b,//相位
    input [31:0] v_max_b,//幅度
    input [31:0] v_min_b,//幅度
    input [31:0] v_bias_b//电压偏置 


);

//像素坐标
parameter   X_WIDTH = 4'd11;
parameter   Y_WIDTH = 4'd11;    

/*//MODE_1080p 对应的是现在我的电脑屏幕 后续根据购买屏幕修改
    parameter V_TOTAL = 12'd1125;
    parameter V_FP = 12'd4;
    parameter V_BP = 12'd36;
    parameter V_SYNC = 12'd5;
    parameter V_ACT = 12'd1080;
    parameter H_TOTAL = 12'd2200;
    parameter H_FP = 12'd88;
    parameter H_BP = 12'd148;
    parameter H_SYNC = 12'd44;
    parameter H_ACT = 12'd1920;
    parameter HV_OFFSET = 12'd0;
*/
// 7' 800*480   对应下面子模块的屏幕信息   时钟计算：1056x525x60刷新率=33264000 约33M 尽量设低一点点 此处打算设32M
parameter  H_SYNC   =  11'd128;    //行同步
parameter  H_BP   =  11'd88;     //行显示后沿
parameter  H_ACT   =  11'd800;    //行有效数据
parameter  H_FP  =  11'd40;     //行显示前沿
parameter  H_TOTAL  =  11'd1056;   //行扫描周期
   
parameter  V_SYNC   =  11'd2;      //场同步
parameter  V_BP    =  11'd33;     //场显示后沿
parameter  V_ACT   =  11'd480;    //场有效数据
parameter  V_FP  =  11'd10;     //场显示前沿
parameter  V_TOTAL =  11'd525;    //场扫描周期       
   
wire         vs_out_a   ; //列
wire         hs_out_a   ; //行
wire         de_out_a   ;
wire         vs_out_b   ; //列
wire         hs_out_b   ; //行
wire         de_out_b   ;
wire         vs_out_c   ;
wire         hs_out_c   ;
wire         de_out_c   ;
wire         vs_out_d   ;
wire         hs_out_d   ;
wire         de_out_d   ;
wire  [7:0]  r_out_a    ; 
wire  [7:0]  g_out_a    ; 
wire  [7:0]  b_out_a    ;
wire  [7:0]  r_out_b    ; 
wire  [7:0]  g_out_b    ; 
wire  [7:0]  b_out_b    ;
wire  [7:0]  r_out_c    ; 
wire  [7:0]  g_out_c    ; 
wire  [7:0]  b_out_c    ;
wire  [7:0]  r_out_d    ; 
wire  [7:0]  g_out_d    ; 
wire  [7:0]  b_out_d    ;

wire         vs_out_e   ;
wire         hs_out_e   ;
wire         de_out_e   ;
wire  [7:0]  r_out_e    ; 
wire  [7:0]  g_out_e    ; 
wire  [7:0]  b_out_e    ;

  
   // wire                        cfg_clk    ;
    //wire                        locked     ; pll IP核一般在顶层 
   // wire                        rstn       ;
    wire                        init_over  ;
    reg  [15:0]                 rstn_1ms   ;
    wire [X_WIDTH - 1'b1:0]     pixel_posx      ;
    wire [Y_WIDTH - 1'b1:0]     pixel_posy      ;    
    wire                        hs         ;
    wire                        vs         ;
    wire                        de         ;
    reg  [3:0]                  reset_delay_cnt;
    
    //wire rstn_out;
    assign pix_clk = pix_clk0;

    /*pll u_pll (
        .clkin1   (  sys_clk    ),//50MHz
        .clkout0  (  pix_clk    ),//148.5MHz
        .clkout1  (  cfg_clk    ),//10MHz
        .pll_lock (  locked     )
    );
   */
    ms72xx_ctl ms72xx_ctl(                //配置模块
        .clk         (  cfg_clk    ), //input       clk,
        .rst_n       (  rstn_out   ), //input       rstn,
                                
        .init_over   (  init_over  ), //output      init_over,
        .iic_tx_scl  (  iic_tx_scl ), //output      iic_scl,
        .iic_tx_sda  (  iic_tx_sda ), //inout       iic_sda
        .iic_scl     (  iic_scl    ), //output      iic_scl,
        .iic_sda     (  iic_sda    )  //inout       iic_sda
    );
   assign    led_int    =     init_over;//led_int 输出指示初始化过程是否已完成 (init_over)，这对于调试和监控系统状态非常有用
    
    always @(posedge cfg_clk)         //用一个计数器 (rstn_1ms) 实现复位逻辑，该计数器计数直到特定值（16'h2710，相当于1000毫秒）。这个计数器确保系统在经过定义的初始化时间后才会退出复位状态。
    begin
    	if(!locked)
    	    rstn_1ms <= 16'd0;
    	else
    	begin
    		if(rstn_1ms == 16'h2710)
    		    rstn_1ms <= rstn_1ms;
    		else
    		    rstn_1ms <= rstn_1ms + 1'b1;
    	end
    end
    
    assign rstn_out = (rstn_1ms == 16'h2710);


    sync_vg #(
        .X_BITS               (  X_WIDTH              ), 
        .Y_BITS               (  Y_WIDTH              ),
        .V_TOTAL              (  V_TOTAL              ),//                        
        .V_FP                 (  V_FP                 ),//                        
        .V_BP                 (  V_BP                 ),//                        
        .V_SYNC               (  V_SYNC               ),//                        
        .V_ACT                (  V_ACT                ),//                        
        .H_TOTAL              (  H_TOTAL              ),//                        
        .H_FP                 (  H_FP                 ),//                        
        .H_BP                 (  H_BP                 ),//                        
        .H_SYNC               (  H_SYNC               ),//                        
        .H_ACT                (  H_ACT                ) //                        
 
    ) sync_vg_isnt                                         
    (                                                 
        .clk                  (  pix_clk               ),//input                   clk,                                 
        .rstn                 (  rstn_out              ),//input                   rstn,                            
        .out_vsync            (  out_vsync            ),
        .vs_out               (  vs                   ),//output reg              vs_out,                                                                                                                                      
        .hs_out               (  hs                   ),//output reg              hs_out,            
        .de_out               (  de                   ),//output reg              de_out,             
        .x_act                (  pixel_posx           ),//output reg [X_BITS-1:0] x_out,             
        .y_act                (  pixel_posy           ) //output reg [Y_BITS:0]   y_out,             
    );
    
hdmia_topa  hdmia_topa_insta(
        . pix_clk    (pix_clk    )   ,//pixclk     
        . rstn_out   (rstn_out   )   ,
        . pixel_posx (pixel_posx )   ,
        . pixel_posy (pixel_posy )   ,
        .   vs_in    (  vs    )      ,
        .   hs_in    (  hs   )      ,
        .   de_in    (  de    )      ,             
        .  vs_out    ( vs_out_a   )    , //列
        .  hs_out    ( hs_out_a    )    , //行
        .  de_out    ( de_out_a   )    ,
        .  r_out     ( r_out_a     )    , 
        .  g_out     ( g_out_a     )    , 
        .  b_out     ( b_out_a     )    ,
        . data_symbol        (data_symbol        ) ,
        . data_percentiles   (data_percentiles   ) ,      
        . data_decile        (data_decile        ) ,     
        . data_units         (data_units         ) ,  
        . data_tens          (data_tens          ) ,     
        . bcd_data           (bcd_data           ) ,    
        . data_percentilesvpp(data_percentilesvpp) ,      
        . data_decilevpp     (data_decilevpp     ) ,     
        . data_unitsvpp      (data_unitsvpp      ) ,  
        . data_tensvpp       (data_tensvpp       ) , 
        .v_shift   (v_shift  ),         
        .h_shift   (h_shift  ), 
        .v_scale   (v_scale  ),         
        .trig_line (trig_line),       
        .grid_choose  (grid_choose), 
        . ch_choose     ( ch_choose   )      ,
        . deci_rate     ( deci_rate   )      , 
        . trig_level    ( trig_level  )      , 
        . trig_edge     ( trig_edge   )      ,  
        . wave_run      ( wave_run    )      ,  
        . wave_data     ( wave_data   )       ,       
        .wave_addr      (wave_addr_a    )        ,    
        .outrange       (outrange     )        ,           
        .wave_data_req  (wave_data_req_a)        ,  
        .wr_over        (wr_over_a      ) 
    );

hdmib_topbb  hdmib_topb_instb(
        . pix_clk    (pix_clk    )   ,//pixclk     
        . rstn_out   (rstn_out   )   ,
        . pixel_posx (pixel_posx )   ,
        . pixel_posy (pixel_posy )   ,
        .   vs_in    (  vs    )      ,
        .   hs_in    (  hs    )      ,
        .   de_in    (  de    )      ,             
        .  vs_out    ( vs_out_b    )    , //列
        .  hs_out    ( hs_out_b    )    , //行
        .  de_out    ( de_out_b    )    ,
        .  r_out     ( r_out_b     )    , 
        .  g_out     ( g_out_b     )    , 
        .  b_out     ( b_out_b     )    ,
        . data_symbol        (data_symbol_b        ) ,
        . data_percentiles   (data_percentiles_b   ) ,      
        . data_decile        (data_decile_b        ) ,     
        . data_units         (data_units_b         ) ,  
        . data_tens          (data_tens_b          ) ,     
        . bcd_data           (bcd_data_b           ) ,    
        . data_percentilesvpp(data_percentilesvpp_b) ,      
        . data_decilevpp     (data_decilevpp_b     ) ,     
        . data_unitsvpp      (data_unitsvpp_b      ) ,  
        . data_tensvpp       (data_tensvpp_b       ) , 
        .v_shift   (v_shift_b  ),         
        .h_shift   (h_shift_b  ), 
        .v_scale   (v_scale_b  ),         
        .trig_line (trig_line_b),     
        .grid_choose  (grid_choose),    
        . ch_choose     ( ch_choose   )      ,
        . deci_rate     ( deci_rate_b   )      , 
        . trig_level    ( trig_level_b  )      , 
        . trig_edge     ( trig_edge_b   )      ,  
        . wave_run      ( wave_run_b    )      ,  
        . wave_data     ( wave_data_b  )       ,       
        .wave_addr      (wave_addr_b    )        ,    
        .outrange       (outrange_b     )        ,           
        .wave_data_req  (wave_data_req_b)        ,  
        .wr_over        (wr_over_b      ) 

    );

hdmi_fft hdmi_fft_inst(
    . pix_clk  ( pix_clk )     ,
    . rstn_out ( rstn_out)     ,
    . vs_out   ( vs_out_d  )     , //列
    . hs_out   ( hs_out_d  )     , //行
    . de_out   ( de_out_d  )     ,
    .vs        (vs       )     ,
    .hs        (hs       )     ,
    .de        (de       )     ,
    .FREQ_ADJ  (FREQ_ADJ)      ,
    . r_out    ( r_out_d   )     , 
    . g_out    ( g_out_d   )     , 
    . b_out    ( b_out_d   )     ,
    . act_x    ( pixel_posx  )     ,
    . act_y    (pixel_posy   )     ,
    . wave_choose  ( 2'b00  )            ,//选择时域波形 先默认00
    . bcd_data     (bcd_data_fft     )            ,
    .wave_done     (wave_done     )            ,
    .data_req      (data_req      )            ,
    .fft_data      (fft_data_out      )            ,
    .fft_point_cnt (fft_point_cnt )            ,
    .fft_point_done(fft_point_done)
);

shuanglu_display shuanglu_display_isnt(
        . pix_clk    (pix_clk    )   ,//pixclk     
        . rstn_out   (rstn_out   )   ,
        . pixel_posx (pixel_posx )   ,
        . pixel_posy (pixel_posy )   ,
        .   vs_in    (  vs    )      ,
        .   hs_in    (  hs   )      ,
        .   de_in    (  de    )      ,             
        .  vs_out    ( vs_out_c   )    , //列
        .  hs_out    ( hs_out_c    )    , //行
        .  de_out    ( de_out_c   )    ,
        .  r_out     ( r_out_c     )    , 
        .  g_out     ( g_out_c     )    , 
        .  b_out     ( b_out_c     )    ,
   
        . data_symbol        (data_symbol        ) ,
        . data_percentiles   (data_percentiles   ) ,      
        . data_decile        (data_decile        ) ,     
        . data_units         (data_units         ) ,  
        . data_tens          (data_tens          ) ,     
        . data_symbol_b     (data_symbol_b      ) ,
        . data_percentiles_b(data_percentiles_b ) ,      
        . data_decile_b     (data_decile_b      ) ,     
        . data_units_b      (data_units_b       ) ,  
        . data_tens_b       (data_tens_b        ) ,  
        . bcd_data           (bcd_data           ) ,    
        . bcd_data_b           (bcd_data_b           ) ,   
        . data_percentilesvpp(data_percentilesvpp) ,      
        . data_decilevpp     (data_decilevpp     ) ,     
        . data_unitsvpp      (data_unitsvpp      ) ,  
        . data_tensvpp       (data_tensvpp       ) , 
        . data_percentilesvpp_b (data_percentilesvpp_b ) ,      
        . data_decilevpp_b      (data_decilevpp_b      ) ,     
        . data_unitsvpp_b       (data_unitsvpp_b       ) ,  
        . data_tensvpp_b        (data_tensvpp_b        ) , 
        .v_shift   (v_shift  ),         
        .h_shift   (h_shift  ), 
        .v_scale   (v_scale  ),         
        .trig_line (trig_line),        
        . ch_choose     ( ch_choose   )      ,
        . deci_rate     ( deci_rate   )      , 
        . trig_level    ( trig_level  )      , 
        . trig_edge     ( trig_edge   )      ,  
        . wave_run      ( wave_run    )      ,  
        . wave_data     ( wave_data_c   )       ,       
        .wave_addr      (wave_addr_c    )        ,    
        .outrange       (outrange_c     )        ,           
        .wave_data_req  (wave_data_req_c)        ,  
        .wr_over        (wr_over_c      )        ,

        .v_shift_b        (v_shift_b  ),         
        .h_shift_b        (h_shift_b  ), 
        .v_scale_b        (v_scale_b  ),         
        .trig_line_b      (trig_line_b),        
        . deci_rate_b     ( deci_rate_b   )      , 
        . trig_level_b    ( trig_level_b  )      , 
        . trig_edge_b     ( trig_edge_b   )      ,  
        . wave_run_b      ( wave_run_b    )      ,  
        . wave_data_b     ( wave_data_d  )       ,       
        .wave_addr_b      (wave_addr_d    )        ,    
        .outrange_b       (outrange_d     )        ,           
        .wave_data_req_b  (wave_data_req_d)        ,  
        .wr_over_b        (wr_over_d      ) 
    );

dds_display  dds_display_isnt(
    .pix_clk (pix_clk)      ,//pixclk     
    .rstn_out (rstn_out )     ,
    .pixel_xpos(pixel_posx),
    .pixel_ypos(pixel_posy),
    .vs_in  (vs  )      , 
    .hs_in  (hs  )      , 
    .de_in  (de  )      ,                      
    .vs_out (vs_out_e )      , //列
    .hs_out (hs_out_e )      , //行
    .de_out (de_out_e )      ,
    .r_out  (r_out_e  )      , 
    .g_out  (g_out_e  )      , 
    .b_out  (b_out_e  )      ,
         //DDS
    .dds_frequency_A (  dds_frequency_A ),
    .dds_phase_A     (     dds_phase_A  ),
    .dds_Amplitude_A (dds_Amplitude_A   ) , 
    .dds_frequency_B ( dds_frequency_B  ) ,
    .dds_phase_B     ( dds_phase_B      ) ,
    .dds_Amplitude_B (dds_Amplitude_B   ) , 
.dds_bias_B(dds_bias_B),
.dds_bias_A(dds_bias_A),
    .wave_choose(dds_wave_type_A )   ,
    .wave_choose_b(dds_wave_type_B)   ,
    .dds_choose({dds_choose_en_B,dds_choose_en_A})    ,
    .dds_pwm(dds_pwm_choose)       ,
    .duty_cycle_d0(duty_cycle_A ) ,
    .duty_cycle_d1(duty_cycle_B)  ,

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



always@(*) begin
        case(ch_choose)
    3'b001: begin
        vs_out = vs_out_a   ;
        hs_out = hs_out_a   ;
        de_out = de_out_a   ;          
        r_out  = r_out_a   ;
        g_out  = g_out_a   ;
        b_out  = b_out_a   ; 
    end
    3'b010: begin
        vs_out = vs_out_b   ;
        hs_out = hs_out_b   ;
        de_out = de_out_b   ;          
        r_out  = r_out_b   ;
        g_out  = g_out_b   ;
        b_out  = b_out_b   ; 
    end
    3'b011: begin
        vs_out = vs_out_c   ;
        hs_out = hs_out_c   ;
        de_out = de_out_c   ;          
        r_out  = r_out_c   ;
        g_out  = g_out_c   ;
        b_out  = b_out_c   ; 
    end   
    3'b000: begin
        vs_out = vs_out_d   ;
        hs_out = hs_out_d   ;
        de_out = de_out_d   ;          
        r_out  = r_out_d   ;
        g_out  = g_out_d   ;
        b_out  = b_out_d   ; 
    end     
   3'b100: begin
        vs_out = vs_out_e   ;
        hs_out = hs_out_e   ;
        de_out = de_out_e   ;          
        r_out  = r_out_e   ;
        g_out  = g_out_e   ;
        b_out  = b_out_e   ; 
    end     
    default :begin
        vs_out = vs_out_e   ;
        hs_out = hs_out_e   ;
        de_out = de_out_e   ;          
        r_out  = r_out_e   ;
        g_out  = g_out_e   ;
        b_out  = b_out_e   ; 
    end
endcase
 end 


endmodule




