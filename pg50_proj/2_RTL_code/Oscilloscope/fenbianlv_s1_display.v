module fenbianlv_s1_display(
    input             lcd_pclk,     //时钟
    input             sys_rst_n,        //复位，低电平有效
    input      [4:0]  v_scale,      //改变垂直
    input      [11:0] deci_rate,     //对应改变水平分辨率                    
    input      [10:0] pixel_xpos,   //像素点横坐标
    input      [10:0] pixel_ypos,   //像素点纵坐标 
    output            shuipin_en   ,   //显示水平分辨率
    output            chuizhi_en   ,   //显示垂直分辨率
    output reg [23:0] pixel_data,    //像素点数据 水平
    output reg [23:0] pixel_data1    //像素点数据 垂直
); 
//parameter define
parameter  CHAR_POS_X  = 11'd350      ;           //字符区域起始点横坐标    修改来适合示波器的显示  M:后面的数字 HOR 后面的数值
parameter  CHAR_POS_Y  = 11'd446      ;           //字符区域起始点纵坐标
parameter  CHAR_WIDTH  = 11'd40     ;           //字符区域宽度
parameter  CHAR_HEIGHT = 11'd16    ;           //字符区域高度
parameter  CHAR_POS_X1  = 11'd470      ;           //字符区域起始点横坐标
parameter  CHAR_WIDTH1  = 11'd40     ;           //字符区域宽度
//parameter  WHITE       = 24'hFFFFFF ;     		//背景色，白色
//parameter  BLACK       = 24'h0      ;     	    //字符颜色，黑色 
parameter WHITE  =  24'h00ff00;//背景色lvse
parameter BLACK   =  24'hFFFFFF;//字符颜色,baise

reg   [127:0]  char  [15:0] ;        //字符数组
reg   [4:0]  v_scale_t;
reg   [11:0] deci_rate_t;
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
            v_scale_t <= 5'b0;
            deci_rate_t <= 12'd13;
        end 
    else   begin 
          v_scale_t <= v_scale;
          deci_rate_t <= deci_rate;
   end
end 
assign  shuipin_en = (pixel_xpos >= (CHAR_POS_X - 1'd1))&&(pixel_xpos < (CHAR_POS_X - 1'd1 +CHAR_WIDTH))&&(pixel_ypos >= CHAR_POS_Y) && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT);
assign  chuizhi_en = (pixel_xpos >= (CHAR_POS_X1 - 1'd1))&&(pixel_xpos < (CHAR_POS_X1 - 1'd1 +CHAR_WIDTH1))&&(pixel_ypos >= CHAR_POS_Y) && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT);

always @(posedge lcd_pclk ) begin
    char[0] <= 128'h00000018244242424242424224180000 ;  // "0"
    char[1] <= 128'h000000107010101010101010107C0000 ;  // "1"
    char[2] <= 128'h0000003C4242420404081020427E0000 ;  // "2"
    char[3] <= 128'h0000003C424204180402024244380000 ;  // "3"
    char[4] <= 128'h000000040C14242444447E04041E0000 ;  // "4"
    char[5] <= 128'h0000007E404040586402024244380000 ;  // "5"
    char[6] <= 128'h0000001C244040586442424224180000 ;  // "6"
    char[7] <= 128'h0000007E444408081010101010100000 ;  // "7"
    char[8] <= 128'h0000003C4242422418244242423C0000 ;  // "8"
    char[9] <= 128'h0000001824424242261A020224380000 ;  // "9"
    char[10] <=128'h00000000000000C642424242463B0000 ;  //"u",
    char[11] <=128'h000000000000003E42403C02427C0000 ;//"s",
    char[12] <=128'h00000000000000FE4949494949ED0000 ;/*"m",0*/
    char[13] <=128'h00000000000000EE4444282810100000 ;/*"v",0*/
    char[14] <=128'h00008181814242424224242424180000 ;/*"V",0*/
    char[15] <=128'h00000000000000000000000000000000 ;//" ",0
