`timescale 1ns / 1ps
`define UD #1
module hexin_shuanglu(
  
//hdmi_out 
    //output            pix_clk       ,//pixclk      �����Ѿ�������Ӧ�ĸ�ֵ����                     
    output  reg       vs_out        , //��
    output  reg       hs_out        , //��
    output  reg       de_out        ,
    output     [7:0]  r_out         , 
    output     [7:0]  g_out         , 
    output     [7:0]  b_out         ,
    input                                rst_n, 
    input                                lcd_pclk,
    input [10:0]                   pixel_xpos,
    input [10:0]                   pixel_ypos,
    input                                vs_in, 
    input                                hs_in, 
    input                                de_in,
    
    //�Լ��ӵĲ���    ���о��ǲο�������16λ�������� ��˴�rgb888��ͬ  ��Щ�˿���������ڲ�����ʾ���ֵĴ��� 
    input      [11:0]  wave_data,       //����(AD����)    �������˿��ڴ洢�������ֳ��� 
    output     [9:0]  wave_addr,       // ��ʾ��������Ӧram��ַ ֮ǰram��9λ�� ��Ҫ�޸�  ��Ҫ�ǿ���Ƶĺ��������ظ���
    input             outrange,           
    output            wave_data_req,   //�����Σ�AD������
    output            wr_over,         //���Ʋ������
    input      [9:0]  v_shift,         //������ֱƫ������bit[9]=0/1:����/���� 
    input      [9:0]  h_shift, 
    input      [4:0]  v_scale,         //������ֱ���ű�����bit[4]=0/1:��С/�Ŵ� 
    input      [8:0] trig_line,        //������ƽ  ����Ƕ�Ӧ������������  �˴����480 ��ʱ�޸�Ϊ9λ��

//�Լ��ӵĲ���    ���о��ǲο�������16λ�������� ��˴�rgb888��ͬ  ��Щ�˿���������ڲ�����ʾ���ֵĴ��� 
    input      [11:0]  wave_data_b,       //����(AD����)    �������˿��ڴ洢�������ֳ��� 
    output     [9:0]  wave_addr_b,       // ��ʾ��������Ӧram��ַ ֮ǰram��9λ�� ��Ҫ�޸�  ��Ҫ�ǿ���Ƶĺ��������ظ���
    input             outrange_b,           
    output            wave_data_req_b,   //�����Σ�AD������
    output            wr_over_b,         //���Ʋ������
    input      [9:0]  v_shift_b,         //������ֱƫ������bit[9]=0/1:����/���� 
    input      [4:0]  v_scale_b,         //������ֱ���ű�����bit[4]=0/1:��С/�Ŵ� 
    input      [8:0] trig_line_b,        //������ƽ  ����Ƕ�Ӧ������������  �˴����480 ��ʱ�޸�Ϊ9λ��
   //��ʾ�ַ� logo  Ƶ��/vpp/��ѹ
    input            fre_en,
    input      [23:0] pixel_data_fre,
    input             back_en,
    input      [23:0] pixel_data_back, 
   input          run_en,
   input          ch1_en,
   input          ch2_en,
   input          edge_en,
   input          vshift_en,
   input          hshift_en,
   input   [23:0] pixel_data_run,
   input   [23:0] pixel_data_ch1,
   input   [23:0] pixel_data_ch2,
   input   [23:0] pixel_data_edge,
   input   [23:0] pixel_data_v,                   
   input   [23:0] pixel_data_h ,               //��Ӧh_shift���ƶ���ʾ
    //��ʾˮƽ/��ֱ
    input            shuipin_en,
    input      [23:0] pixel_data_shuipin,
    input             chuizhi_en,
    input      [23:0] pixel_data_chuizhi,  
    input            v_en,
    input      [23:0] pixel_data_vol ,
//��ʾ�ַ� logo  Ƶ��/vpp/��ѹ
    input            fre_en_b,
    input      [23:0] pixel_data_fre_b,
    input             back_en_b,
    input      [23:0] pixel_data_back_b, 
   input          run_en_b,
   //input          ch1_en,
   //input          ch2_en,
   input          edge_en_b,
   input          vshift_en_b,
   input          hshift_en_b,
   input   [23:0] pixel_data_run_b,
   //input   [23:0] pixel_data_ch1,
  // input   [23:0] pixel_data_ch2,
   input   [23:0] pixel_data_edge_b,
   input   [23:0] pixel_data_v_b,                   
   input   [23:0] pixel_data_h_b ,               //��Ӧh_shift���ƶ���ʾ
    //��ʾˮƽ/��ֱ
    input            shuipin_en_b,
    input      [23:0] pixel_data_shuipin_b,
    input             chuizhi_en_b,
    input      [23:0] pixel_data_chuizhi_b,  
    input            v_en_b,
    input      [23:0] pixel_data_vol_b 
  
   );

