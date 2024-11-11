module fre_display(
    input             lcd_pclk  ,               //lcd驱动时钟
    input             sys_rst_n ,               //复位信号
	input      [35:0] data_d0      ,
    input      [10:0] pixel_xpos,               //像素点横坐标   在例化时将低位宽的像素坐标拼接0即可满足该模块的位宽
    input      [10:0] pixel_ypos,               //像素点纵坐标
    output            fre_en,
    output reg [23:0] pixel_data                //像素点数据
);
//parameter define
parameter  CHAR_POS_X  = 11'd58      ;           //字符区域起始点横坐标    修改来适合示波器的显示
parameter  CHAR_POS_Y  = 11'd1      ;           //字符区域起始点纵坐标
parameter  CHAR_WIDTH  = 11'd88     ;           //字符区域宽度
parameter  CHAR_HEIGHT = 11'd16    ;           //字符区域高度
//parameter  WHITE       = 24'hFFFFFF ;     		//背景色，白色
//parameter  BLACK       = 24'h0      ;     	    //字符颜色，黑色 
parameter WHITE  =  24'h0000ff;//背景色蓝色
parameter BLACK   =  24'hFFFFFF;//字符颜色,白色
//reg define
reg     [127:0] char        [11:0]  ;           //字符数组
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
    char[0 ]  <= 128'h00000018244242424242424224180000 ; // "0"
    char[1 ]  <= 128'h000000107010101010101010107C0000 ; // "1"
    char[2 ]  <= 128'h0000003C4242420404081020427E0000 ; // "2"
    char[3 ]  <= 128'h0000003C424204180402024244380000 ; // "3"
    char[4 ]  <= 128'h000000040C14242444447E04041E0000 ; // "4"
    char[5 ]  <= 128'h0000007E404040586402024244380000 ; // "5"
    char[6 ]  <= 128'h0000001C244040586442424224180000 ; // "6"
    char[7 ]  <= 128'h0000007E444408081010101010100000 ; // "7"
    char[8 ]  <= 128'h0000003C4242422418244242423C0000 ; // "8"
    char[9 ]  <= 128'h0000001824424242261A020224380000 ; // "9"
    char[10]  <= 128'h000000E7424242427E42424242E70000 ; // "H"
    char[11]  <= 128'h000000000000007E44081010227E0000 ; // "z"
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
            if(char[data8][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data7][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data6][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data5][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd5)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data4][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd5) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd6)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data3][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd6) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd7)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data2][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd7) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd8)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])    //具体计算一下就懂原理了 就是相当于127-120为第一Y 和 x对应的8个数 后面依次类推为第二Y‘’‘’
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end        
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd8) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd9)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[data0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) -11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end 
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd9) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd10)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd11 * 11'd10) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[11][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end	
	else begin
		pixel_data <= WHITE;              //绘制屏幕背景为白色
	end
end

endmodule 