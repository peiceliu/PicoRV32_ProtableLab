
module ad9226_driver(
    input ad_clk,                   // 输入时钟信号
    output clkA,                   // 控制A通道时钟 65M
    output clkB,                    // 控制B通道时钟 65M                  
    input sys_rst_n,                 // 复位信号
    input [11:0] adc_data_A,// ADC转换结果 A通道
    input [11:0] adc_data_B,// ADC转换结果 B通道
    output reg [11:0] adc_data_A_out,// ADC转换结果 A通道    将ADC转换过来的数据直接引出来就行，然后送到抽样存储模块即可          
    output reg [11:0] adc_data_B_out// ADC转换结果 B通道     这里不给初值 确保数据完全对应来自ADC模块
);

assign clkA = ad_clk;
assign clkB = ad_clk;
/*
    always @(posedge ad_clk ) begin                                                                   
        adc_data_A_out <= adc_data_A;
        adc_data_B_out <= adc_data_B;
    end 
*/
//reg [11:0] adc_data_A_d1;
//reg [11:0] adc_data_B_d1;
 always @(posedge ad_clk  ) begin 
       if(adc_data_A >= 12'd2048)
            adc_data_A_out <= (4096 - adc_data_A) + 2048;
       else 
           adc_data_A_out <= (2048 - adc_data_A );
end 
      
 always @(posedge ad_clk  ) begin 
       if(adc_data_B >= 12'd2048)
            adc_data_B_out <= (4096 - adc_data_B) + 2048;
       else 
           adc_data_B_out <= (2048 - adc_data_B );
end    



endmodule