//parameter define  
localparam WHITE  = 24'hffffff;     //RGB565 ��ɫ    ����RGB565תRGB888�Ĺ����ǶԵ��ϵ�
localparam BLUE   = 24'h66ffff;     //RGB565 ��ɫ
localparam GREEN  = 24'h00ff00;   
localparam BLACK  = 24'h000000; 
localparam RED    = 24'hff0000; 
//������Ʊ������� 800x480
localparam H_TOTAL = 11'd1056;
localparam V_TOTAL = 11'd525;
//reg define
reg  [15:0] pre_length1;
reg  [15:0] pre_length;//��;: �洢��һ���������ڵĲ��γ��Ȼ�ĳ���ض��ĳ���ֵ������԰����ڻ�����֡ʱ���бȽϻ��������жϡ�����: ����Ҫʱ����ʹ������Ĵ����������Ƿ���Ҫ���²������ݣ������ڴ���ͬ���ε�ʱ����ٵ�ǰ�Ļ���״̬��
reg         outrange_reg;
reg  [15:0] shift_length;//��;: �洢���ź��ε�ʵ�ʳ���ֵ��ͨ����������ݵ����ֵ�����������: �ڽ��в��λ���ʱ����Ҫ����������������������ȷ��ӳ�䲨�ε���ʾ����ϡ�
reg  [9:0]  v_shift_t;
reg  [4:0]  v_scale_t;
reg  [11:0] scale_length;//Ϊ����Ӧ12λ��AD�ļ��㹫ʽ
reg  [8:0] trig_line_t;//��;: ���ڴ洢�����ߵ�λ�ã������ܴ�����ͼ�еĲο��߻��ǡ����ֵͨ�������û����û�ͨ��ĳЩ�߼�����õ��ġ�����: ����ʾ����ʱ�����Ը�����������ߵ�ֵ��������ʾ�Ļ�׼�ߣ��Ӷ��ò���ͼ�Ľ����Ϊ������
reg  [23:0] pixel_data;
wire [15:0] draw_length;


//reg define
reg  [15:0] pre_length1_b;
reg  [15:0] pre_length_b;//��;: �洢��һ���������ڵĲ��γ��Ȼ�ĳ���ض��ĳ���ֵ������԰����ڻ�����֡ʱ���бȽϻ��������жϡ�����: ����Ҫʱ����ʹ������Ĵ����������Ƿ���Ҫ���²������ݣ������ڴ���ͬ���ε�ʱ����ٵ�ǰ�Ļ���״̬��
reg  [15:0] shift_length_b;//��;: �洢���ź��ε�ʵ�ʳ���ֵ��ͨ����������ݵ����ֵ�����������: �ڽ��в��λ���ʱ����Ҫ����������������������ȷ��ӳ�䲨�ε���ʾ����ϡ�
reg  [9:0]  v_shift_t_b;
reg  [4:0]  v_scale_t_b;
reg  [11:0] scale_length_b;//Ϊ����Ӧ12λ��AD�ļ��㹫ʽ
reg  [8:0] trig_line_t_b;//��;: ���ڴ洢�����ߵ�λ�ã������ܴ�����ͼ�еĲο��߻��ǡ����ֵͨ�������û����û�ͨ��ĳЩ�߼�����õ��ġ�����: ����ʾ����ʱ�����Ը�����������ߵ�ֵ��������ʾ�Ļ�׼�ߣ��Ӷ��ò���ͼ�Ľ����Ϊ������
wire [15:0] draw_length_b;
reg         outrange_reg_b;
//*****************************************************
//**                    main code
//*****************************************************

