`timescale 1ns / 1ps
`define UD #1
module hexin_shuanglu(
  
//hdmi_out 
    //output            pix_clk       ,//pixclk      顶层已经作了相应的赋值工作                     
    output  reg       vs_out        , //列
    output  reg       hs_out        , //行
    output  reg       de_out        ,
    output     [7:0]  r_out         , 
    output     [7:0]  g_out         , 
    output     [7:0]  b_out         ,
    input                                rst_n, 
    input                                lcd_pclk,
    input [10:0]                   pixel_xpos,
    input [10:0]                   pixel_ypos,
    input                                vs_in, 
    input                                hs_in, 
    input                                de_in,
    
    //自己加的部分    还有就是参考历程是16位像素数据 与此处rgb888不同  这些端口添加是用于波形显示部分的代码 
    input      [11:0]  wave_data,       //波形(AD数据)    上述诸多端口在存储触发部分出现 
    output     [9:0]  wave_addr,       // 显示点数，对应ram地址 之前ram是9位宽 需要修改  主要是看设计的横坐标像素个数
    input             outrange,           
    output            wave_data_req,   //请求波形（AD）数据
    output            wr_over,         //绘制波形完成
    input      [9:0]  v_shift,         //波形竖直偏移量，bit[9]=0/1:上移/下移 
    input      [9:0]  h_shift, 
    input      [4:0]  v_scale,         //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
    input      [8:0] trig_line,        //触发电平  这个是对应于像素纵坐标  此处最多480 暂时修改为9位宽

//自己加的部分    还有就是参考历程是16位像素数据 与此处rgb888不同  这些端口添加是用于波形显示部分的代码 
    input      [11:0]  wave_data_b,       //波形(AD数据)    上述诸多端口在存储触发部分出现 
    output     [9:0]  wave_addr_b,       // 显示点数，对应ram地址 之前ram是9位宽 需要修改  主要是看设计的横坐标像素个数
    input             outrange_b,           
    output            wave_data_req_b,   //请求波形（AD）数据
    output            wr_over_b,         //绘制波形完成
    input      [9:0]  v_shift_b,         //波形竖直偏移量，bit[9]=0/1:上移/下移 
    input      [4:0]  v_scale_b,         //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
    input      [8:0] trig_line_b,        //触发电平  这个是对应于像素纵坐标  此处最多480 暂时修改为9位宽
   //显示字符 logo  频率/vpp/电压
    input            fre_en,
    input      [23:0] pixel_data_fre,
    input             back_en,
    input      [23:0] pixel_data_back, 
   input          run_en,
   input          ch1_en,
   input          ch2_en,
   input          edge_en,
   input          vshift_en,
   input          hshift_en,
   input   [23:0] pixel_data_run,
   input   [23:0] pixel_data_ch1,
   input   [23:0] pixel_data_ch2,
   input   [23:0] pixel_data_edge,
   input   [23:0] pixel_data_v,                   
   input   [23:0] pixel_data_h ,               //对应h_shift的移动显示
    //显示水平/垂直
    input            shuipin_en,
    input      [23:0] pixel_data_shuipin,
    input             chuizhi_en,
    input      [23:0] pixel_data_chuizhi,  
    input            v_en,
    input      [23:0] pixel_data_vol ,
//显示字符 logo  频率/vpp/电压
    input            fre_en_b,
    input      [23:0] pixel_data_fre_b,
    input             back_en_b,
    input      [23:0] pixel_data_back_b, 
   input          run_en_b,
   //input          ch1_en,
   //input          ch2_en,
   input          edge_en_b,
   input          vshift_en_b,
   input          hshift_en_b,
   input   [23:0] pixel_data_run_b,
   //input   [23:0] pixel_data_ch1,
  // input   [23:0] pixel_data_ch2,
   input   [23:0] pixel_data_edge_b,
   input   [23:0] pixel_data_v_b,                   
   input   [23:0] pixel_data_h_b ,               //对应h_shift的移动显示
    //显示水平/垂直
    input            shuipin_en_b,
    input      [23:0] pixel_data_shuipin_b,
    input             chuizhi_en_b,
    input      [23:0] pixel_data_chuizhi_b,  
    input            v_en_b,
    input      [23:0] pixel_data_vol_b 
  
   );

