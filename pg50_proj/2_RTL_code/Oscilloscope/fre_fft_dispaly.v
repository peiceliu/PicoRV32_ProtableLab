module fre_fft_display(
    input             lcd_pclk  ,               //lcd驱动时钟
    input             sys_rst_n ,               //复位信号
	input      [35:0] data_d0      ,
    input      [10:0] pixel_xpos,               //像素点横坐标   在例化时将低位宽的像素坐标拼接0即可满足该模块的位宽
    input      [10:0] pixel_ypos,               //像素点纵坐标
    output            fre_en,
    output reg [23:0] pixel_data                //像素点数据
);
//parameter define
parameter  CHAR_POS_X  = 11'd171      ;           //字符区域起始点横坐标    修改来适合示波器的显示
parameter  CHAR_POS_Y  = 11'd75      ;           //字符区域起始点纵坐标
parameter  CHAR_WIDTH  = 11'd176     ;           //字符区域宽度
parameter  CHAR_HEIGHT = 11'd32    ;           //字符区域高度
//parameter  WHITE       = 24'hFFFFFF ;     		//背景色，白色
//parameter  BLACK       = 24'h0      ;     	    //字符颜色，黑色 
parameter WHITE  =  24'hffffff;//背景色白色
parameter BLACK   = 24'h000000;//字符颜色,黑色
//reg define
reg     [511:0] char        [11:0]  ;           //字符数组
reg [35:0] data_d1;
reg [35:0] data_d2;
reg [35:0] data_d3   ;
reg [10:0] cnt;
reg [45:0] data_sum;
reg [35:0]  data;
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
       data_d1 <= 36'd0;
       data_d2 <= 36'd0;
       data_d3 <= 36'd0;
    end 
    else begin
       data_d1 <= data_d0;
       data_d2 <= data_d1;
       data_d3 <= data_d2;
    end 
end

always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
       cnt <= 11'd0;
    end 
   else if(cnt == 11'd1024)
       cnt <= 11'd0;
   else 
       cnt <= cnt+11'd1;
end 
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
        data_sum <= 46'd0;
    end
    else if (( data_d3[35:31] == 4'd0)&& (cnt <=11'd1023))
        data_sum <= data_sum + data_d3 ;
    else  if(cnt == 11'd1024)begin
        data <= data_sum[45:10];
        data_sum <= 46'd0;
    end
    else  data_sum <= data_sum;
end


//wire define
wire [3:0]      data0    ;            // 个位数
wire [3:0]      data1    ;            // 十位数
wire [3:0]      data2    ;            // 百位数
wire [3:0]      data3    ;            // 千位数
wire [3:0]      data4    ;            // 万位数
wire [3:0]      data5    ;            // 十万位数
wire [3:0]      data6    ;            // 百万位数
wire [3:0]      data7    ;            // 千万位数
wire [3:0]      data8    ;            // 亿位数
//*****************************************************
//**                    main code
//*****************************************************
assign  data8 = data[35:32];    // 亿位数
assign  data7 = data[31:28];    // 千万位数
assign  data6 = data[27:24];    // 百万位数
assign  data5 = data[23:20];    // 十万位数
assign  data4 = data[19:16];    // 万位数
assign  data3 = data[15:12];    // 千位数
assign  data2 = data[11:8];     // 百位数
assign  data1 = data[7:4];      // 十位数
assign  data0 = data[3:0];      // 个位数

//给字符数组赋值，用于存储字模数据
always @(posedge lcd_pclk) begin
    char[0 ] <=  512'h00000000000000000000000003C006200C30181818181808300C300C300C300C300C300C300C300C300C300C1808181818180C30062003C00000000000000000;
    char[1 ]  <= 512'h000000000000000000000000008001801F800180018001800180018001800180018001800180018001800180018001800180018003C01FF80000000000000000; 
    char[2 ]  <= 512'h00000000000000000000000007E008381018200C200C300C300C000C001800180030006000C0018003000200040408041004200C3FF83FF80000000000000000;
    char[3 ]  <= 512'h00000000000000000000000007C018603030301830183018001800180030006003C0007000180008000C000C300C300C30083018183007C00000000000000000;
    char[4 ]  <= 512'h0000000000000000000000000060006000E000E0016001600260046004600860086010603060206040607FFC0060006000600060006003FC0000000000000000;
    char[5 ]  <= 512'h0000000000000000000000000FFC0FFC10001000100010001000100013E0143018181008000C000C000C000C300C300C20182018183007C00000000000000000;
    char[6 ]  <= 512'h00000000000000000000000001E006180C180818180010001000300033E0363038183808300C300C300C300C300C180C18080C180E3003E00000000000000000;
    char[7 ]  <= 512'h0000000000000000000000001FFC1FFC100830102010202000200040004000400080008001000100010001000300030003000300030003000000000000000000;
    char[8 ]  <= 512'h00000000000000000000000007E00C301818300C300C300C380C38081E180F2007C018F030783038601C600C600C600C600C3018183007C00000000000000000;
    char[9 ]  <= 512'h00000000000000000000000007C01820301030186008600C600C600C600C600C701C302C186C0F8C000C0018001800103030306030C00F800000000000000000;
    char[10]  <= 512'h000000000000000000000000FC3F300C300C300C300C300C300C300C300C300C3FFC300C300C300C300C300C300C300C300C300C300CFC3F0000000000000000;
    char[11]  <= 512'h0000000000000000000000001FFE1C0C180C3018201800300060006000C000C00180018003000300060006000C00180218063004301C7FFC0000000000000000;
end 

//产生fre_en 不过要提前一拍产生 由于赋值一般存在一拍延时 所以在对应的像素块要减一  这里Y是1-16 x是150-237 11个16x8
assign  fre_en = (pixel_xpos >= (CHAR_POS_X - 1'd1))&&(pixel_xpos < (CHAR_POS_X - 1'd1 +CHAR_WIDTH))&&(pixel_ypos >= CHAR_POS_Y) && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT);

//给不同的区域赋值不同的像素数据
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
        pixel_data <= WHITE;
    end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd11 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data8][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd16) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data7][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd16) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data6][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd16) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data5][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd16) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd5)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data4][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd16) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd5) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd6)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data3][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd16) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd6) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd7)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data2][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd16) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd7) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd8)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd16) - 11'd1])    //具体计算一下就懂原理了 就是相当于127-120为第一Y 和 x对应的8个数 后面依次类推为第二Y‘’‘’
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end        
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd8) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd9)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd16) -11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end 
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd9) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd10)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd16) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd10) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[11][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd16 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd16) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end	
	else begin
		pixel_data <= WHITE;              //绘制屏幕背景为白色
	end
end

endmodule 