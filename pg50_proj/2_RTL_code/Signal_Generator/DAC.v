module DAC(
    input [13:0] dac_data_0,//DDS��rom�ж����Ĳ�������
    input [13:0] dac_data_1,//DDS��rom�ж����Ĳ�������
    input rsr_n,
    input clk, //125M ��Ҫ��DSSʱ��ͬ�� ��������Ҫ��FIFO���� ֱ�ӽ�DDS���������������DAת��
   output [13:0]DataA,  //С÷��DAC������ͨ����Ŀǰ�ǿ��ǵ�ͨ��
   output ClkA,
   output WRTA,
   output [13:0]DataB,  //С÷��DAC������ͨ����Ŀǰ�ǿ��ǵ�ͨ��
   output ClkB,
   output WRTB
);

assign ClkA = clk;
assign WRTA = ClkA;
assign DataA = dac_data_0;//���ֻ�����⼸���ӿ��߼����Ǿ��Ǹ�ʱ�Ӻ͸�һ��ֵ����
assign ClkB = clk;
assign WRTB = ClkB;
assign DataB = dac_data_1;//���ֻ�����⼸���ӿ��߼����Ǿ��Ǹ�ʱ�Ӻ͸�һ��ֵ����


endmodule