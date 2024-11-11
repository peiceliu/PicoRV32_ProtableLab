module data_store_b(
    input               rst_n,      // ��λ�ź�

    input       [11:0]   trig_level, // ������ƽ  ֮ǰ��8λ�� �˴�Ӧ��Ҫ�޸�Ϊ12
    input               trig_edge,  // ��������
    input               wave_run,   // ���βɼ�����/ֹͣ
    input       [9:0]   h_shift,    // ����ˮƽƫ����

    input                ad_clk,     // ADʱ��
    input       [11:0]   ad_data,    // AD��������   �޸�Ϊ��12λ��
    input               deci_valid, // ������Ч�ź� �����ڵĸߵ�ƽ
    
    input               lcd_clk,    //��ʱ��ȥ��Ӧ�����LCD��ʾģ�� ������HDMI�Ļ���Ҫ˼��һ��
    input               lcd_wr_over,//���λ�����
    input               wave_data_req,//�൱�ڶ�ʷ��
    input       [9:0]   wave_rd_addr,   //  ��ǰ��ȡ��ַ
    output      [11:0]   wave_rd_data, //�޸�12λ
    output reg          outrange    //ˮƽƫ�Ƴ�����Χ ����ط����ڲ�ͬ��С����ʾ�����߽粻һ��
);

//reg define                                 //��Ϊ��500������
reg [8:0] wr_addr;      //RAMд��ַ
//reg       ram_aclr;     //RAM���

reg       trig_flag;    //������־ 
reg       trig_en;      //����ʹ��
reg [8:0] trig_addr;    //������ַ

reg [11:0] pre_data; 
reg [11:0] pre_data1;
reg [11:0] pre_data2;
reg [8:0] data_cnt;

//wire define
wire       wr_en;       //RAMдʹ��
wire [9:0] rd_addr;     //RAM��ַ   
wire [9:0] rel_addr;    //��Դ�����ַ
wire [9:0] shift_addr;  //ƫ�ƺ�ĵ�ַ

wire       trig_pulse;  //���㴥������ʱ��������
wire [11:0] rd_ram_data;//�޸�Ϊ12λ��

//*****************************************************
//**                    main code
//*****************************************************
assign wr_en    = deci_valid && (data_cnt <= 499) && wave_run;

//���㲨��ˮƽƫ�ƺ��RAM���ݵ�ַ
assign shift_addr = h_shift[9] ? (wave_rd_addr-h_shift[8:0]) : //���� // ���� wave_rd_addr ��������Ҫ��λ�ĵ�ַh_shift ��һ��������λ��Ϣ���źţ����� h_shift[9] ������λ����,h_shift[8:0] ָ����λ���������ٶ�Ϊ0-511�ķ�Χ��
                    (wave_rd_addr+h_shift[8:0]);               //����

//���ݴ�����ַ���������غ�������ӳ���RAM��ַ
assign rel_addr = trig_addr + shift_addr;//��Ե�ַ ���ھ������յĶ�ȡ��ַ
assign rd_addr = (rel_addr<250) ? (rel_addr+250) :    // �����Ե�ַС��150��ӳ�䵽150-299����,�����Ե�ַ����449��150+299)��ӳ�䵽0-149����,��150��449֮�䣬ֱ�Ӽ�ȥ150�Ա�ӳ�䵽0-299����
                    (rel_addr>749) ? (rel_addr-750) : //// �����Ե�ַС��250��ӳ�䵽250-499����,�����Ե�ַ����250+499��ӳ�䵽0-249����,��250��549֮�䣬ֱ�Ӽ�ȥ250�Ա�ӳ�䵽0-499����
                        (rel_addr-250);

//���㴥������ʱ��������ź�
assign trig_pulse = trig_edge ? //1�����ػ���0�½��ش���
                    ((pre_data2<trig_level) && (pre_data1<trig_level) 
                        && (pre_data>=trig_level) && (ad_data>trig_level)) :
                    ((pre_data2>trig_level) && (pre_data1>trig_level) 
                        && (pre_data<=trig_level) && (ad_data<trig_level));        

//����������Ϊ255ʱ����������ʾ��Χ