//parameter define  
localparam WHITE  = 24'hffffff;     //RGB565 白色    根据RGB565转RGB888的规则是对的上的
localparam BLUE   = 24'h66ffff;     //RGB565 蓝色
localparam GREEN  = 24'h00ff00;   
localparam BLACK  = 24'h000000; 
localparam RED    = 24'hff0000; 
//便于设计背景网格 800x480
localparam H_TOTAL = 11'd1056;
localparam V_TOTAL = 11'd525;
//reg define
reg  [15:0] pre_length1;
reg  [15:0] pre_length;//用途: 存储上一个绘制周期的波形长度或某种特定的长度值。这可以帮助在绘制新帧时进行比较或者条件判断。作用: 在需要时可以使用这个寄存器来决定是否需要更新波形数据，或者在处理不同波形的时候跟踪当前的绘制状态。
reg         outrange_reg;
reg  [15:0] shift_length;//用途: 存储缩放后波形的实际长度值，通常与采样数据的最大值相关联。作用: 在进行波形绘制时，需要依据这个长度来决定如何正确地映射波形到显示面板上。
reg  [9:0]  v_shift_t;
reg  [4:0]  v_scale_t;
reg  [11:0] scale_length;//为了适应12位宽AD的计算公式
reg  [8:0] trig_line_t;//用途: 用于存储触发线的位置，它可能代表波形图中的参考线或标记。这个值通常是由用户设置或通过某些逻辑计算得到的。作用: 在显示波形时，可以根据这个触发线的值来计算显示的基准线，从而让波形图的解读更为清晰。
reg  [23:0] pixel_data;
wire [15:0] draw_length;


//reg define
reg  [15:0] pre_length1_b;
reg  [15:0] pre_length_b;//用途: 存储上一个绘制周期的波形长度或某种特定的长度值。这可以帮助在绘制新帧时进行比较或者条件判断。作用: 在需要时可以使用这个寄存器来决定是否需要更新波形数据，或者在处理不同波形的时候跟踪当前的绘制状态。
reg  [15:0] shift_length_b;//用途: 存储缩放后波形的实际长度值，通常与采样数据的最大值相关联。作用: 在进行波形绘制时，需要依据这个长度来决定如何正确地映射波形到显示面板上。
reg  [9:0]  v_shift_t_b;
reg  [4:0]  v_scale_t_b;
reg  [11:0] scale_length_b;//为了适应12位宽AD的计算公式
reg  [8:0] trig_line_t_b;//用途: 用于存储触发线的位置，它可能代表波形图中的参考线或标记。这个值通常是由用户设置或通过某些逻辑计算得到的。作用: 在显示波形时，可以根据这个触发线的值来计算显示的基准线，从而让波形图的解读更为清晰。
wire [15:0] draw_length_b;
reg         outrange_reg_b;
//*****************************************************
//**                    main code
//*****************************************************

assign r_out = pixel_data[23:16];
assign g_out = pixel_data[15:8];
assign b_out = pixel_data[7:0];

// 请求像素数据信号
assign wave_data_req = ((pixel_xpos >= 11'd49 - 1'b1-1'b1) && (pixel_xpos < 11'd549 - 1-1)  //处理边界问题
                         && (pixel_ypos >= 11'd29) && (pixel_ypos < 11'd430)) 
                       ? 1'b1 : 1'b0;
// 请求像素数据信号
assign wave_data_req_b = ((pixel_xpos >= 11'd49 - 1'b1-1'b1) && (pixel_xpos < 11'd549 - 1-1)  //处理边界问题
                         && (pixel_ypos >= 11'd29) && (pixel_ypos < 11'd430)) 
                       ? 1'b1 : 1'b0;

