module FFT(
    input  [11:0]  ad_data,
    input          ad_clk,
    input          pix_clk,
    input          out_vsync,
    input          wave_done,
    input          sys_rst_n,
    input          sys_clk,
    input  [35:0]  bcd_data,
    input          data_req,
    output [35:0]  bcd_data_fft,
    output [7:0]  fft_point_cnt,
    output [11:0] fft_data_out,
    output [11:0] FREQ_ADJ,
    input         fft_point_done
   );


wire [11:0] ad_data_out;
wire [7:0]  fft_addr_in;
wire        fft_data_in_en;
wire       fft_data_out_last;
wire       fft_done;
wire [7:0] ram_waddr_max1;  
wire [7:0] ram_waddr_max2;
wire        s_axis_data_tready;
wire [7:0]  ram_waddr_max;
assign  bcd_data_fft = bcd_data;
ad_fft ad_fft_isnt(
    .ad_clk(ad_clk),          	//ad����ʱ��
	.ad_data_in(ad_data),      	//AD��������
    .s_axis_data_tready(s_axis_data_tready), //fft����ͨ��׼������ź�? 
    .in_vsync(out_vsync),       	//֡ͬ��������Ч ��������ʾ������������  ������ʱ������Ҫ�� ��������ɾ�����ź�
    .wave_done(wave_done),
    .cnt_ram_wr_en(fft_addr_in),	//ramдʹ�ܼ�����
    .ram_wr_en(fft_data_in_en),			//ramдʹ��
    .sys_rst_n(sys_rst_n),
    .FREQ_ADJ(FREQ_ADJ),
    .bcd_data_fft(bcd_data_fft),
    .fft_done(fft_done)                ,
    .ram_waddr_max(ram_waddr_max)    , 
    // .ram_waddr_max2(ram_waddr_max2)    ,     
    .ad_data_out(ad_data_out)        //adc�������?
   );


fft_top fft_top_inst(
  .clk(sys_clk)                     ,
  .rst_n(sys_rst_n)                   ,
  .fft_data_in(ad_data_out)             ,
  .fft_addr_in(fft_addr_in)             ,
  .fft_data_in_en(fft_data_in_en)       ,
  .ad_clk(ad_clk)                  ,
  .s_axis_data_tready(s_axis_data_tready)      ,
  .fft_data_out_en(data_req)         ,   // ��Ӧdata_req
  .fft_point_done(fft_point_done)          , //FFT ��ǰƵ�׻������?
  .fft_data_out_last(fft_data_out_last)       ,   //fft_eop
  .fft_data_out(fft_data_out)            ,   
  .fft_addr_out(fft_point_cnt)            ,   //fft_point_cnt
  .hdmi_clk(pix_clk)                ,
  .fft_done(fft_done)                ,        //����fft�������?
  .ram_waddr_max1(ram_waddr_max1)          ,   //��Ƶ
  .ram_waddr_max2(ram_waddr_max2)         ,     //��Ƶ
  .ram_waddr_max(ram_waddr_max)     
);  


endmodule