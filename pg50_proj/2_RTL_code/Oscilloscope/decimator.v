module decimator(
    input       ad_clk,//若是小梅哥的开发板，时钟暂定为65M，需确保和ADC模块时钟同步，这样才不会跨时钟域
    input       rst_n,
    
    input [11:0] deci_rate, 
    output reg  deci_valid
);

//reg define
reg [11:0] deci_cnt;         // 抽样计数器 需要注意采样数据个数和LCD显示像素

//*****************************************************
//**                    main code
//*****************************************************

//抽样计数器计数
always @(posedge ad_clk or negedge rst_n) begin
    if(!rst_n)
        deci_cnt <= 12'd0;
    else
        if(deci_cnt == deci_rate-1)
            deci_cnt <= 12'd0;
        else
            deci_cnt <= deci_cnt + 1'b1;
end

//输出抽样有效信号
always @(posedge ad_clk or negedge rst_n) begin
    if(!rst_n)
        deci_valid <= 1'b0;
    else
        if(deci_cnt == deci_rate-1)
            deci_valid <= 1'b1;
        else
            deci_valid <= 1'b0;    
end

endmodule 