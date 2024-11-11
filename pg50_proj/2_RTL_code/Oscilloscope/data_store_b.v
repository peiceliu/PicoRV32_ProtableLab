module data_store_b(
    input               rst_n,      // 复位信号

    input       [11:0]   trig_level, // 触发电平  之前是8位宽 此处应该要修改为12
    input               trig_edge,  // 触发边沿
    input               wave_run,   // 波形采集启动/停止
    input       [9:0]   h_shift,    // 波形水平偏移量

    input                ad_clk,     // AD时钟
    input       [11:0]   ad_data,    // AD输入数据   修改为了12位宽
    input               deci_valid, // 抽样有效信号 单周期的高电平
    
    input               lcd_clk,    //读时钟去对应后面的LCD显示模块 不过用HDMI的话需要思考一下
    input               lcd_wr_over,//波形绘制满
    input               wave_data_req,//相当于读史能
    input       [9:0]   wave_rd_addr,   //  当前读取地址
    output      [11:0]   wave_rd_data, //修改12位
    output reg          outrange    //水平偏移超出范围 这个地方对于不同大小的显示屏，边界不一样
);

//reg define                                 //改为了500个像素
reg [8:0] wr_addr;      //RAM写地址
//reg       ram_aclr;     //RAM清除

reg       trig_flag;    //触发标志 
reg       trig_en;      //触发使能
reg [8:0] trig_addr;    //触发地址

reg [11:0] pre_data; 
reg [11:0] pre_data1;
reg [11:0] pre_data2;
reg [8:0] data_cnt;

//wire define
wire       wr_en;       //RAM写使能
wire [9:0] rd_addr;     //RAM地址   
wire [9:0] rel_addr;    //相对触发地址
wire [9:0] shift_addr;  //偏移后的地址

wire       trig_pulse;  //满足触发条件时产生脉冲
wire [11:0] rd_ram_data;//修改为12位宽

//*****************************************************
//**                    main code
//*****************************************************
assign wr_en    = deci_valid && (data_cnt <= 499) && wave_run;

//计算波形水平偏移后的RAM数据地址
assign shift_addr = h_shift[9] ? (wave_rd_addr-h_shift[8:0]) : //右移 // 假设 wave_rd_addr 是我们需要移位的地址h_shift 是一个包含移位信息的信号，其中 h_shift[9] 控制移位方向,h_shift[8:0] 指定移位的数量（假定为0-511的范围）
                    (wave_rd_addr+h_shift[8:0]);               //左移

//根据触发地址，计算像素横坐标所映射的RAM地址
assign rel_addr = trig_addr + shift_addr;//相对地址 用于决定最终的读取地址
assign rd_addr = (rel_addr<250) ? (rel_addr+250) :    // 如果相对地址小于150，映射到150-299区间,如果相对地址大于449（150+299)，映射到0-149区间,在150到449之间，直接减去150以便映射到0-299区间
                    (rel_addr>749) ? (rel_addr-750) : //// 如果相对地址小于250，映射到250-499区间,如果相对地址大于250+499，映射到0-249区间,在250到549之间，直接减去250以便映射到0-499区间
                        (rel_addr-250);

//满足触发条件时输出脉冲信号
assign trig_pulse = trig_edge ? //1上升沿或者0下降沿触发
                    ((pre_data2<trig_level) && (pre_data1<trig_level) 
                        && (pre_data>=trig_level) && (ad_data>trig_level)) :
                    ((pre_data2>trig_level) && (pre_data1>trig_level) 
                        && (pre_data<=trig_level) && (ad_data<trig_level));        

//读出的数据为255时超出波形显示范围

//assign wave_rd_data = outrange ? 8'd255 : (8'd255 - (rd_ram_data >> 4));
//assign wave_rd_data = outrange ? 12'd4095 : (12'd4095 - rd_ram_data);
assign wave_rd_data = rd_ram_data;
/*
//判断水平偏移后地址范围
always @(posedge lcd_clk or negedge rst_n)begin
    if(!rst_n)
        outrange <= 1'b0;
    else                                        //右移时判断左边界
        if(h_shift[9] && (wave_rd_addr<h_shift[8:0]))    
            outrange <= 1'b1;
                                                //左移时判断右边界
        else if((~h_shift[9]) && (wave_rd_addr+h_shift[8:0]>499)) //对于不同分辨率屏幕 需要修改299  这里是设置的299
            outrange <= 1'b1;
        else
            outrange <= 1'b0;
end
*/
always @(posedge lcd_clk or negedge rst_n)begin
    if(!rst_n)
        outrange <= 1'b0;
    else                                        //右移时判断左边界
        if(h_shift[9] && (wave_rd_addr + 100 <h_shift[8:0]))    
            outrange <= 1'b1;
                                                //左移时判断右边界
        else if((~h_shift[9]) && (wave_rd_addr+h_shift[8:0]>599)) //对于不同分辨率屏幕 需要修改299  这里是设置的299
            outrange <= 1'b1;
        else
            outrange <= 1'b0;
