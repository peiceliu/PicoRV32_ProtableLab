module fenbianlv_s1_display(
    input             lcd_pclk,     //ʱ��
    input             sys_rst_n,        //��λ���͵�ƽ��Ч
    input      [4:0]  v_scale,      //�ı䴹ֱ
    input      [11:0] deci_rate,     //��Ӧ�ı�ˮƽ�ֱ���                    
    input      [10:0] pixel_xpos,   //���ص������
    input      [10:0] pixel_ypos,   //���ص������� 
    output            shuipin_en   ,   //��ʾˮƽ�ֱ���
    output            chuizhi_en   ,   //��ʾ��ֱ�ֱ���
    output reg [23:0] pixel_data,    //���ص����� ˮƽ
    output reg [23:0] pixel_data1    //���ص����� ��ֱ
); 
//parameter define
parameter  CHAR_POS_X  = 11'd350      ;           //�ַ�������ʼ�������    �޸����ʺ�ʾ��������ʾ  M:��������� HOR �������ֵ
parameter  CHAR_POS_Y  = 11'd446      ;           //�ַ�������ʼ��������
parameter  CHAR_WIDTH  = 11'd40     ;           //�ַ�������
parameter  CHAR_HEIGHT = 11'd16    ;           //�ַ�����߶�
parameter  CHAR_POS_X1  = 11'd470      ;           //�ַ�������ʼ�������
parameter  CHAR_WIDTH1  = 11'd40     ;           //�ַ�������
//parameter  WHITE       = 24'hFFFFFF ;     		//����ɫ����ɫ
//parameter  BLACK       = 24'h0      ;     	    //�ַ���ɫ����ɫ 
parameter WHITE  =  24'h00ff00;//����ɫlvse
parameter BLACK   =  24'hFFFFFF;//�ַ���ɫ,baise

reg   [127:0]  char  [15:0] ;        //�ַ�����
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
//����ͬ������ֵ��ͬ����������
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
        pixel_data <= WHITE;
    end
	else case(deci_rate_t)
       3:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //��Ӧ��ʾ1us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end


    6:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //��Ӧ��ʾ2us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end

    13:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //��Ӧ��ʾ4us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end

    26:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //��Ӧ��ʾ8us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end
       65:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //��Ӧ��ʾ20us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end
    130:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //��Ӧ��ʾ40us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end
       325:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //��Ӧ��ʾ100us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end
    650:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //��Ӧ��ʾ200us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[2][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end
    1625:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //��Ӧ��ʾ500us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[5][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end
    3250:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //��Ӧ��ʾ500us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end
     default:if((pixel_xpos >= CHAR_POS_X - 1'b1)   //��Ӧ��ʾ4us
            && (pixel_xpos < CHAR_POS_X - 1'b1  + CHAR_WIDTH / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd8) - 11'd1])
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end
    endcase 
end

   //����ͬ������ֵ��ͬ����������
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
        pixel_data1 <= WHITE;
    end
	else case(v_scale_t)
    5'b00000:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //��Ӧ��ʾ500mv  ��ʱ��Ĭ���������µ�20���Ӷ�Ӧ�����ȣ������10���� Ĭ����������1v��
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[5][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data1 <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data1 <= WHITE;              //������Ļ����Ϊ��ɫ
	end

 
    5'b00010:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //��Ӧ��ʾ1v ��Сһ��
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data1 <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data1 <= WHITE;              //������Ļ����Ϊ��ɫ
	end

    5'b00100:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //��Ӧ��ʾ2v ��С4��
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data1 <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data1 <= WHITE;              //������Ļ����Ϊ��ɫ
	end
	5'b00110:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //��Ӧ��ʾ4v ��С8��
	&& (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
	&& (pixel_ypos >= CHAR_POS_Y) 
	&& (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
	) begin
	if(char[15][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
		- ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
		pixel_data1 <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
	else
		pixel_data1 <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
    pixel_data1 <= WHITE;              //������Ļ����Ϊ��ɫ
    end
    5'b10010:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //��Ӧ��ʾ250mv  �Ŵ�һ��        
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[2][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data1 <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data1 <= WHITE;              //������Ļ����Ϊ��ɫ
	end
	5'b10101:if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //��Ӧ��ʾ100mv �Ŵ�5��
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[1][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data1 <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data1 <= WHITE;              //������Ļ����Ϊ��ɫ
	end
    default :if((pixel_xpos >= CHAR_POS_X1 - 1'b1)   //��Ӧ��ʾ500mv  ��ʱ��Ĭ���������µ�20���Ӷ�Ӧ�����ȣ������10���� Ĭ����������1v��
            && (pixel_xpos < CHAR_POS_X1 - 1'b1  + CHAR_WIDTH1 / 11'd5 * 11'd1)
			&& (pixel_ypos >= CHAR_POS_Y) 
            && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT)
            ) begin
            if(char[5][(CHAR_HEIGHT+CHAR_POS_Y - pixel_ypos) * 11'd8 
                - ((pixel_xpos-(CHAR_POS_X1 - 1'b1)) % 11'd8) - 11'd1])
                pixel_data1 <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data1 <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
		pixel_data1 <= WHITE;              //������Ļ����Ϊ��ɫ
	end
       
    endcase 
end 

endmodule 






















