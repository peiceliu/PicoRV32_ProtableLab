module hdmia_topa(
    input            pix_clk       ,//pixclk     
    input            rstn_out      ,
    input [10:0]                   pixel_posx,
    input [10:0]                   pixel_posy,
    input                                vs_in, 
    input                                hs_in, 
    input                                de_in,                      
      output            vs_out        , //列
      output            hs_out        , //行
      output            de_out        ,
      output     [7:0]  r_out         , 
      output     [7:0]  g_out         , 
      output     [7:0]  b_out         ,
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

    input      [9:0]  v_shift,         //波形竖直偏移量，bit[9]=0/1:上移/下移 
    input      [9:0]  h_shift, 
    input      [4:0]  v_scale,         //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
    input      [8:0]  trig_line,        //触发线不同于触发电平  这个是对应于像素纵坐标  此处最多480 暂时修改为9位宽
     // 外部控制采样存储
     input                 grid_choose,
     input       [1:0]     ch_choose,
     input      [11:0]     deci_rate, 
     input      [11:0]    trig_level, // 触发电平 来源于data_store部分
     input               trig_edge,  // 触发边沿
     input               wave_run ,  // 波形采集启动/停止
//自己加的部分    还有就是参考历程是16位像素数据 与此处rgb888不同  这些端口添加是用于波形显示部分的代码  要去对应示波器上面的那条路的整体模块包括采样存储读取
    input      [11:0]  wave_data,       //波形(AD数据)    上述诸多端口在存储触发部分出现 
    output     [9:0]  wave_addr,       // 显示点数，对应ram地址 之前ram是9位宽 需要修改  主要是看设计的横坐标像素个数
    input             outrange,           
    output            wave_data_req,   //请求波形（AD）数据
    output            wr_over         //绘制波形完成
);
wire shuipincaiyang_en ;
wire chuizhifudu_en    ;
wire [23:0] pixel_data_caiyang ;       
wire [23:0] pixel_data_fudu  ;     

