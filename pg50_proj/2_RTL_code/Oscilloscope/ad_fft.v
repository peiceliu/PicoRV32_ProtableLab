module ad_fft(
    input			ad_clk,          	//ad����ʱ��
	input  [11:0]	ad_data_in,      	//AD��������
    input			s_axis_data_tready, //fft����ͨ��׼������ź��? 
    input			in_vsync,       	//֡ͬ��������Ч ��������ʾ������������  ������ʱ������Ҫ�� ��������ɾ�����ź�
    output      reg  [8:0]  cnt_ram_wr_en,	//ramдʹ�ܼ�����
    output      reg  		ram_wr_en,			//ramдʹ��
    input           sys_rst_n,
    input           wave_done,
    input [35:0]  bcd_data_fft,
    input           fft_done    ,
    input          [7:0]                    ram_waddr_max          ,   //��Ƶ
    // input          [7:0]                    ram_waddr_max2           ,  //��Ƶ
    output reg  [11:0] FREQ_ADJ,
    output [11:0]	ad_data_out        //adc��������?
   );
reg 		in_vsync_t;			//֡ͬ�������ź�    ����ָʾдʹ�� ����һ֡��Ӧд����������? 
reg 		in_vsync_t0;		
reg 		in_vsync_t1;	
reg [11:0] ad_data_in_d0; //AD �������ݴ����ź�
reg [11:0] ad_data_in_d1;
reg  ram_wr_en_flag;
// reg [7:0] ram_waddr_max;


