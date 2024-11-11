module hdmi_fft(
    input             pix_clk       ,
    input             rstn_out      ,
    output            vs_out        , //列
    output            hs_out        , //行
    output            de_out        ,
    input            vs        ,
    input            hs        ,
    input            de        ,
    output     [7:0]  r_out         , 
    output     [7:0]  g_out         , 
    output     [7:0]  b_out         ,
    input      [10:0] act_x         ,
    input      [10:0] act_y         ,
    input      [1:0]       wave_choose   ,//选择时域波形 先默认00
    input      [35:0]      bcd_data,
    input      [11:0]      FREQ_ADJ ,
    output                wave_done,
    output                data_req,
    input     [11:0]      fft_data,
    input     [7:0]       fft_point_cnt,
    output                fft_point_done
);
    
wire back_en;
wire [23:0] pixel_data_back;
wire wave_en;
wire [23:0] pixel_data_wave;

back_fft_display back_fft_display_inst(                                  //显示字符和logo 目前打算添加背景网格+波形（由于这两部分可能出现叠加，所以要在一个模块并且需要判断优先级）
   .lcd_pclk(pix_clk),     //时钟
   .rst_n(rstn_out),        //复位，低电平有效             
   .pixel_xpos(act_x),     //当前像素点横坐标
   .pixel_ypos(act_y),     //当前像素点纵坐标  
   .wave_en(wave_en)   ,   //显示这些固定背景的使能 
   .wave_choose(wave_choose),
   .pixel_data_wave(pixel_data_wave),    //像素点数据,
   .back_en(back_en)   ,   //显示这些固定背景的使能 
   .pixel_data(pixel_data_back)    //像素点数据,
);     
wire fre_en;
wire [23:0] pixel_data_fre;
fre_fft_display fre_fft_display_isnt(
    .lcd_pclk(pix_clk)  ,               //驱动时钟
    .sys_rst_n(rstn_out) ,               //复位信号
	.data_d0(bcd_data)      ,
    .pixel_xpos(act_x),               //像素点横坐标   在例化时将低位宽的像素坐标拼接0即可满足该模块的位宽
    .pixel_ypos(act_y),               //像素点纵坐标
    .fre_en(fre_en),
    .pixel_data(pixel_data_fre)                //像素点数据
);
wire fre_eq_diven;
wire [23:0] pixel_data_div;
hdmi_fft_display hdmi_fft_display_isnt(
    .lcd_pclk(pix_clk),       //时钟
    .rst_n(rstn_out),          //复位，低电平有效
    .lcd_id(16'h7084),         //LCD屏ID    
    .pixel_xpos(act_x),     //当前像素点横坐标
    .pixel_ypos(act_y),     //当前像素点纵坐标  
    .h_disp(11'd800),         //LCD屏水平分辨率
    .v_disp(11'd480),         //LCD屏垂直分辨率   
    .wave_done(wave_done),
    // input video timing
    .vs_in                (  vs                   ),//input                         vn_in                        
    .hs_in                (  hs                   ),//input                         hn_in,                           
    .de_in                (  de                   ),//input                         dn_in,    
    .vs_out(vs_out), 
    .hs_out(hs_out), 
    .de_out(de_out),
    .r_out(r_out), 
    .g_out(g_out), 
    .b_out(b_out),
    .fre_eq_diven(fre_eq_diven),
    .pixel_data_div(pixel_data_div),                //像素点数据
    .fre_en(fre_en),
    .pixel_data_fre(pixel_data_fre),                //像素点数据
    .back_en(back_en)   ,   //显示这些固定背景的使能 
    .pixel_data_back(pixel_data_back),    //像素点数据,
    .wave_en(wave_en)   ,   //显示这些固定背景的使能 
    .pixel_data_wave(pixel_data_wave),    //像素点数据,
    .fft_point_cnt(fft_point_cnt),  //FFT频谱位置
    .fft_data(fft_data),       //FFT频率幅值  缩小16倍
    .fft_point_done(fft_point_done), //FFT当前频谱绘制完成
    .data_req(data_req)        //请求数据信号
    );

fft_div_adaptive fft_div_adaptive_inst (
   .lcd_pclk(pix_clk)  ,               //lcd驱动时钟
   .sys_rst_n(rstn_out) ,               //复位信号
	.data_d0(bcd_data) ,
   .pixel_xpos(act_x),               //像素点横坐标   在例化时将低位宽的像素坐标拼接0即可满足该模块的位宽
   .pixel_ypos(act_y),               //像素点纵坐标
   .freq_adj(FREQ_ADJ),
   .fre_eq_diven(fre_eq_diven),
   .pixel_data(pixel_data_div)                //像素点数据
   );
endmodule