//显示频率板块
    wire fre_en;
    wire [23:0] pixel_data_fre;
    
    fre_display fre_display_isnt(
        .lcd_pclk(pix_clk)  ,               //驱动时钟
        .sys_rst_n(rstn_out) ,               //复位信号
        .data_d0(bcd_data)      ,
        .pixel_xpos(pixel_posx),               //像素点横坐标   在例化时将低位宽的像素坐标拼接0即可满足该模块的位宽
        .pixel_ypos(pixel_posy),               //像素点纵坐标
        .fre_en(fre_en),
        .pixel_data(pixel_data_fre)                //像素点数据
    );
    
    //显示电压板块
    wire v_en;
    wire [23:0] pixel_data_vol;
    voltage_display voltage_display_inst(
        .lcd_pclk(pix_clk)          ,
        .rst_n(rstn_out)              ,
        
        .data_symbol(data_symbol)        , //电压值符号位，负电压最高位显示负号 ,正值显示空格                 
        .data_percentiles(data_percentiles)   , //电压值小数点后第二位                                
        .data_decile(data_decile)  , //电压值小数点后第一位                                
        .data_units(data_units)   , //电压值的个位数                                   
        .data_tens(data_tens)    , //电压值的十位数  
        
        .data_percentilesvpp(data_percentilesvpp)   , //电压值小数点后第二位                                
        .data_decilevpp(data_decilevpp)       , //电压值小数点后第一位                                
        .data_unitsvpp(data_unitsvpp)         , //电压值的个位数                                   
        .data_tensvpp(data_tensvpp)          , //电压值的十位数  
                      
        .pixel_xpos(pixel_posx)         , //像素点横坐标
        .pixel_ypos(pixel_posy)         , //像素点纵坐标
        .v_en(v_en)               , //便于后面在顶层抉择优先级，显示电压
        .pixel_data(pixel_data_vol)           //像素点数据
    );
    //字符和logo
    wire back_en;
    wire [23:0] pixel_data_back;
    
    hdmi_display hdmi_display_isnt(                                  //显示字符和logo 目前打算添加背景网格+波形（由于这两部分可能出现叠加，所以要在一个模块并且需要判断优先级）
        . lcd_pclk(pix_clk),     //时钟
        . rst_n(rstn_out),        //复位，低电平有效               
        . pixel_xpos(pixel_posx),   //像素点横坐标
        . pixel_ypos(pixel_posy),   //像素点纵坐标 
        . back_en(back_en)   ,   //显示这些固定背景的使能 
        . pixel_data(pixel_data_back)    //像素点数据,
    );             
    wire shuipin_en;
    wire [23:0] pixel_data_shuipin;
    wire chuizhi_en;
    wire [23:0] pixel_data_chuizhi;
    fenbianlv_display fenbianlv_display_isnt(
        . lcd_pclk(pix_clk),     //时钟
        . sys_rst_n(rstn_out),        //复位，低电平有效
        . v_scale(v_scale),      //改变垂直
        . deci_rate(deci_rate),     //对应改变水平分辨率                    
        . pixel_xpos(pixel_posx),   //像素点横坐标
        . pixel_ypos(pixel_posy),   //像素点纵坐标 
        . shuipin_en(shuipin_en)   ,   //显示水平分辨率
        . chuizhi_en(chuizhi_en)   ,   //显示垂直分辨率
        . pixel_data(pixel_data_shuipin),    //像素点数据 水平
        . pixel_data1(pixel_data_chuizhi)    //像素点数据 垂直
    ); 
    
    //核心显示 波形显示控制+网格 +其他几个display模块的数据显示 有叠加的部分需要考虑优先级问题
    
    wire           run_en;
    wire           ch1_en;
    wire           ch2_en;
    wire           edge_en;
    wire           vshift_en;
    wire           hshift_en;
    wire    [23:0] pixel_data_run;
    wire    [23:0] pixel_data_ch1;
    wire    [23:0] pixel_data_ch2;
    wire    [23:0] pixel_data_edge;
    wire    [23:0] pixel_data_v;                  
    wire    [23:0] pixel_data_h;                //对应h_shift的移动显示
 wire   grid_en;         
 wire   zdcf_en;         
 wire    auto_en;         
 wire [23:0]   pixel_data_zdcf; 
 wire [23:0]   pixel_data_auto; 
 wire [23:0]   pixel_data_grid; 
    
    hexin_display hexin_display_inst(
        .rst_n(rstn_out), 
        .lcd_pclk(pix_clk),
        .pixel_xpos(pixel_posx),
        .pixel_ypos(pixel_posy),
        .vs_in(vs_in), 
        .hs_in(hs_in), 
        .de_in(de_in),
        
        //自己加的部分    还有就是参考历程是16位像素数据 与此处rgb888不同  这些端口添加是用于波形显示部分的代码 
        . wave_data(wave_data),       //波形(AD数据)    上述诸多端口在存储触发部分出现 
        . wave_addr(wave_addr),       // 显示点数，对应ram地址 之前ram是9位宽 需要修改  主要是看设计的横坐标像素个数
        . outrange(outrange),           
        . wave_data_req(wave_data_req),   //请求波形（AD）数据
        . wr_over(wr_over),         //绘制波形完成
        . v_shift(v_shift),         //波形竖直偏移量，bit[9]=0/1:上移/下移 
        . v_scale(v_scale),         //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
        . trig_line(trig_line),        //触发电平  这个是对应于像素纵坐标  此处最多480 暂时修改为9位宽
       
        //显示字符 logo  频率/vpp/电压
        .fre_en(fre_en) ,
        .pixel_data_fre(pixel_data_fre),
        .back_en(back_en),
        .pixel_data_back(pixel_data_back), 
        .v_en(v_en),
        .pixel_data_vol(pixel_data_vol),  
        . shuipin_en(shuipin_en)   ,   //显示水平分辨率
        . chuizhi_en(chuizhi_en)   ,   //显示垂直分辨率
        . pixel_data_shuipin(pixel_data_shuipin),    //像素点数据 水平
        . pixel_data_chuizhi(pixel_data_chuizhi),    //像素点数据 垂直
        .run_en         (run_en   )           ,
        .ch1_en         (ch1_en   )           ,
        .ch2_en         (ch2_en   )           ,
        .edge_en        (edge_en  )           ,
        .vshift_en      (vshift_en)           ,
        .hshift_en      (hshift_en)           ,
        .pixel_data_run (pixel_data_run )           ,
        .pixel_data_ch1 (pixel_data_ch1 )           ,
        .pixel_data_ch2 (pixel_data_ch2 )           ,
        .pixel_data_edge(pixel_data_edge)           ,
        .pixel_data_v   (pixel_data_v   )           ,                   
        .pixel_data_h     (pixel_data_h     )      ,     //对应h_shift的移动显示
        .grid_choose(grid_choose),
         .grid_en(grid_en),         
         .zdcf_en(zdcf_en),         
         .auto_en(auto_en),         
         .pixel_data_zdcf(pixel_data_zdcf), 
         .pixel_data_auto(pixel_data_auto), 
         .pixel_data_grid(pixel_data_grid), 
           .shuipincaiyang_en (shuipincaiyang_en )  ,  
           .chuizhifudu_en    (chuizhifudu_en    ) ,  
           .pixel_data_caiyang       (pixel_data_caiyang   )  ,         
           .pixel_data_fudu      (pixel_data_fudu      ) ,   
        .vs_out(vs_out), 
        .hs_out(hs_out), 
        .de_out(de_out),
        .r_out(r_out), 
        .g_out(g_out), 
        .b_out(b_out)
       );
     biankuang_display biankuang_display_isnt(
        .lcd_pclk(pix_clk)  ,               //lcd驱动时钟
        .sys_rst_n(rstn_out) ,               //复位信号
        .wave_run(wave_run)      ,
        .v_shift(v_shift),         //波形竖直偏移量，bit[9]=0/1:上移/下移 
        .h_shift(h_shift), 
        //.v_scale(),         //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
        .trig_edge(trig_edge),  // 触发边沿
        .ch_choose(ch_choose),  //通道选择
        .pixel_xpos(pixel_posx),               //像素点横坐标   在例化时将低位宽的像素坐标拼接0即可满足该模块的位宽
        .pixel_ypos(pixel_posy),               //像素点纵坐标
 .grid_choose(grid_choose),
 .auto(1'b0),
        .run_en         (run_en   )           ,
        .ch1_en         (ch1_en   )           ,
        .ch2_en         (ch2_en   )           ,
        .edge_en        (edge_en  )           ,
        .vshift_en      (vshift_en)           ,
        .hshift_en      (hshift_en)           ,
         .grid_en(grid_en),         
         .zdcf_en(zdcf_en),         
         .auto_en(auto_en),         
         .pixel_data_zdcf(pixel_data_zdcf), 
         .pixel_data_auto(pixel_data_auto), 
         .pixel_data_grid(pixel_data_grid), 
        .pixel_data_run (pixel_data_run )           ,
        .pixel_data_ch1 (pixel_data_ch1 )           ,
        .pixel_data_ch2 (pixel_data_ch2 )           ,
        .pixel_data_edge(pixel_data_edge)           ,
        .pixel_data_v   (pixel_data_v   )           ,                   
        .pixel_data_h     (pixel_data_h     )           //对应h_shift的移动显示
       );

div_display_aaaaa div_displayaaa_inst (
   .lcd_pclk(pix_clk),     //时钟
   .sys_rst_n(rstn_out),        //复位，低电平有效
   .v_scale(v_scale),      //改变垂直
   .deci_rate(deci_rate),     //对应改变水平分辨率                    
   .pixel_xpos(pixel_posx),   //像素点横坐标
   .pixel_ypos(pixel_posy),   //像素点纵坐标 
   .shuipincaiyang_en (shuipincaiyang_en )  ,  
   .chuizhifudu_en    (chuizhifudu_en    ) ,  
   .pixel_data        (pixel_data_caiyang   )  ,         
   .pixel_data1       (pixel_data_fudu      )      
); 

endmodule