/*
assign wave_data_req = ((pixel_xpos >= 11'd49 - 1'b1) && (pixel_xpos < 11'd549 - 1)  
                         && (pixel_ypos >= 11'd49) && (pixel_ypos < 11'd450)) 
                       ? 1'b1 : 1'b0;
*/
// 根据显示的X坐标计算数据在RAM中的地址
assign wave_addr = wave_data_req ? (pixel_xpos - (11'd49-1'b1-1'b1)) : 10'd0;
// 根据显示的X坐标计算数据在RAM中的地址
assign wave_addr_b = wave_data_req_b ? (pixel_xpos - (11'd49-1'b1-1'b1)) : 10'd0;

// 标志一帧波形绘制完毕
assign wr_over  = (pixel_xpos == 11'd549) && (pixel_ypos == 11'd429);
// 标志一帧波形绘制完毕
assign wr_over_b  = (pixel_xpos == 11'd549) && (pixel_ypos == 11'd429);

//寄存输入的参数
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n) begin
        v_shift_t <= 10'b0;
        v_scale_t <= 5'b0;
        trig_line_t <= 9'b0;
    end    
    else begin
        v_shift_t <= v_shift;
        v_scale_t <= v_scale;
        trig_line_t <= trig_line;    
    end
end
//寄存输入的参数
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n) begin
        v_shift_t_b <= 10'b0;
        v_scale_t_b <= 5'b0;
        trig_line_t_b <= 9'b0;
    end    
    else begin
        v_shift_t_b <= v_shift_b;
        v_scale_t_b <= v_scale_b;
        trig_line_t_b <= trig_line_b;    
    end
end


always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n)begin
        vs_out <= 1'b0;
        hs_out <= 1'b0;
        de_out <= 1'b0;
    end
    else begin
        vs_out <= `UD vs_in;
        hs_out <= `UD hs_in;
        de_out <= `UD de_in;
    end
end 

//竖直方向上的缩放
always @(*) begin
    if(v_scale_t[4])   //放大
        scale_length = ((wave_data>>4)* v_scale_t[3:0]-((9'd128*v_scale_t[3:0])-9'd128));
    else               //缩小
        scale_length = ((wave_data>>4) >> v_scale_t[3:1])+(128-(128>>v_scale_t[3:1]));
end


//对波形进行竖直方向的移动
always @(*) begin
    if(v_shift_t[9]) begin  //下移
        if(scale_length >= 12'd2048) 
            shift_length = v_shift_t[8:0]+9'd20-(~{4'hf,scale_length}+1'b1);
        else
            shift_length = scale_length+v_shift_t[8:0]+9'd20;
    end
    else begin              //上移
        if(scale_length >= 12'd2048) 
            shift_length = 16'd0;
        else if(scale_length+9'd20 <= v_shift_t[8:0])
            shift_length = 16'd0;
        else
            shift_length = scale_length+9'd20-v_shift_t[8:0];
    end    
end

//处理负数长度
assign draw_length = shift_length[15] ? 16'd0 : shift_length;
//寄存前一个像素点的纵坐标，用于各点之间的连线 连线绘制：保存的前一个点的信息可以用于绘制波形图中的连线，使得波形在LCD屏幕上更加流畅和连续。
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n) begin
        pre_length <= 16'd0;
        pre_length1 <= 16'd0;
    end
    else 
    if((pixel_xpos >= 11'd48)  && (pixel_xpos < 11'd548 )  && (pixel_ypos >= 11'd29) && (pixel_ypos < 11'd430)) begin
        pre_length <= (draw_length*25)/16;
        pre_length1 <= pre_length;
    end
end



//寄存outrange,用于水平方向移动时处理左右边界
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n)
        outrange_reg <= 1'b0;
    else 
        outrange_reg <= outrange;
end

//竖直方向上的缩放
always @(*) begin
    if(v_scale_t_b[4])   //放大
        scale_length_b = ((wave_data_b>>4)* v_scale_t_b[3:0]-((9'd128*v_scale_t_b[3:0])-9'd128));
    else               //缩小
        scale_length_b = ((wave_data_b>>4) >> v_scale_t_b[3:1])+(128-(128>>v_scale_t_b[3:1]));
end


//对波形进行竖直方向的移动
always @(*) begin
    if(v_shift_t_b[9]) begin  //下移
        if(scale_length_b >= 12'd2048) 
            shift_length_b = v_shift_t_b[8:0]+9'd20-(~{4'hf,scale_length_b}+1'b1);
        else
            shift_length_b = scale_length_b+v_shift_t_b[8:0]+9'd20;
    end
    else begin              //上移
        if(scale_length_b >= 12'd2048) 
            shift_length_b = 16'd0;
        else if(scale_length_b+9'd20 <= v_shift_t_b[8:0])
            shift_length_b = 16'd0;
        else
            shift_length_b = scale_length_b+9'd20-v_shift_t_b[8:0];
    end    
end

//处理负数长度
assign draw_length_b = shift_length_b[15] ? 16'd0 : shift_length_b;
//寄存前一个像素点的纵坐标，用于各点之间的连线 连线绘制：保存的前一个点的信息可以用于绘制波形图中的连线，使得波形在LCD屏幕上更加流畅和连续。
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n) begin
        pre_length_b <= 16'd0;
        pre_length1_b <= 16'd0;
    end
    else 
    if((pixel_xpos >= 11'd48)  && (pixel_xpos < 11'd548 )  && (pixel_ypos >= 11'd29) && (pixel_ypos < 11'd430)) begin
        pre_length_b <= (draw_length_b*25)/16;
        pre_length1_b <= pre_length_b;
    end
end

//寄存outrange,用于水平方向移动时处理左右边界
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n)
        outrange_reg_b <= 1'b0;
    else 
        outrange_reg_b <= outrange_b;
end


reg grid;
reg grid1;

//首先设计背景网格  然后对于波形和字符的显示 可以assign+判断语句 不过都是建立在背景显示的基础上

reg [10:0] h_cnt;
reg [10:0] v_cnt;

//行计数器对像素时钟计数
always@ (posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        h_cnt <= 11'd0;
    else begin
        if(h_cnt == H_TOTAL - 1'b1)
            h_cnt <= 11'd0;
        else
            h_cnt <= h_cnt + 1'b1;           
    end
end
//场计数器对行计数
always@ (posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        v_cnt <= 11'd0;
    else begin
        if(h_cnt == H_TOTAL - 1'b1) begin
            if(v_cnt == V_TOTAL - 1'b1)
                v_cnt <= 11'd0;
            else
                v_cnt <= v_cnt + 1'b1;    
        end
    end    
end
//行像素49-549，每次隔20画一条  考虑抽样数的近似值  3.25对应1us 列像素49-449 隔40     中间和水平单独画  h_cnt = 515 v_cnt=284        216（对应计数器应该是215）  35
always@(*)begin
       if((h_cnt >= 265 ) && (h_cnt <= 765) && (v_cnt>= 64) && (v_cnt <= 464))begin    
			if((h_cnt == 265) || (h_cnt == 285) || (h_cnt == 305) || (h_cnt == 325) 
			|| (h_cnt == 345) || (h_cnt == 365) || (h_cnt == 385) || (h_cnt == 405) 
			|| (h_cnt == 425) || (h_cnt == 445) || (h_cnt == 465) || (h_cnt == 485) || (h_cnt == 505) || (h_cnt == 525) 
            || (h_cnt == 545) || (h_cnt == 565) || (h_cnt == 585) || (h_cnt == 605) || (h_cnt == 625) || (h_cnt == 645)
            || (h_cnt == 665) || (h_cnt == 685) || (h_cnt == 705) || (h_cnt == 725) || (h_cnt == 745) || (h_cnt == 765)
			|| (v_cnt == 84) || (v_cnt == 104) || (v_cnt == 124) || (v_cnt == 144) 
            || (v_cnt == 164) || (v_cnt == 184) || (v_cnt == 204) || (v_cnt == 224) || (v_cnt == 244)
			|| (v_cnt == 284) || (v_cnt== 304) || (v_cnt == 324) || (v_cnt== 344) || (v_cnt == 364) || (v_cnt == 384)
            || (v_cnt == 404) || (v_cnt== 424) || (v_cnt == 444) || (v_cnt== 464) || (v_cnt == 64) )
				grid = 1;                           //垂直20格子 500mv           水平25格子 水平分辨率任意 
			else
				grid = 0;	
		end
		else
			grid = 0;        
end
//目前触发电平线249+34=283 有点错开了这个284（把触发电平设为249，这样就是250+34让对上背景线284？）  该怎么弄 还有就是1v  2v是是不是应该基于触发电平来设置 而不是根据背景线 确实应该是根据触发电平设置1v 2v 这样才够准确
always@(*)begin
    if((h_cnt >= 265 ) && (h_cnt <= 765) && (v_cnt>= 64) && (v_cnt <= 464))begin
     if((h_cnt == 515) ||(v_cnt == 264))
           grid1 = 1;
     else 
           grid1 = 0;
    end 
    else 
           grid1 = 0;
end 
/*
 if(((pixel_ypos >= pre_length) && (pixel_ypos <= draw_length))
                    ||((pixel_ypos <= pre_length)&&(pixel_ypos >= draw_length)))
            pixel_data <= RED;     //显示波形
*/
//根据读出的AD值，在屏幕上绘点                            //目前暂定ui_pixel_data为背景显示（包括字符 图片logo 网格线）波形数据显示此处已经划分区域解决  利用叠加显示来做
                                                       // 频率 峰峰值 怎么动态显示出来（参考rtc实时时钟)，同时在画网格线可以定义纵网格之间的量程 // 波形切换指示 启动/暂停 缩放 移动 暂定为按键加上位机 怎么能在屏幕上对应显示是一个问题
 //显示优先级 可参考case语句的写法 还有就是感觉这里用时序设计比较合理吧 此处选择时序 不过对于超量程可能会出问题，此处暂时不考虑。 不行的话可以考虑改为组合
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n)
        pixel_data <= BLACK;
   // else  if(outrange_reg || outrange)    //超出波形显示范围
        //pixel_data <= WHITE; //显示UI波形(此处改为部分局部背景）    
    else if((pixel_xpos > (11'd49)) && (pixel_xpos < (11'd549 ) ) &&                 //坐标点在波形显示范围内51-549
                   (pixel_ypos >= 11'd29) && (pixel_ypos < 11'd430)) begin
        if(((pixel_ypos >= pre_length1) && (pixel_ypos <= pre_length))
                    ||((pixel_ypos <= pre_length1)&&(pixel_ypos >= pre_length)))
            pixel_data <= BLUE;     //显示波形
        else if(((pixel_ypos >= pre_length1_b) && (pixel_ypos <= pre_length_b))
                    ||((pixel_ypos <= pre_length1_b)&&(pixel_ypos >= pre_length_b)))
            pixel_data <= GREEN;     //显示波形
        else if(((v_shift_b[9] == 1'b1) && (pixel_ypos == trig_line_t_b + ((v_shift_b[8:0]*25)/16)))|| ((v_shift_b[9] == 1'b0) && (pixel_ypos == trig_line_t_b - ((v_shift_b[8:0]*25)/16)))) 
            pixel_data <= GREEN;      //显示触发线
        else  if(((v_shift[9] == 1'b1) && (pixel_ypos == trig_line_t + ((v_shift[8:0]*25)/16)))|| ((v_shift[9] == 1'b0) && (pixel_ypos == trig_line_t - ((v_shift[8:0]*25)/16)))) 
            pixel_data <= RED;      //显示触发线
          else if(grid)
           pixel_data <= WHITE;
        else if(grid1)
           pixel_data <= BLUE;
        else 
            pixel_data <= BLACK;
      end 
 
   else if(v_en)  //如果这样判断的话 对应像素展示应该会在延迟一拍 画图具体分析一下
           pixel_data <= pixel_data_vol;
   else if(back_en)
           pixel_data <= pixel_data_back;
   else if(fre_en)
           pixel_data <= pixel_data_fre;
   else if(shuipin_en)
           pixel_data <= pixel_data_shuipin;
   else if(chuizhi_en)
           pixel_data <= pixel_data_chuizhi;
   else if(run_en)
           pixel_data <= pixel_data_run;
   else if(ch1_en)
           pixel_data <= pixel_data_ch1;
   else if(ch2_en)
           pixel_data <= pixel_data_ch2;
   else if(vshift_en)
           pixel_data <= pixel_data_v;
   else if(hshift_en)
           pixel_data <= pixel_data_h;
   else if(edge_en)
           pixel_data <= pixel_data_edge;
 
   else if(( h_cnt == 265 ) && (v_cnt>= 64) && (v_cnt <= 464))
           pixel_data <= WHITE;
/*
   else if(( h_cnt > 245 ) && (h_cnt <= 265) && ((v_cnt == 84) || (v_cnt == 104) || (v_cnt == 124) || (v_cnt == 144) 
            || (v_cnt == 164) || (v_cnt == 184) || (v_cnt == 204) || (v_cnt == 224) || (v_cnt == 244)
			|| (v_cnt == 264) || (v_cnt== 304) || (v_cnt == 324) || (v_cnt== 344) || (v_cnt == 364) || (v_cnt == 384)
            || (v_cnt == 404) || (v_cnt== 424) || (v_cnt == 444) || (v_cnt== 464) || (v_cnt == 64)))
           pixel_data <= WHITE;
*/
  else if(v_en_b)  //如果这样判断的话 对应像素展示应该会在延迟一拍 画图具体分析一下
           pixel_data <= pixel_data_vol_b;
   else if(back_en_b)
           pixel_data <= pixel_data_back_b;
   else if(fre_en_b)
           pixel_data <= pixel_data_fre_b;
   else if(shuipin_en_b)
           pixel_data <= pixel_data_shuipin_b;
   else if(chuizhi_en_b)
           pixel_data <= pixel_data_chuizhi_b;
   else if(run_en_b)
           pixel_data <= pixel_data_run_b;
   else if(vshift_en_b)
           pixel_data <= pixel_data_v_b;
   else if(hshift_en_b)
           pixel_data <= pixel_data_h_b;
   else if(edge_en_b)
           pixel_data <= pixel_data_edge_b;
   else 
          pixel_data <= BLACK;
end        

endmodule