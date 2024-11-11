module hdmia_topa(
    input            pix_clk       ,//pixclk     
    input            rstn_out      ,
    input [10:0]                   pixel_posx,
    input [10:0]                   pixel_posy,
    input                                vs_in, 
    input                                hs_in, 
    input                                de_in,                      
      output            vs_out        , //��
      output            hs_out        , //��
      output            de_out        ,
      output     [7:0]  r_out         , 
      output     [7:0]  g_out         , 
      output     [7:0]  b_out         ,
//��ѹ�� Ҫ��ʾ��Щ���� ����Ҫ����HDMI����� ������para_measure
    input         data_symbol      ,//��ѹֵ����λ������ѹ���λ��ʾ����,����ѹ��ʾ�ո�
	input  [7:0]  data_percentiles ,//��ѹֵС�����ڶ�λ      
	input  [7:0]  data_decile      ,//��ѹֵС������һλ     
	input  [7:0]  data_units       ,//��ѹֵ�ĸ�λ��        
	input  [7:0]  data_tens       ,  //��ѹֵ��ʮλ��    
 //Ƶ��
    input [35:0]    bcd_data,    //����Ƶ��ֵ ����BCDת����Щ 
  //vpp
    input  [7:0]  data_percentilesvpp ,//��ѹֵС�����ڶ�λ      
	input  [7:0]  data_decilevpp      ,//��ѹֵС������һλ     
	input  [7:0]  data_unitsvpp       ,//��ѹֵ�ĸ�λ��        
	input  [7:0]  data_tensvpp        , //��ѹֵ��ʮλ��  

    input      [9:0]  v_shift,         //������ֱƫ������bit[9]=0/1:����/���� 
    input      [9:0]  h_shift, 
    input      [4:0]  v_scale,         //������ֱ���ű�����bit[4]=0/1:��С/�Ŵ� 
    input      [8:0]  trig_line,        //�����߲�ͬ�ڴ�����ƽ  ����Ƕ�Ӧ������������  �˴����480 ��ʱ�޸�Ϊ9λ��
     // �ⲿ���Ʋ����洢
     input                 grid_choose,
     input       [1:0]     ch_choose,
     input      [11:0]     deci_rate, 
     input      [11:0]    trig_level, // ������ƽ ��Դ��data_store����
     input               trig_edge,  // ��������
     input               wave_run ,  // ���βɼ�����/ֹͣ
//�Լ��ӵĲ���    ���о��ǲο�������16λ�������� ��˴�rgb888��ͬ  ��Щ�˿���������ڲ�����ʾ���ֵĴ���  Ҫȥ��Ӧʾ�������������·������ģ����������洢��ȡ
    input      [11:0]  wave_data,       //����(AD����)    �������˿��ڴ洢�������ֳ��� 
    output     [9:0]  wave_addr,       // ��ʾ��������Ӧram��ַ ֮ǰram��9λ�� ��Ҫ�޸�  ��Ҫ�ǿ���Ƶĺ��������ظ���
    input             outrange,           
    output            wave_data_req,   //�����Σ�AD������
    output            wr_over         //���Ʋ������
);
wire shuipincaiyang_en ;
wire chuizhifudu_en    ;
wire [23:0] pixel_data_caiyang ;       
wire [23:0] pixel_data_fudu  ;     