assign r_out = pixel_data[23:16];
assign g_out = pixel_data[15:8];
assign b_out = pixel_data[7:0];

// �������������ź�
assign wave_data_req = ((pixel_xpos >= 11'd49 - 1'b1-1'b1) && (pixel_xpos < 11'd549 - 1-1)  //����߽�����
                         && (pixel_ypos >= 11'd29) && (pixel_ypos < 11'd430)) 
                       ? 1'b1 : 1'b0;
// �������������ź�
assign wave_data_req_b = ((pixel_xpos >= 11'd49 - 1'b1-1'b1) && (pixel_xpos < 11'd549 - 1-1)  //����߽�����
                         && (pixel_ypos >= 11'd29) && (pixel_ypos < 11'd430)) 
                       ? 1'b1 : 1'b0;

/*
assign wave_data_req = ((pixel_xpos >= 11'd49 - 1'b1) && (pixel_xpos < 11'd549 - 1)  
                         && (pixel_ypos >= 11'd49) && (pixel_ypos < 11'd450)) 
                       ? 1'b1 : 1'b0;
*/
// ������ʾ��X�������������RAM�еĵ�ַ
assign wave_addr = wave_data_req ? (pixel_xpos - (11'd49-1'b1-1'b1)) : 10'd0;
// ������ʾ��X�������������RAM�еĵ�ַ
assign wave_addr_b = wave_data_req_b ? (pixel_xpos - (11'd49-1'b1-1'b1)) : 10'd0;

// ��־һ֡���λ������
assign wr_over  = (pixel_xpos == 11'd549) && (pixel_ypos == 11'd429);
// ��־һ֡���λ������
assign wr_over_b  = (pixel_xpos == 11'd549) && (pixel_ypos == 11'd429);

//�Ĵ�����Ĳ���
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n) begin
        v_shift_t <= 10'b0;
        v_scale_t <= 5'b0;
        trig_line_t <= 9'b0;
    end    
    else begin
        v_shift_t <= v_shift;
        v_scale_t <= v_scale;
        trig_line_t <= trig_line;    
    end
end
//�Ĵ�����Ĳ���
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n) begin
        v_shift_t_b <= 10'b0;
        v_scale_t_b <= 5'b0;
        trig_line_t_b <= 9'b0;
    end    
    else begin
        v_shift_t_b <= v_shift_b;
        v_scale_t_b <= v_scale_b;
        trig_line_t_b <= trig_line_b;    
    end
end


always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n)begin
        vs_out <= 1'b0;
        hs_out <= 1'b0;
        de_out <= 1'b0;
    end
    else begin
        vs_out <= `UD vs_in;
        hs_out <= `UD hs_in;
        de_out <= `UD de_in;
    end
end 

//��ֱ�����ϵ�����
always @(*) begin
    if(v_scale_t[4])   //�Ŵ�
        scale_length = ((wave_data>>4)* v_scale_t[3:0]-((9'd128*v_scale_t[3:0])-9'd128));
    else               //��С
        scale_length = ((wave_data>>4) >> v_scale_t[3:1])+(128-(128>>v_scale_t[3:1]));
end


//�Բ��ν�����ֱ������ƶ�
always @(*) begin
    if(v_shift_t[9]) begin  //����
        if(scale_length >= 12'd2048) 
            shift_length = v_shift_t[8:0]+9'd20-(~{4'hf,scale_length}+1'b1);
        else
            shift_length = scale_length+v_shift_t[8:0]+9'd20;
    end
    else begin              //����
        if(scale_length >= 12'd2048) 
            shift_length = 16'd0;
        else if(scale_length+9'd20 <= v_shift_t[8:0])
            shift_length = 16'd0;
        else
            shift_length = scale_length+9'd20-v_shift_t[8:0];
    end    
end

//����������
assign draw_length = shift_length[15] ? 16'd0 : shift_length;
//�Ĵ�ǰһ�����ص�������꣬���ڸ���֮������� ���߻��ƣ������ǰһ�������Ϣ�������ڻ��Ʋ���ͼ�е����ߣ�ʹ�ò�����LCD��Ļ�ϸ���������������
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n) begin
        pre_length <= 16'd0;
        pre_length1 <= 16'd0;
    end
    else 
    if((pixel_xpos >= 11'd48)  && (pixel_xpos < 11'd548 )  && (pixel_ypos >= 11'd29) && (pixel_ypos < 11'd430)) begin
        pre_length <= (draw_length*25)/16;
        pre_length1 <= pre_length;
    end
end



//�Ĵ�outrange,����ˮƽ�����ƶ�ʱ�������ұ߽�
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n)
        outrange_reg <= 1'b0;
    else 
        outrange_reg <= outrange;
end

//��ֱ�����ϵ�����
always @(*) begin
    if(v_scale_t_b[4])   //�Ŵ�
        scale_length_b = ((wave_data_b>>4)* v_scale_t_b[3:0]-((9'd128*v_scale_t_b[3:0])-9'd128));
    else               //��С
        scale_length_b = ((wave_data_b>>4) >> v_scale_t_b[3:1])+(128-(128>>v_scale_t_b[3:1]));
end


//�Բ��ν�����ֱ������ƶ�
always @(*) begin
    if(v_shift_t_b[9]) begin  //����
        if(scale_length_b >= 12'd2048) 
            shift_length_b = v_shift_t_b[8:0]+9'd20-(~{4'hf,scale_length_b}+1'b1);
        else
            shift_length_b = scale_length_b+v_shift_t_b[8:0]+9'd20;
    end
    else begin              //����
        if(scale_length_b >= 12'd2048) 
            shift_length_b = 16'd0;
        else if(scale_length_b+9'd20 <= v_shift_t_b[8:0])
            shift_length_b = 16'd0;
        else
            shift_length_b = scale_length_b+9'd20-v_shift_t_b[8:0];
    end    
end

//����������
assign draw_length_b = shift_length_b[15] ? 16'd0 : shift_length_b;
//�Ĵ�ǰһ�����ص�������꣬���ڸ���֮������� ���߻��ƣ������ǰһ�������Ϣ�������ڻ��Ʋ���ͼ�е����ߣ�ʹ�ò�����LCD��Ļ�ϸ���������������
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n) begin
        pre_length_b <= 16'd0;
        pre_length1_b <= 16'd0;
    end
    else 
    if((pixel_xpos >= 11'd48)  && (pixel_xpos < 11'd548 )  && (pixel_ypos >= 11'd29) && (pixel_ypos < 11'd430)) begin
        pre_length_b <= (draw_length_b*25)/16;
        pre_length1_b <= pre_length_b;
    end
end

//�Ĵ�outrange,����ˮƽ�����ƶ�ʱ�������ұ߽�
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n)
        outrange_reg_b <= 1'b0;
    else 
        outrange_reg_b <= outrange_b;
end


reg grid;
reg grid1;

//������Ʊ�������  Ȼ����ڲ��κ��ַ�����ʾ ����assign+�ж���� �������ǽ����ڱ�����ʾ�Ļ�����

reg [10:0] h_cnt;
reg [10:0] v_cnt;

//�м�����������ʱ�Ӽ���
always@ (posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        h_cnt <= 11'd0;
    else begin
        if(h_cnt == H_TOTAL - 1'b1)
            h_cnt <= 11'd0;
        else
            h_cnt <= h_cnt + 1'b1;           
    end
end
//�����������м���
always@ (posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n) 
        v_cnt <= 11'd0;
    else begin
        if(h_cnt == H_TOTAL - 1'b1) begin
            if(v_cnt == V_TOTAL - 1'b1)
                v_cnt <= 11'd0;
            else
                v_cnt <= v_cnt + 1'b1;    
        end
    end    
end
//������49-549��ÿ�θ�20��һ��  ���ǳ������Ľ���ֵ  3.25��Ӧ1us ������49-449 ��40     �м��ˮƽ������  h_cnt = 515 v_cnt=284        216����Ӧ������Ӧ����215��  35
always@(*)begin
       if((h_cnt >= 265 ) && (h_cnt <= 765) && (v_cnt>= 64) && (v_cnt <= 464))begin    
			if((h_cnt == 265) || (h_cnt == 285) || (h_cnt == 305) || (h_cnt == 325) 
			|| (h_cnt == 345) || (h_cnt == 365) || (h_cnt == 385) || (h_cnt == 405) 
			|| (h_cnt == 425) || (h_cnt == 445) || (h_cnt == 465) || (h_cnt == 485) || (h_cnt == 505) || (h_cnt == 525) 
            || (h_cnt == 545) || (h_cnt == 565) || (h_cnt == 585) || (h_cnt == 605) || (h_cnt == 625) || (h_cnt == 645)
            || (h_cnt == 665) || (h_cnt == 685) || (h_cnt == 705) || (h_cnt == 725) || (h_cnt == 745) || (h_cnt == 765)
			|| (v_cnt == 84) || (v_cnt == 104) || (v_cnt == 124) || (v_cnt == 144) 
            || (v_cnt == 164) || (v_cnt == 184) || (v_cnt == 204) || (v_cnt == 224) || (v_cnt == 244)
			|| (v_cnt == 284) || (v_cnt== 304) || (v_cnt == 324) || (v_cnt== 344) || (v_cnt == 364) || (v_cnt == 384)
            || (v_cnt == 404) || (v_cnt== 424) || (v_cnt == 444) || (v_cnt== 464) || (v_cnt == 64) )
				grid = 1;                           //��ֱ20���� 500mv           ˮƽ25���� ˮƽ�ֱ������� 
			else
				grid = 0;	
		end
		else
			grid = 0;        
end
//Ŀǰ������ƽ��249+34=283 �е�������284���Ѵ�����ƽ��Ϊ249����������250+34�ö��ϱ�����284����  ����ôŪ ���о���1v  2v���ǲ���Ӧ�û��ڴ�����ƽ������ �����Ǹ��ݱ����� ȷʵӦ���Ǹ��ݴ�����ƽ����1v 2v �����Ź�׼ȷ
always@(*)begin
    if((h_cnt >= 265 ) && (h_cnt <= 765) && (v_cnt>= 64) && (v_cnt <= 464))begin
     if((h_cnt == 515) ||(v_cnt == 264))
           grid1 = 1;
     else 
           grid1 = 0;
    end 
    else 
           grid1 = 0;
end 
/*
 if(((pixel_ypos >= pre_length) && (pixel_ypos <= draw_length))
                    ||((pixel_ypos <= pre_length)&&(pixel_ypos >= draw_length)))
            pixel_data <= RED;     //��ʾ����
*/
//���ݶ�����ADֵ������Ļ�ϻ��                            //Ŀǰ�ݶ�ui_pixel_dataΪ������ʾ�������ַ� ͼƬlogo �����ߣ�����������ʾ�˴��Ѿ�����������  ���õ�����ʾ����
                                                       // Ƶ�� ���ֵ ��ô��̬��ʾ�������ο�rtcʵʱʱ��)��ͬʱ�ڻ������߿��Զ���������֮������� // �����л�ָʾ ����/��ͣ ���� �ƶ� �ݶ�Ϊ��������λ�� ��ô������Ļ�϶�Ӧ��ʾ��һ������
 //��ʾ���ȼ� �ɲο�case����д�� ���о��Ǹо�������ʱ����ƱȽϺ���� �˴�ѡ��ʱ�� �������ڳ����̿��ܻ�����⣬�˴���ʱ�����ǡ� ���еĻ����Կ��Ǹ�Ϊ���
always @(posedge lcd_pclk or negedge rst_n)begin
    if(!rst_n)
        pixel_data <= BLACK;
   // else  if(outrange_reg || outrange)    //����������ʾ��Χ
        //pixel_data <= WHITE; //��ʾUI����(�˴���Ϊ���־ֲ�������    
    else if((pixel_xpos > (11'd49)) && (pixel_xpos < (11'd549 ) ) &&                 //������ڲ�����ʾ��Χ��51-549
                   (pixel_ypos >= 11'd29) && (pixel_ypos < 11'd430)) begin
        if(((pixel_ypos >= pre_length1) && (pixel_ypos <= pre_length))
                    ||((pixel_ypos <= pre_length1)&&(pixel_ypos >= pre_length)))
            pixel_data <= BLUE;     //��ʾ����
        else if(((pixel_ypos >= pre_length1_b) && (pixel_ypos <= pre_length_b))
                    ||((pixel_ypos <= pre_length1_b)&&(pixel_ypos >= pre_length_b)))
            pixel_data <= GREEN;     //��ʾ����
        else if(((v_shift_b[9] == 1'b1) && (pixel_ypos == trig_line_t_b + ((v_shift_b[8:0]*25)/16)))|| ((v_shift_b[9] == 1'b0) && (pixel_ypos == trig_line_t_b - ((v_shift_b[8:0]*25)/16)))) 
            pixel_data <= GREEN;      //��ʾ������
        else  if(((v_shift[9] == 1'b1) && (pixel_ypos == trig_line_t + ((v_shift[8:0]*25)/16)))|| ((v_shift[9] == 1'b0) && (pixel_ypos == trig_line_t - ((v_shift[8:0]*25)/16)))) 
            pixel_data <= RED;      //��ʾ������
          else if(grid)
           pixel_data <= WHITE;
        else if(grid1)
           pixel_data <= BLUE;
        else 
            pixel_data <= BLACK;
      end 
 
   else if(v_en)  //��������жϵĻ� ��Ӧ����չʾӦ�û����ӳ�һ�� ��ͼ�������һ��
           pixel_data <= pixel_data_vol;
   else if(back_en)
           pixel_data <= pixel_data_back;
   else if(fre_en)
           pixel_data <= pixel_data_fre;
   else if(shuipin_en)
           pixel_data <= pixel_data_shuipin;
   else if(chuizhi_en)
           pixel_data <= pixel_data_chuizhi;
   else if(run_en)
           pixel_data <= pixel_data_run;
   else if(ch1_en)
           pixel_data <= pixel_data_ch1;
   else if(ch2_en)
           pixel_data <= pixel_data_ch2;
   else if(vshift_en)
           pixel_data <= pixel_data_v;
   else if(hshift_en)
           pixel_data <= pixel_data_h;
   else if(edge_en)
           pixel_data <= pixel_data_edge;
 
   else if(( h_cnt == 265 ) && (v_cnt>= 64) && (v_cnt <= 464))
           pixel_data <= WHITE;
/*
   else if(( h_cnt > 245 ) && (h_cnt <= 265) && ((v_cnt == 84) || (v_cnt == 104) || (v_cnt == 124) || (v_cnt == 144) 
            || (v_cnt == 164) || (v_cnt == 184) || (v_cnt == 204) || (v_cnt == 224) || (v_cnt == 244)
			|| (v_cnt == 264) || (v_cnt== 304) || (v_cnt == 324) || (v_cnt== 344) || (v_cnt == 364) || (v_cnt == 384)
            || (v_cnt == 404) || (v_cnt== 424) || (v_cnt == 444) || (v_cnt== 464) || (v_cnt == 64)))
           pixel_data <= WHITE;
*/
  else if(v_en_b)  //��������жϵĻ� ��Ӧ����չʾӦ�û����ӳ�һ�� ��ͼ�������һ��
           pixel_data <= pixel_data_vol_b;
   else if(back_en_b)
           pixel_data <= pixel_data_back_b;
   else if(fre_en_b)
           pixel_data <= pixel_data_fre_b;
   else if(shuipin_en_b)
           pixel_data <= pixel_data_shuipin_b;
   else if(chuizhi_en_b)
           pixel_data <= pixel_data_chuizhi_b;
   else if(run_en_b)
           pixel_data <= pixel_data_run_b;
   else if(vshift_en_b)
           pixel_data <= pixel_data_v_b;
   else if(hshift_en_b)
           pixel_data <= pixel_data_h_b;
   else if(edge_en_b)
           pixel_data <= pixel_data_edge_b;
   else 
          pixel_data <= BLACK;
end        

endmodule