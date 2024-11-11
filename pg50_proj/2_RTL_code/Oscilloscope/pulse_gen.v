module pulse_gen(
    input           rst_n,      //系统复位，低电平有效
    
    /*input  [7:0]    trig_level,
    input           ad_clk,     //AD9280驱动时钟
    input  [7:0]    ad_data,    //AD输入数据
    */
    input  [11:0]    trig_level,
    input           ad_clk,     //AD9280驱动时钟
    input  [11:0]    ad_data,    //AD输入数据
    output          ad_pulse    //输出的脉冲信号
);

parameter THR_DATA = 3;//阈值的意义，当被测信号的频率很低时，为了防止因数据抖动导致转换后的脉冲有较大误差，代码定义的 THR_DATA 表示抖动的阈值，当 ad_data 大于（trig_level-THR_DATA）时，输出的脉冲 ad_pulse 为高电平，反之为低电平
//这里暂时保持为3！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
//reg define
reg          pulse;
reg          pulse_delay;

//*****************************************************
//**                    main code
//*****************************************************

assign ad_pulse = pulse & pulse_delay;

//根据触发电平，将输入的AD采样值转换成高低电平
always @ (posedge ad_clk or negedge rst_n)begin
    if(!rst_n)
        pulse <= 1'b0;
    else begin
        if((trig_level >= THR_DATA) && (ad_data < trig_level - THR_DATA))    //当ad_data的值在trig_level - THR_DATA和trig_level + THR_DATA之间时，没有明确的条件来更新pulse的值。在这种情况下，pulse保持不变，可能会导致在这个范围内的变化没有得到响应
            pulse <= 1'b0;
        else if(ad_data > trig_level + THR_DATA)
            pulse <= 1'b1;
    end    
end

//延时一个时钟周期，用于消除抖动
always @ (posedge ad_clk or negedge rst_n)begin
    if(!rst_n)
        pulse_delay <= 1'b0;
    else
        pulse_delay <= pulse;
end

endmodule 