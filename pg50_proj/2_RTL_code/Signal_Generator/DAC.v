module DAC(
    input [13:0] dac_data_0,//DDS从rom中读出的波形数据
    input [13:0] dac_data_1,//DDS从rom中读出的波形数据
    input rsr_n,
    input clk, //125M 需要和DSS时钟同步 这样不需要用FIFO缓存 直接将DDS输出给到驱动就行DA转换
   output [13:0]DataA,  //小梅哥DAC有两个通道，目前是考虑单通道
   output ClkA,
   output WRTA,
   output [13:0]DataB,  //小梅哥DAC有两个通道，目前是考虑单通道
   output ClkB,
   output WRTB
);

assign ClkA = clk;
assign WRTA = ClkA;
assign DataA = dac_data_0;//如果只考虑这几个接口逻辑，那就是给时钟和赋一下值就行
assign ClkB = clk;
assign WRTB = ClkB;
assign DataB = dac_data_1;//如果只考虑这几个接口逻辑，那就是给时钟和赋一下值就行


endmodule