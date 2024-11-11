module hdmi_fft(
    input             pix_clk       ,
    input             rstn_out      ,
    output            vs_out        , //��
    output            hs_out        , //��
    output            de_out        ,
    input            vs        ,
    input            hs        ,
    input            de        ,
    output     [7:0]  r_out         , 
    output     [7:0]  g_out         , 
    output     [7:0]  b_out         ,
    input      [10:0] act_x         ,
    input      [10:0] act_y         ,
    input      [1:0]       wave_choose   ,//ѡ��ʱ���� ��Ĭ��00
    input      [35:0]      bcd_data,
    input      [11:0]      FREQ_ADJ ,
    output                wave_done,
    output                data_req,
    input     [11:0]      fft_data,
    input     [7:0]       fft_point_cnt,
    output                fft_point_done
);
    
wire back_en;
wire [23:0] pixel_data_back;
wire wave_en;
wire [23:0] pixel_data_wave;

back_fft_display back_fft_display_inst(                                  //��ʾ�ַ���logo Ŀǰ������ӱ�������+���Σ������������ֿ��ܳ��ֵ��ӣ�����Ҫ��һ��ģ�鲢����Ҫ�ж����ȼ���
   .lcd_pclk(pix_clk),     //ʱ��
   .rst_n(rstn_out),        //��λ���͵�ƽ��Ч             
   .pixel_xpos(act_x),     //��ǰ���ص������
   .pixel_ypos(act_y),     //��ǰ���ص�������  
   .wave_en(wave_en)   ,   //��ʾ��Щ�̶�������ʹ�� 
   .wave_choose(wave_choose),
   .pixel_data_wave(pixel_data_wave),    //���ص�����,
   .back_en(back_en)   ,   //��ʾ��Щ�̶�������ʹ�� 
   .pixel_data(pixel_data_back)    //���ص�����,
);     
wire fre_en;
wire [23:0] pixel_data_fre;
fre_fft_display fre_fft_display_isnt(
    .lcd_pclk(pix_clk)  ,               //����ʱ��
    .sys_rst_n(rstn_out) ,               //��λ�ź�
	.data_d0(bcd_data)      ,
    .pixel_xpos(act_x),               //���ص������   ������ʱ����λ�����������ƴ��0���������ģ���λ��
    .pixel_ypos(act_y),               //���ص�������
    .fre_en(fre_en),
    .pixel_data(pixel_data_fre)                //���ص�����
);
wire fre_eq_diven;
wire [23:0] pixel_data_div;
hdmi_fft_display hdmi_fft_display_isnt(
    .lcd_pclk(pix_clk),       //ʱ��
    .rst_n(rstn_out),          //��λ���͵�ƽ��Ч
    .lcd_id(16'h7084),         //LCD��ID    
    .pixel_xpos(act_x),     //��ǰ���ص������
    .pixel_ypos(act_y),     //��ǰ���ص�������  
    .h_disp(11'd800),         //LCD��ˮƽ�ֱ���
    .v_disp(11'd480),         //LCD����ֱ�ֱ���   
    .wave_done(wave_done),
    // input video timing
    .vs_in                (  vs                   ),//input                         vn_in                        
    .hs_in                (  hs                   ),//input                         hn_in,                           
    .de_in                (  de                   ),//input                         dn_in,    
    .vs_out(vs_out), 
    .hs_out(hs_out), 
    .de_out(de_out),
    .r_out(r_out), 
    .g_out(g_out), 
    .b_out(b_out),
    .fre_eq_diven(fre_eq_diven),
    .pixel_data_div(pixel_data_div),                //���ص�����
    .fre_en(fre_en),
    .pixel_data_fre(pixel_data_fre),                //���ص�����
    .back_en(back_en)   ,   //��ʾ��Щ�̶�������ʹ�� 
    .pixel_data_back(pixel_data_back),    //���ص�����,
    .wave_en(wave_en)   ,   //��ʾ��Щ�̶�������ʹ�� 
    .pixel_data_wave(pixel_data_wave),    //���ص�����,
    .fft_point_cnt(fft_point_cnt),  //FFTƵ��λ��
    .fft_data(fft_data),       //FFTƵ�ʷ�ֵ  ��С16��
    .fft_point_done(fft_point_done), //FFT��ǰƵ�׻������
    .data_req(data_req)        //���������ź�
    );

fft_div_adaptive fft_div_adaptive_inst (
   .lcd_pclk(pix_clk)  ,               //lcd����ʱ��
   .sys_rst_n(rstn_out) ,               //��λ�ź�
	.data_d0(bcd_data) ,
   .pixel_xpos(act_x),               //���ص������   ������ʱ����λ�����������ƴ��0���������ģ���λ��
   .pixel_ypos(act_y),               //���ص�������
   .freq_adj(FREQ_ADJ),
   .fre_eq_diven(fre_eq_diven),
   .pixel_data(pixel_data_div)                //���ص�����
   );
endmodule