//assign wave_rd_data = outrange ? 8'd255 : (8'd255 - (rd_ram_data >> 4));
//assign wave_rd_data = outrange ? 12'd4095 : (12'd4095 - rd_ram_data);
assign wave_rd_data = rd_ram_data;
/*
//�ж�ˮƽƫ�ƺ��ַ��Χ
always @(posedge lcd_clk or negedge rst_n)begin
    if(!rst_n)
        outrange <= 1'b0;
    else                                        //����ʱ�ж���߽�
        if(h_shift[9] && (wave_rd_addr<h_shift[8:0]))    
            outrange <= 1'b1;
                                                //����ʱ�ж��ұ߽�
        else if((~h_shift[9]) && (wave_rd_addr+h_shift[8:0]>499)) //���ڲ�ͬ�ֱ�����Ļ ��Ҫ�޸�299  ���������õ�299
            outrange <= 1'b1;
        else
            outrange <= 1'b0;
end
*/
always @(posedge lcd_clk or negedge rst_n)begin
    if(!rst_n)
        outrange <= 1'b0;
    else                                        //����ʱ�ж���߽�
        if(h_shift[9] && (wave_rd_addr + 100 <h_shift[8:0]))    
            outrange <= 1'b1;
                                                //����ʱ�ж��ұ߽�
        else if((~h_shift[9]) && (wave_rd_addr+h_shift[8:0]>599)) //���ڲ�ͬ�ֱ�����Ļ ��Ҫ�޸�299  ���������õ�299
            outrange <= 1'b1;
        else
            outrange <= 1'b0;
end



//дRAM��ַ�ۼ�
always @(posedge ad_clk or negedge rst_n)begin //���������300����������
    if(!rst_n)
        wr_addr  <= 9'd0;
    else if(deci_valid) begin
        if(wr_addr < 9'd499) 
            wr_addr <= wr_addr + 1'b1;
        else 
            wr_addr  <= 9'd0;
    end
end

//����ʹ��
always @(posedge ad_clk or negedge rst_n)begin //�޸�data_cnt����ֵ����߿ɽ��յ�����������ȻRAM�洢���ݵĵ�ַ��Ҫ��Ӧ����
    if(!rst_n) begin
        data_cnt <= 9'd0;
        trig_en  <= 1'b0;
    end
    else begin
        if(deci_valid) begin
            if(data_cnt < 249) begin    //����ǰ���ٽ���150������
                data_cnt <= data_cnt + 1'b1;
                trig_en  <= 1'b0;
            end
            else begin
                trig_en <= 1'b1;        //�򿪴���ʹ��   data_cnt Ϊ150ʱ
                if(trig_flag) begin     //��⵽�����ź�
                    trig_en <= 1'b0;         
                    if(data_cnt < 500)  //��������150������
                        data_cnt <= data_cnt + 1'b1;
                end
            end

        end
                                        //���λ�����ɺ����¼���
        if((data_cnt == 500) && lcd_wr_over & wave_run)
            data_cnt <= 9'd0;
    end
end

//�Ĵ�AD���ݣ������жϴ�������
always @(posedge ad_clk or negedge rst_n)begin
    if(!rst_n) begin
        pre_data  <= 12'd0;
        pre_data1 <= 12'd0;
        pre_data2 <= 12'd0;
    end
    else if(deci_valid) begin
        pre_data  <= ad_data;
        pre_data1 <= pre_data;
        pre_data2 <= pre_data1;
    end
end

//�������
always @(posedge ad_clk or negedge rst_n)begin
    if(!rst_n) begin
        trig_addr <= 9'd0;
        trig_flag <= 1'b0;
    end
    else begin
        if(deci_valid && trig_en && trig_pulse) begin        //��һ��deci_valid��Ч ֻ�ܲ���trig_enΪ��Ȼ�󱣳�Ϊ�� ֱ���ڶ���deci_valid��Ч �������Ϊ�� �жϳ�trig_flagΪ�� Ȼ��tri_en��� ��Ӧ���Ǽ�2��ԭ�� �������֤
            trig_flag <= 1'b1;
            trig_addr <= wr_addr + 2;//trig_addr ������Ϊ��ǰд��ַ wr_addr �� 2���˴��ļ� 2 ������Ϊ�˶����ƫ�ƣ��Ա�����������Ҫ  �����޸���Ҫ�������2������
        end
        if(trig_flag && (data_cnt == 500)     
            && lcd_wr_over && wave_run)
            trig_flag <= 1'b0;
    end
end

//����˫��RAM
/*ram_2port u_ram_2port (
	.wrclock    (ad_clk),
	.wraddress  (wr_addr),
	.data       (ad_data),
	.wren       (wr_en),
    
	.rdclock    (lcd_clk),
	.rd_aclr    (1'b0),
	.rdaddress  (rd_addr), 
    .rden       (wave_data_req),
	.q          (rd_ram_data)
	);
*/
ram2b ram2b_inst (
  .wr_data(ad_data),    // input [11:0]
  .wr_addr(wr_addr),    // input [8:0]
  .wr_en(wr_en),        // input
  .wr_clk(ad_clk),      // input
  .wr_rst(~rst_n),      // input
  .rd_addr(rd_addr[8:0]),    // input [8:0]                ��Ȼrd_addr��9λ������ֻ�ǵ�8λ��ֵȥ�������ҿ�������ԭ�ӵ�ԭ��IP�����
  .rd_data(rd_ram_data),    // output [11:0]
  .rd_clk(lcd_clk),      // input
  .rd_clk_en(wave_data_req),    // input
  .rd_rst(~rst_n)       // input
);

endmodule 