// always @(*) begin
//     if (ram_waddr_max1 >= ram_waddr_max2) begin
//         ram_waddr_max = ram_waddr_max1;
//     end else begin
//         ram_waddr_max = ram_waddr_max2;
//     end
// end 
//���������ݽ���ʱ����ͬ��
always @(posedge ad_clk or negedge sys_rst_n) begin
   if(sys_rst_n == 1'b0)begin
    in_vsync_t <= 1'b0;
    in_vsync_t0 <= 1'b0;
    in_vsync_t1 <= 1'b0;
    ad_data_in_d0 <= 12'd0; 
    ad_data_in_d1 <= 12'd0; 
end 
   else begin
    in_vsync_t <= in_vsync;
    in_vsync_t0 <= in_vsync_t;
    in_vsync_t1 <= in_vsync_t0;
    ad_data_in_d0 <= ad_data_in; 
    ad_data_in_d1 <= ad_data_in_d0; 
    end  
end
assign  ad_data_out = ad_data_in_d1;
always @(posedge ad_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
       ram_wr_en_flag <= 1'b0;
    else if(in_vsync_t0 && ~in_vsync_t1)
       ram_wr_en_flag <= 1'b1;
    else if(!wave_done)
     ram_wr_en_flag <= 1'b0;
end

//================== from ad_data_chanshen.v ==================================
 //  parameter  FREQ_ADJ = 12'd508;  //Ƶ�ʵ���,FREQ_ADJ��Խ��,���������Ƶ��Խ���?,��Χ0~4095 ��Ӧ���̶���60/KHZ
    // parameter  FREQ_ADJ = 12'd254;  ��Ӧ���̶��� 120/KHZ
   // parameter  FREQ_ADJ = 12'd127;  ��Ӧ���̶��� 240/KHZ
   // parameter  FREQ_ADJ = 12'd63;  ��Ӧ���̶��� 480/KHZ
   // parameter  FREQ_ADJ = 12'd30;  ��Ӧ���̶��� 1MHZ
  // parameter  FREQ_ADJ = 12'd15;  ��Ӧ���̶��� 2MHZ û��д
// parameter  FREQ_ADJ = 12'd5;  ��Ӧ���̶��� 6MHZ
  // parameter  FREQ_ADJ = 12'd2;  ��Ӧ���̶��� 15MHZ



   //reg define
   reg    [11:0]    freq_cnt  ;  //Ƶ�ʵ��ڼ�����
   reg    [26:0]    cnt_1s;
always @(posedge ad_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) 
       cnt_1s <= 27'd0;
    else if(cnt_1s == (27'd65000000 - 1))
       cnt_1s <= 27'd0;
    else 
       cnt_1s <= cnt_1s + 27'd1;
end 
/*
 reg    [49:0]    cnt_2s;
always @(posedge ad_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) 
       cnt_2s <= 50'd0;
    else if(cnt_2s == (50'd600000000 - 1))
       cnt_2s <= 50'd600000000 - 1 ;
    else 
       cnt_2s <= cnt_2s + 50'd1;
end 
wire [35:0] bcd_data_fft1;
assign bcd_data_fft1 = (cnt_2s < (50'd600000000 - 1))? 60000001 : 1000001;
*/
reg [35:0] data_d1;
reg [35:0] data_d2;
reg [35:0] data_d3   ;
reg [14:0] cnt;
reg [49:0] data_sum;
reg                                                             fft_done_r1             ;
reg                                                             fft_done_r2             ;
reg [35:0]  data;
always @(posedge ad_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
       data_d1 <= 36'd0;
       data_d2 <= 36'd0;
       data_d3 <= 36'd0;
    end 
    else begin
       data_d1 <=  bcd_data_fft;
       data_d2 <= data_d1;
       data_d3 <= data_d2;
    end 
end

always @(posedge ad_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
       cnt <= 15'd0;
    end 
   else if(cnt == 15'd16384)
       cnt <= 15'd0;
   else 
       cnt <= cnt+15'd1;
end 
always @(posedge ad_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)  begin
        data_sum <= 50'd0;
    end
    else if (data_d3 <= 10000000 && cnt <=15'd16383)
        data_sum <= data_sum + data_d3 ;
    else  if((cnt == 15'd16384) &&  (data_sum > 0) )begin
        data <= data_sum[49:14];
        data_sum <= 50'd0;
    end
    else  data_sum <= data_sum;
end

always @(posedge ad_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        fft_done_r2 <= 'd0;
        fft_done_r1 <= 'd0;
    end else begin
        fft_done_r2 <=  fft_done_r1;
        fft_done_r1 <=  fft_done;
    end
end



always @(posedge ad_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        FREQ_ADJ <= 12'h03f;
    else begin
        if (~fft_done_r2 && fft_done_r1) begin
//if(cnt_1s == (27'd650000 - 1))begin
//           if( (data >= 0) &&  (data <= 60000))
            if (ram_waddr_max < 'd40) begin
                FREQ_ADJ <= ((FREQ_ADJ << 'd1) + 'd1);
            end else if (ram_waddr_max > 'd80 && FREQ_ADJ != 'd1) begin
                FREQ_ADJ <= (FREQ_ADJ >> 'd1);
            end
        end
    end
end 




//                 FREQ_ADJ <= 12'd508;
//        else if( (data > 60000) &&  (data <= 120000))
//                 FREQ_ADJ <= 12'd254;
//        else if( (data > 120000) &&  (data <= 240000))
//                 FREQ_ADJ <= 12'd127;
//        else if( (data > 240000) &&  (data <= 480000))
//                 FREQ_ADJ <= 12'd63;
//        else if( (data > 480000) &&  (data <= 1000000))
//                 FREQ_ADJ <= 12'd30;
       // else if( (data > 1000000) &&  (data <= 2000000))
                 //FREQ_ADJ <= 12'd15;
//        else if( (data > 1000000) &&  (data <= 6000000))
//                 FREQ_ADJ <= 12'd5;
 //      else if( (data > 6000000) &&  (data <= 10000000))
 //                FREQ_ADJ <= 12'd2;
  //   end 
 //  else 
//       FREQ_ADJ <= FREQ_ADJ;
//end 



//Ƶ�ʵ��ڼ�����
always @(posedge ad_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        freq_cnt <= 12'd0;
    else if(freq_cnt == FREQ_ADJ)    
        freq_cnt <= 12'd0;
    else         
        freq_cnt <= freq_cnt + 12'd1;
end
//================== from ad_data_chanshen.v ==================================

//����ram��дʹ��
always @(posedge ad_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        ram_wr_en <= 1'b0;                   
	// else 
    // if(ram_wr_en_flag) begin//�ڳ�ͬ�������ص���ʱд������
    else if(cnt_ram_wr_en <= 255 && freq_cnt == 'd1)
            ram_wr_en <= 1'b1;
    else if(cnt_ram_wr_en > 255 || freq_cnt != 'd1)  
        ram_wr_en <= 1'b0;           
    else 
        ram_wr_en <= 1'b0;     
end 

//����ramдʹ�ܼ�����
always @(posedge ad_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        cnt_ram_wr_en <= 9'd0;   
    else if (cnt_ram_wr_en >= 255 && ram_wr_en && s_axis_data_tready) 
        cnt_ram_wr_en <= 9'd0;                     
    else if(ram_wr_en && s_axis_data_tready)  
        cnt_ram_wr_en <= cnt_ram_wr_en + 1'b1;              

end 


endmodule