end
//给不同的区域赋值不同的像素数据
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
        pixel_data <= WHITE;
    end
	else case(deci_rate_t)
       3:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //对应显示1us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd5)
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


    6:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //对应显示2us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[2][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd5)
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

    13:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //对应显示4us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[4][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd5)
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

    26:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //对应显示8us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[8][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd5)
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
       65:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //对应显示20us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[2][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd5)
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
    130:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //对应显示40us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[4][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd5)
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
       325:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //对应显示100us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd5)
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
    650:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //对应显示200us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[2][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd5)
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
    1625:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //对应显示500us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[5][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd5)
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
    3250:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //对应显示500us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[12][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd5)
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
     default:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //对应显示4us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //显示字符为黑色
            else
                pixel_data <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[4][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[10][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X - 1'b1))%11'd8) - 11'd1])
                pixel_data <= BLACK;
            else
                pixel_data <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X - 1'b1 + CHAR_WIDTH / 11'd5 * 11'd5)
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
    endcase 
end

   //给不同的区域赋值不同的像素数据
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
        pixel_data1 <= WHITE;
    end
	else case(v_scale_t)
    5'b00000:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //对应显示500mv  此时是默认无缩放下的20格子对应灵敏度（如果是10格子 默认无缩放是1v）
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[5][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //显示字符为黑色
            else
                pixel_data1 <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[12][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1))%11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd5)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[13][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else begin
		pixel_data1 <= WHITE;              //绘制屏幕背景为白色
	end

 
    5'b00010:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //对应显示1v 缩小一倍
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //显示字符为黑色
            else
                pixel_data1 <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[14][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1))%11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd5)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	
	else begin
		pixel_data1 <= WHITE;              //绘制屏幕背景为白色
	end

    5'b00100:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //对应显示2v 缩小4倍
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //显示字符为黑色
            else
                pixel_data1 <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[2][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[14][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1))%11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd5)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	
	else begin
		pixel_data1 <= WHITE;              //绘制屏幕背景为白色
	end
	5'b00110:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //对应显示4v 缩小8倍
	&& (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
	&& (pixel_ypos >= CHAR_POS_Y) 
	&& (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
	) begin
	if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
		- ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
		pixel_data1 <= BLACK;          //显示字符为黑色
	else
		pixel_data1 <= WHITE;          //显示字符区域背景为白色
end
else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd1) 
	&& (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd2)
	&& (pixel_ypos >= CHAR_POS_Y) 
	&& (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
	) begin
	if(char[4][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
		- ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
		pixel_data1 <= BLACK;
	else
		pixel_data1 <= WHITE;
end
else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5* 11'd2) 
	&& (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3)
	&& (pixel_ypos >= CHAR_POS_Y) 
	&& (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
	) begin
	if(char[14][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
		- ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
		pixel_data1 <= BLACK;
	else
		pixel_data1 <= WHITE;
end
else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3) 
	&& (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4)
	&& (pixel_ypos >= CHAR_POS_Y) 
	&& (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
	) begin
	if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
		- ((pixel_xpos-(CHAR_POS_X1 - 1'b1))%11'd8) - 11'd1])
		pixel_data1 <= BLACK;
	else
		pixel_data1 <= WHITE;
end
else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4) 
	&& (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd5)
	&& (pixel_ypos >= CHAR_POS_Y) 
	&& (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
	) begin
	if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
		- ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
		pixel_data1 <= BLACK;
	else
		pixel_data1 <= WHITE;
end

    else begin
    pixel_data1 <= WHITE;              //绘制屏幕背景为白色
    end
    5'b10010:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //对应显示250mv  放大一倍        
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[2][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //显示字符为黑色
            else
                pixel_data1 <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[5][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[12][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1))%11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd5)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[14][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	
	else begin
		pixel_data1 <= WHITE;              //绘制屏幕背景为白色
	end
	5'b10101:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //对应显示100mv 放大5倍
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //显示字符为黑色
            else
                pixel_data1 <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[12][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1))%11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd5)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[13][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	
	else begin
		pixel_data1 <= WHITE;              //绘制屏幕背景为白色
	end
    default :if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //对应显示500mv  此时是默认无缩放下的20格子对应灵敏度（如果是10格子 默认无缩放是1v）
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[5][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //显示字符为黑色
            else
                pixel_data1 <= WHITE;          //显示字符区域背景为白色
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd1) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd2)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5* 11'd2) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[0][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd3) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[12][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1))%11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else if((pixel_xpos >= CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd4) 
            && (pixel_xpos < CHAR_POS_X1 - 1'b1 + CHAR_WIDTH1 / 11'd5 * 11'd5)
            && (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[13][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;
            else
                pixel_data1 <= WHITE;
        end
	else begin
		pixel_data1 <= WHITE;              //绘制屏幕背景为白色
	end
       
    endcase 
end 

endmodule 






