end



//写RAM地址累加
always @(posedge ad_clk or negedge rst_n)begin //这里是最多300个数据输入
    if(!rst_n)
        wr_addr  <= 9'd0;
    else if(deci_valid) begin
        if(wr_addr < 9'd499) 
            wr_addr <= wr_addr + 1'b1;
        else 
            wr_addr  <= 9'd0;
    end
end

//触发使能
always @(posedge ad_clk or negedge rst_n)begin //修改data_cnt的最值来提高可接收的数据量，当然RAM存储数据的地址量要对应增加
    if(!rst_n) begin
        data_cnt <= 9'd0;
        trig_en  <= 1'b0;
    end
    else begin
        if(deci_valid) begin
            if(data_cnt < 249) begin    //触发前至少接收150个数据
                data_cnt <= data_cnt + 1'b1;
                trig_en  <= 1'b0;
            end
            else begin
                trig_en <= 1'b1;        //打开触发使能   data_cnt 为150时
                if(trig_flag) begin     //检测到触发信号
                    trig_en <= 1'b0;         
                    if(data_cnt < 500)  //继续接收150个数据
                        data_cnt <= data_cnt + 1'b1;
                end
            end

        end
                                        //波形绘制完成后重新计数
        if((data_cnt == 500) && lcd_wr_over & wave_run)
            data_cnt <= 9'd0;
    end
end

//寄存AD数据，用于判断触发条件
always @(posedge ad_clk or negedge rst_n)begin
    if(!rst_n) begin
        pre_data  <= 12'd0;
        pre_data1 <= 12'd0;
        pre_data2 <= 12'd0;
    end
    else if(deci_valid) begin
        pre_data  <= ad_data;
        pre_data1 <= pre_data;
        pre_data2 <= pre_data1;
    end
end

//触发检测
always @(posedge ad_clk or negedge rst_n)begin
    if(!rst_n) begin
        trig_addr <= 9'd0;
        trig_flag <= 1'b0;
    end
    else begin
        if(deci_valid && trig_en && trig_pulse) begin        //第一次deci_valid有效 只能产生trig_en为高然后保持为高 直到第二次deci_valid有效 结合三个为高 判断出trig_flag为高 然后tri_en变低 这应该是加2的原因 需仿真验证
            trig_flag <= 1'b1;
            trig_addr <= wr_addr + 2;//trig_addr 被设置为当前写地址 wr_addr 加 2。此处的加 2 可能是为了对齐或偏移，以便后续处理的需要  后续修改需要考虑这个2的问题
        end
        if(trig_flag && (data_cnt == 500)     
            && lcd_wr_over && wave_run)
            trig_flag <= 1'b0;
    end
end

//例化双口RAM
/*ram_2port u_ram_2port (
	.wrclock    (ad_clk),
	.wraddress  (wr_addr),
	.data       (ad_data),
	.wren       (wr_en),
    
	.rdclock    (lcd_clk),
	.rd_aclr    (1'b0),
	.rdaddress  (rd_addr), 
    .rden       (wave_data_req),
	.q          (rd_ram_data)
	);
*/
ram2b ram2b_inst (
  .wr_data(ad_data),    // input [11:0]
  .wr_addr(wr_addr),    // input [8:0]
  .wr_en(wr_en),        // input
  .wr_clk(ad_clk),      // input
  .wr_rst(~rst_n),      // input
  .rd_addr(rd_addr[8:0]),    // input [8:0]                虽然rd_addr是9位宽，但是只是低8位赋值去读数，我看了正点原子的原版IP核设计
  .rd_data(rd_ram_data),    // output [11:0]
  .rd_clk(lcd_clk),      // input
  .rd_clk_en(wave_data_req),    // input
  .rd_rst(~rst_n)       // input
);

endmodule 

