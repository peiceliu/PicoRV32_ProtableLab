module fre_fft_display(
    input             lcd_pclk  ,               //lcd����ʱ��
    input             sys_rst_n ,               //��λ�ź�
	input      [35:0] data_d0      ,
    input      [10:0] pixel_xpos,               //���ص������   ������ʱ����λ�����������ƴ��0���������ģ���λ��
    input      [10:0] pixel_ypos,               //���ص�������
    output            fre_en,
    output reg [23:0] pixel_data                //���ص�����
);
//parameter define
parameter  CHAR_POS_X  = 11'd171      ;           //�ַ�������ʼ�������    �޸����ʺ�ʾ��������ʾ
parameter  CHAR_POS_Y  = 11'd75      ;           //�ַ�������ʼ��������
parameter  CHAR_WIDTH  = 11'd176     ;           //�ַ�������
parameter  CHAR_HEIGHT = 11'd32    ;           //�ַ�����߶�
//parameter  WHITE       = 24'hFFFFFF ;     		//����ɫ����ɫ
//parameter  BLACK       = 24'h0      ;     	    //�ַ���ɫ����ɫ 
parameter WHITE  =  24'hffffff;//����ɫ��ɫ
parameter BLACK   = 24'h000000;//�ַ���ɫ,��ɫ
//reg define
reg     [511:0] char        [11:0]  ;           //�ַ�����
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
wire [3:0]      data0    ;            // ��λ��
wire [3:0]      data1    ;            // ʮλ��
wire [3:0]      data2    ;            // ��λ��
wire [3:0]      data3    ;            // ǧλ��
wire [3:0]      data4    ;            // ��λ��
wire [3:0]      data5    ;            // ʮ��λ��
wire [3:0]      data6    ;            // ����λ��
wire [3:0]      data7    ;            // ǧ��λ��
wire [3:0]      data8    ;            // ��λ��
//*****************************************************
//**                    main code
//*****************************************************
assign  data8 = data[35:32];    // ��λ��
assign  data7 = data[31:28];    // ǧ��λ��
assign  data6 = data[27:24];    // ����λ��
assign  data5 = data[23:20];    // ʮ��λ��
assign  data4 = data[19:16];    // ��λ��
assign  data3 = data[15:12];    // ǧλ��
assign  data2 = data[11:8];     // ��λ��
assign  data1 = data[7:4];      // ʮλ��
assign  data0 = data[3:0];      // ��λ��

//���ַ����鸳ֵ�����ڴ洢��ģ����
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

//����fre_en ����Ҫ��ǰһ�Ĳ��� ���ڸ�ֵһ�����һ����ʱ �����ڶ�Ӧ�����ؿ�Ҫ��һ  ����Y��1-16 x��150-237 11��16x8
assign  fre_en = (pixel_xpos >= (CHAR_POS_X - 1'd1))&&(pixel_xpos < (CHAR_POS_X - 1'd1 +CHAR_WIDTH))&&(pixel_ypos >= CHAR_POS_Y) && (pixel_ypos < CHAR_POS_Y + CHAR_HEIGHT);

//����ͬ������ֵ��ͬ����������
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
                pixel_data <= BLACK;          //��ʾ�ַ�Ϊ��ɫ
            else
                pixel_data <= WHITE;          //��ʾ�ַ����򱳾�Ϊ��ɫ
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
                - ((pixel_xpos-(CHAR_POS_X - 1'b1)) % 11'd16) - 11'd1])    //�������һ�¾Ͷ�ԭ���� �����൱��127-120Ϊ��һY �� x��Ӧ��8���� ������������Ϊ�ڶ�Y��������
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
		pixel_data <= WHITE;              //������Ļ����Ϊ��ɫ
	end
end

endmodule 