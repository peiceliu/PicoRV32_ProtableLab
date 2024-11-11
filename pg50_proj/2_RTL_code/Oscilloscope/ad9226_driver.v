
module ad9226_driver(
    input ad_clk,                   // ����ʱ���ź�
    output clkA,                   // ����Aͨ��ʱ�� 65M
    output clkB,                    // ����Bͨ��ʱ�� 65M                  
    input sys_rst_n,                 // ��λ�ź�
    input [11:0] adc_data_A,// ADCת����� Aͨ��
    input [11:0] adc_data_B,// ADCת����� Bͨ��
    output reg [11:0] adc_data_A_out,// ADCת����� Aͨ��    ��ADCת������������ֱ�����������У�Ȼ���͵������洢ģ�鼴��          
    output reg [11:0] adc_data_B_out// ADCת����� Bͨ��     ���ﲻ����ֵ ȷ��������ȫ��Ӧ����ADCģ��
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