//��ʾƵ�ʰ��
    wire fre_en;
    wire [23:0] pixel_data_fre;
    
    fre_display fre_display_isnt(
        .lcd_pclk(pix_clk)  ,               //����ʱ��
        .sys_rst_n(rstn_out) ,               //��λ�ź�
        .data_d0(bcd_data)      ,
        .pixel_xpos(pixel_posx),               //���ص������   ������ʱ����λ�����������ƴ��0���������ģ���λ��
        .pixel_ypos(pixel_posy),               //���ص�������
        .fre_en(fre_en),
        .pixel_data(pixel_data_fre)                //���ص�����
    );
    
    //��ʾ��ѹ���
    wire v_en;
    wire [23:0] pixel_data_vol;
    voltage_display voltage_display_inst(
        .lcd_pclk(pix_clk)          ,
        .rst_n(rstn_out)              ,
        
        .data_symbol(data_symbol)        , //��ѹֵ����λ������ѹ���λ��ʾ���� ,��ֵ��ʾ�ո�                 
        .data_percentiles(data_percentiles)   , //��ѹֵС�����ڶ�λ                                
        .data_decile(data_decile)  , //��ѹֵС������һλ                                
        .data_units(data_units)   , //��ѹֵ�ĸ�λ��                                   
        .data_tens(data_tens)    , //��ѹֵ��ʮλ��  
        
        .data_percentilesvpp(data_percentilesvpp)   , //��ѹֵС�����ڶ�λ                                
        .data_decilevpp(data_decilevpp)       , //��ѹֵС������һλ                                
        .data_unitsvpp(data_unitsvpp)         , //��ѹֵ�ĸ�λ��                                   
        .data_tensvpp(data_tensvpp)          , //��ѹֵ��ʮλ��  
                      
        .pixel_xpos(pixel_posx)         , //���ص������
        .pixel_ypos(pixel_posy)         , //���ص�������
        .v_en(v_en)               , //���ں����ڶ���������ȼ�����ʾ��ѹ
        .pixel_data(pixel_data_vol)           //���ص�����
    );
    //�ַ���logo
    wire back_en;
    wire [23:0] pixel_data_back;
    
    hdmi_display hdmi_display_isnt(                                  //��ʾ�ַ���logo Ŀǰ������ӱ�������+���Σ������������ֿ��ܳ��ֵ��ӣ�����Ҫ��һ��ģ�鲢����Ҫ�ж����ȼ���
        . lcd_pclk(pix_clk),     //ʱ��
        . rst_n(rstn_out),        //��λ���͵�ƽ��Ч               
        . pixel_xpos(pixel_posx),   //���ص������
        . pixel_ypos(pixel_posy),   //���ص������� 
        . back_en(back_en)   ,   //��ʾ��Щ�̶�������ʹ�� 
        . pixel_data(pixel_data_back)    //���ص�����,
    );             
    wire shuipin_en;
    wire [23:0] pixel_data_shuipin;
    wire chuizhi_en;
    wire [23:0] pixel_data_chuizhi;
    fenbianlv_display fenbianlv_display_isnt(
        . lcd_pclk(pix_clk),     //ʱ��
        . sys_rst_n(rstn_out),        //��λ���͵�ƽ��Ч
        . v_scale(v_scale),      //�ı䴹ֱ
        . deci_rate(deci_rate),     //��Ӧ�ı�ˮƽ�ֱ���                    
        . pixel_xpos(pixel_posx),   //���ص������
        . pixel_ypos(pixel_posy),   //���ص������� 
        . shuipin_en(shuipin_en)   ,   //��ʾˮƽ�ֱ���
        . chuizhi_en(chuizhi_en)   ,   //��ʾ��ֱ�ֱ���
        . pixel_data(pixel_data_shuipin),    //���ص����� ˮƽ
        . pixel_data1(pixel_data_chuizhi)    //���ص����� ��ֱ
    ); 
    
    //������ʾ ������ʾ����+���� +��������displayģ���������ʾ �е��ӵĲ�����Ҫ�������ȼ�����
    
    wire           run_en;
    wire           ch1_en;
    wire           ch2_en;
    wire           edge_en;
    wire           vshift_en;
    wire           hshift_en;
    wire    [23:0] pixel_data_run;
    wire    [23:0] pixel_data_ch1;
    wire    [23:0] pixel_data_ch2;
    wire    [23:0] pixel_data_edge;
    wire    [23:0] pixel_data_v;                  
    wire    [23:0] pixel_data_h;                //��Ӧh_shift���ƶ���ʾ
 wire   grid_en;         
 wire   zdcf_en;         
 wire    auto_en;         
 wire [23:0]   pixel_data_zdcf; 
 wire [23:0]   pixel_data_auto; 
 wire [23:0]   pixel_data_grid; 
    
    hexin_display hexin_display_inst(
        .rst_n(rstn_out), 
        .lcd_pclk(pix_clk),
        .pixel_xpos(pixel_posx),
        .pixel_ypos(pixel_posy),
        .vs_in(vs_in), 
        .hs_in(hs_in), 
        .de_in(de_in),
        
        //�Լ��ӵĲ���    ���о��ǲο�������16λ�������� ��˴�rgb888��ͬ  ��Щ�˿���������ڲ�����ʾ���ֵĴ��� 
        . wave_data(wave_data),       //����(AD����)    �������˿��ڴ洢�������ֳ��� 
        . wave_addr(wave_addr),       // ��ʾ��������Ӧram��ַ ֮ǰram��9λ�� ��Ҫ�޸�  ��Ҫ�ǿ���Ƶĺ��������ظ���
        . outrange(outrange),           
        . wave_data_req(wave_data_req),   //�����Σ�AD������
        . wr_over(wr_over),         //���Ʋ������
        . v_shift(v_shift),         //������ֱƫ������bit[9]=0/1:����/���� 
        . v_scale(v_scale),         //������ֱ���ű�����bit[4]=0/1:��С/�Ŵ� 
        . trig_line(trig_line),        //������ƽ  ����Ƕ�Ӧ������������  �˴����480 ��ʱ�޸�Ϊ9λ��
       
        //��ʾ�ַ� logo  Ƶ��/vpp/��ѹ
        .fre_en(fre_en) ,
        .pixel_data_fre(pixel_data_fre),
        .back_en(back_en),
        .pixel_data_back(pixel_data_back), 
        .v_en(v_en),
        .pixel_data_vol(pixel_data_vol),  
        . shuipin_en(shuipin_en)   ,   //��ʾˮƽ�ֱ���
        . chuizhi_en(chuizhi_en)   ,   //��ʾ��ֱ�ֱ���
        . pixel_data_shuipin(pixel_data_shuipin),    //���ص����� ˮƽ
        . pixel_data_chuizhi(pixel_data_chuizhi),    //���ص����� ��ֱ
        .run_en         (run_en   )           ,
        .ch1_en         (ch1_en   )           ,
        .ch2_en         (ch2_en   )           ,
        .edge_en        (edge_en  )           ,
        .vshift_en      (vshift_en)           ,
        .hshift_en      (hshift_en)           ,
        .pixel_data_run (pixel_data_run )           ,
        .pixel_data_ch1 (pixel_data_ch1 )           ,
        .pixel_data_ch2 (pixel_data_ch2 )           ,
        .pixel_data_edge(pixel_data_edge)           ,
        .pixel_data_v   (pixel_data_v   )           ,                   
        .pixel_data_h     (pixel_data_h     )      ,     //��Ӧh_shift���ƶ���ʾ
        .grid_choose(grid_choose),
         .grid_en(grid_en),         
         .zdcf_en(zdcf_en),         
         .auto_en(auto_en),         
         .pixel_data_zdcf(pixel_data_zdcf), 
         .pixel_data_auto(pixel_data_auto), 
         .pixel_data_grid(pixel_data_grid), 
           .shuipincaiyang_en (shuipincaiyang_en )  ,  
           .chuizhifudu_en    (chuizhifudu_en    ) ,  
           .pixel_data_caiyang       (pixel_data_caiyang   )  ,         
           .pixel_data_fudu      (pixel_data_fudu      ) ,   
        .vs_out(vs_out), 
        .hs_out(hs_out), 
        .de_out(de_out),
        .r_out(r_out), 
        .g_out(g_out), 
        .b_out(b_out)
       );
     biankuang_display biankuang_display_isnt(
        .lcd_pclk(pix_clk)  ,               //lcd����ʱ��
        .sys_rst_n(rstn_out) ,               //��λ�ź�
        .wave_run(wave_run)      ,
        .v_shift(v_shift),         //������ֱƫ������bit[9]=0/1:����/���� 
        .h_shift(h_shift), 
        //.v_scale(),         //������ֱ���ű�����bit[4]=0/1:��С/�Ŵ� 
        .trig_edge(trig_edge),  // ��������
        .ch_choose(ch_choose),  //ͨ��ѡ��
        .pixel_xpos(pixel_posx),               //���ص������   ������ʱ����λ�����������ƴ��0���������ģ���λ��
        .pixel_ypos(pixel_posy),               //���ص�������
 .grid_choose(grid_choose),
 .auto(1'b0),
        .run_en         (run_en   )           ,
        .ch1_en         (ch1_en   )           ,
        .ch2_en         (ch2_en   )           ,
        .edge_en        (edge_en  )           ,
        .vshift_en      (vshift_en)           ,
        .hshift_en      (hshift_en)           ,
         .grid_en(grid_en),         
         .zdcf_en(zdcf_en),         
         .auto_en(auto_en),         
         .pixel_data_zdcf(pixel_data_zdcf), 
         .pixel_data_auto(pixel_data_auto), 
         .pixel_data_grid(pixel_data_grid), 
        .pixel_data_run (pixel_data_run )           ,
        .pixel_data_ch1 (pixel_data_ch1 )           ,
        .pixel_data_ch2 (pixel_data_ch2 )           ,
        .pixel_data_edge(pixel_data_edge)           ,
        .pixel_data_v   (pixel_data_v   )           ,                   
        .pixel_data_h     (pixel_data_h     )           //��Ӧh_shift���ƶ���ʾ
       );

div_display_aaaaa div_displayaaa_inst (
   .lcd_pclk(pix_clk),     //ʱ��
   .sys_rst_n(rstn_out),        //��λ���͵�ƽ��Ч
   .v_scale(v_scale),      //�ı䴹ֱ
   .deci_rate(deci_rate),     //��Ӧ�ı�ˮƽ�ֱ���                    
   .pixel_xpos(pixel_posx),   //���ص������
   .pixel_ypos(pixel_posy),   //���ص������� 
   .shuipincaiyang_en (shuipincaiyang_en )  ,  
   .chuizhifudu_en    (chuizhifudu_en    ) ,  
   .pixel_data        (pixel_data_caiyang   )  ,         
   .pixel_data1       (pixel_data_fudu      )      
); 

endmodule