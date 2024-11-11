/*
module DDS_swj_b(
	input				clk			,//125M
	input				rst_n		,
	input		[31:0]	f_word		,//Ƶ�ʿ�����
	input		[2:0]	wave_c		,//���ֲ��ο����л�
	input		[13:0]	p_word 		,//��Ϊ14λ�� ֮ǰ��12λ��  Ĭ����0��λ
	input		[4:0]	amplitude	,//��ֵ 1-5��Ӧ�Ŵ�-5v-5v 6-8��С1/2 1/4 1/8
    input       [13:0]  vol_bias,    //��ѹƫ��
	output		[13:0]	dac_dataxin	//����Ĳ������ݸ���DACģ��
	);

	localparam	DATA_WIDTH = 4'd14;
	localparam	ADDR_WIDTH = 4'd14;

	reg		[13:0]	addr	 ;
	wire	[13:0]	dac_data0;
	wire	[13:0]	dac_data1;
	wire	[13:0]	dac_data2;
	wire	[13:0]	dac_data3;
    wire	[13:0]	dac_data4;
	wire	[13:0]	dac_data5;
	wire	[13:0]	dac_data6;
	wire	[13:0]	dac_data7;
/*
	//����ѡ��
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			dac_data <= 14'd0;
		end
		else begin
			case(wave_c)
				2'b00:dac_data <= dac_data0/amplitude;	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095 2048��Ӧ0v 
				2'b01:dac_data <= dac_data1/amplitude;	//���ǲ�
				2'b10:dac_data <= dac_data2/amplitude;	//��ݲ�
				2'b11:dac_data <= dac_data3/amplitude;	//����
				default:;
			endcase
		end
	end
*/
/*
reg	[13:0]	dac_data;
//��ѹƫ�� �����λ��Ϊ����λ�ĸо�  ��Ϊ-5v-5v ��ʵ��ѹƫ��������5v����Ӧ���ݼӼ�8192 �� ������Ҫ 1����/ 0����ƫ��
//assign dac_dataxin = ((dac_data + vol_bias) <= 14'd16383)? (dac_data + vol_bias):14'd16383;
wire [14:0] dac_dataxin0 ; 
assign dac_dataxin0 = (vol_bias[13]) ? (dac_data + vol_bias[12:0]) : (dac_data - vol_bias[12:0]);
assign dac_dataxin = (dac_dataxin0 <= 14'd16383) ? (dac_dataxin0[13:0]) :14'd16383;;


//����ѡ��
	always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dac_data <= 14'd0;
    end
    else if((amplitude >= 1)&&(amplitude <= 5))
       begin
        case(wave_c)
            3'b000: if(dac_data0 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data0-14'd8192)*amplitude;	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data0)*amplitude;
            3'b001: if(dac_data1 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data1-14'd8192)*amplitude;	//���ǲ�
                   else    
                            dac_data <= 14'd8192 - (14'd8192-dac_data1)*amplitude;
             3'b010: if(dac_data2 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data2-14'd8192)*amplitude;	//��ݲ�
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data2)*amplitude;
             3'b011: if(dac_data3 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data3-14'd8192)*amplitude;	//����
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data3)*amplitude;
            3'b100: if(dac_data4 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data4-14'd8192)*amplitude;	//���ݲ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data4)*amplitude;
            3'b101: if(dac_data5 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data5-14'd8192)*amplitude;	//���β�
                   else    
                            dac_data <= 14'd8192 - (14'd8192-dac_data5)*amplitude;
             3'b110: if(dac_data6 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data6-14'd8192)*amplitude;	//��˹������
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data6)*amplitude;
             3'b111: if(dac_data7 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data7-14'd8192)*amplitude;	//г��
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data7)*amplitude;
            default:;
        endcase
    end

else if(amplitude == 6)
    begin
     case(wave_c)
         3'b000: if(dac_data0 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data0-14'd8192)>>1);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data0)>>1);
         3'b001: if(dac_data1 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data1-14'd8192)>>1);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data1)>>1);
          3'b010: if(dac_data2 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data2-14'd8192)>>1);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data2)>>1);
        3'b011: if(dac_data3 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data3-14'd8192)>>1);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data3)>>1);
        3'b100: if(dac_data4 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data4-14'd8192)>>1);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data4)>>1);
        3'b101: if(dac_data5 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data5-14'd8192)>>1);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data5)>>1);
        3'b110: if(dac_data6 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data6-14'd8192)>>1);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data6)>>1);
        3'b111: if(dac_data7 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data7-14'd8192)>>1);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data7)>>1);
         default:;
     endcase
 end
 else if(amplitude == 7)
    begin
     case(wave_c)
         3'b000: if(dac_data0 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data0-14'd8192)>>2);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data0)>>2);
         3'b001: if(dac_data1 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data1-14'd8192)>>2);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data1)>>2);
         3'b010: if(dac_data2 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data2-14'd8192)>>2);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data2)>>2);
         3'b011: if(dac_data3 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data3-14'd8192)>>2);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data3)>>2);
         3'b100: if(dac_data4 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data4-14'd8192)>>2);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data4)>>2);
         3'b101: if(dac_data5 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data5-14'd8192)>>2);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data5)>>2);
         3'b110: if(dac_data6 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data6-14'd8192)>>2);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data6)>>2);
         3'b111: if(dac_data7 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data7-14'd8192)>>2);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data7)>>2);
         default:;
     endcase
 end
 else if(amplitude == 8)
    begin
     case(wave_c)
         3'b000: if(dac_data0 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data0-14'd8192)>>3);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data0)>>3);
         3'b001: if(dac_data1 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data1-14'd8192)>>3);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data1)>>3);
         3'b010: if(dac_data2 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data2-14'd8192)>>3);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data2)>>3);
         3'b011: if(dac_data3 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data3-14'd8192)>>3);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data3)>>3);
         3'b100: if(dac_data4 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data4-14'd8192)>>3);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data4)>>3);
         3'b101: if(dac_data5 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data5-14'd8192)>>3);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data5)>>3);
        3'b110: if(dac_data6 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data6-14'd8192)>>3);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data6)>>3);
        3'b111: if(dac_data7>= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data7-14'd8192)>>3);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data7)>>3);
         default:;
     endcase
 end
   else
    begin
        case(wave_c)
            3'b000: if(dac_data0 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data0-14'd8192);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data0);
            3'b001: if(dac_data1 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data1-14'd8192);	//���ǲ�
                   else    
                            dac_data <= 14'd8192 - (14'd8192-dac_data1);
             3'b010: if(dac_data2 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data2-14'd8192);	//��ݲ�
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data2);
             3'b011: if(dac_data3 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data3-14'd8192);	//����
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data3);
            3'b100: if(dac_data4 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data4-14'd8192);	//���ݲ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data4);
            3'b101: if(dac_data5 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data5-14'd8192);	//���β�
                   else    
                            dac_data <= 14'd8192 - (14'd8192-dac_data5);
             3'b110: if(dac_data6 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data6-14'd8192);	//��˹������
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data6);
             3'b111: if(dac_data7 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data7-14'd8192);	//г��
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data7);
            default:;
        endcase
    end
end




	//��λ�ۼ���
	reg	[31:0]	fre_acc;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			fre_acc <= 0;
		end
		else begin
			fre_acc <= fre_acc + f_word;
		end
	end

	//���ɲ��ұ��ַ
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			addr <= 0;
		end
		else begin
			addr <= fre_acc[31:18] + p_word; //���������
		end
	end

	//���Ҳ�
	sin_rom sin_rom_inst (
		.addr(addr),          // input [13:0]
        .clk(clk),            // input
        .rst(~rst_n),            // input
        .rd_data(dac_data0)     // output [13:0]
	);

	//���ǲ�
   sanjiao_rom sanjiao_rom_inst (
       .addr(addr),          // input [13:0]
       .clk(clk),            // input
       .rst(~rst_n),            // input
       .rd_data(dac_data1)     // output [13:0]
   );

	//��ݲ�
	juchi_rom juchi_rom_inst (
       .addr(addr),          // input [13:0]
       .clk(clk),            // input
       .rst(~rst_n),            // input
       .rd_data(dac_data2)     // output [13:0]
    );
	//����
    fangbo_rom fangbo_rom_inst (
       .addr(addr),          // input [13:0]
       .clk(clk),            // input
       .rst(~rst_n),            // input
       .rd_data(dac_data3)     // output [13:0]
     );

jieti_rom jieti_rom_inst (
  .addr(addr),          // input [13:0]
  .clk(clk),            // input
  .rst(~rst_n),            // input
  .rd_data(dac_data4)     // output [13:0]
);

tixing_rom tixing_rom_inst (
  .addr(addr),          // input [13:0]
  .clk(clk),            // input
  .rst(~rst_n),            // input
  .rd_data(dac_data5)     // output [13:0]
);
gauss_rom gauss_rom_inst (
  .addr(addr),          // input [13:0]
  .clk(clk),            // input
  .rst(~rst_n),            // input
  .rd_data(dac_data6)     // output [13:0]
);
xiebo_rom xiebo_rom_inst (
  .addr(addr),          // input [13:0]
  .clk(clk),            // input
  .rst(~rst_n),            // input
  .rd_data(dac_data7)     // output [13:0]
);


endmodule
*/

module DDS_swj_b(
	input				clk			,//125M
	input				rst_n		,
	input		[31:0]	f_word		,//Ƶ�ʿ�����
	input		[2:0]	wave_c		,//���ֲ��ο����л�
	input		[13:0]	p_word 		,//��Ϊ14λ�� ֮ǰ��12λ��  Ĭ����0��λ
	input		[4:0]	amplitude	,//��ֵ 1-5��Ӧ�Ŵ�-5v-5v 6-8��С1/2 1/4 1/8
    input       [13:0]  vol_bias,    //��ѹƫ��
    input       [7:0]   duty_cycle  , //ռ�ձ�
    input       [31:0]  div_fractor,
    input  [13:0]	dac_data0,
    input  [13:0]	dac_data1,
    input  [13:0]	dac_data2,
    input  [13:0]	dac_data3,
    input  [13:0]	dac_data4,
    input  [13:0]	dac_data5,
    input  [13:0]	dac_data6,
    input  [13:0]	dac_data7,  
    output		[13:0]	dac_dataxin_pwm,	//����Ĳ������ݸ���DACģ��
	output		[13:0]	dac_dataxin	//����Ĳ������ݸ���DACģ��
	);


	localparam	DATA_WIDTH = 4'd14;
	localparam	ADDR_WIDTH = 4'd14;

    reg     [13:0]	dac_data_pwm;
    reg     [13:0]	dac_data_pwm0;
    reg     [31:0]  duty_cnt;
   

reg	[13:0]	dac_data;
//��ѹƫ�� �����λ��Ϊ����λ�ĸо�  ��Ϊ-5v-5v ��ʵ��ѹƫ��������5v����Ӧ���ݼӼ�8192 �� ������Ҫ 1����/ 0����ƫ��
//assign dac_dataxin = ((dac_data + vol_bias) <= 14'd16383)? (dac_data + vol_bias):14'd16383;
wire [14:0] dac_dataxin0 ; 
assign dac_dataxin0 = (vol_bias[13]) ? (dac_data + vol_bias[12:0]) : (dac_data - vol_bias[12:0]);
assign dac_dataxin = (dac_dataxin0 <= 14'd16383) ? (dac_dataxin0[13:0]) :14'd16383;
wire [14:0] dac_dataxinpwm ; 
assign dac_dataxinpwm = (vol_bias[13]) ? (dac_data_pwm + vol_bias[12:0]) : (dac_data_pwm - vol_bias[12:0]);
assign dac_dataxin_pwm = (dac_dataxinpwm <= 14'd16383) ? (dac_dataxinpwm[13:0]) :14'd16383;

//����ѡ��
	always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dac_data <= 14'd0;
    end
    else if((amplitude >= 1)&&(amplitude <= 5))
       begin
        case(wave_c)
            3'b000: if(dac_data0 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data0-14'd8192)*amplitude;	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data0)*amplitude;
            3'b001: if(dac_data1 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data1-14'd8192)*amplitude;	//���ǲ�
                   else    
                            dac_data <= 14'd8192 - (14'd8192-dac_data1)*amplitude;
             3'b010: if(dac_data2 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data2-14'd8192)*amplitude;	//��ݲ�
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data2)*amplitude;
             3'b011: if(dac_data3 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data3-14'd8192)*amplitude;	//����
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data3)*amplitude;
            3'b100: if(dac_data4 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data4-14'd8192)*amplitude;	//���ݲ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data4)*amplitude;
            3'b101: if(dac_data5 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data5-14'd8192)*amplitude;	//���β�
                   else    
                            dac_data <= 14'd8192 - (14'd8192-dac_data5)*amplitude;
             3'b110: if(dac_data6 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data6-14'd8192)*amplitude;	//��˹������
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data6)*amplitude;
             3'b111: if(dac_data7 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data7-14'd8192)*amplitude;	//г��
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data7)*amplitude;
            default:;
        endcase
    end

else if(amplitude == 6)
    begin
     case(wave_c)
         3'b000: if(dac_data0 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data0-14'd8192)>>1);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data0)>>1);
         3'b001: if(dac_data1 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data1-14'd8192)>>1);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data1)>>1);
          3'b010: if(dac_data2 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data2-14'd8192)>>1);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data2)>>1);
        3'b011: if(dac_data3 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data3-14'd8192)>>1);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data3)>>1);
        3'b100: if(dac_data4 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data4-14'd8192)>>1);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data4)>>1);
        3'b101: if(dac_data5 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data5-14'd8192)>>1);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data5)>>1);
        3'b110: if(dac_data6 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data6-14'd8192)>>1);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data6)>>1);
        3'b111: if(dac_data7 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data7-14'd8192)>>1);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data7)>>1);
         default:;
     endcase
 end
 else if(amplitude == 7)
    begin
     case(wave_c)
         3'b000: if(dac_data0 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data0-14'd8192)>>2);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data0)>>2);
         3'b001: if(dac_data1 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data1-14'd8192)>>2);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data1)>>2);
         3'b010: if(dac_data2 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data2-14'd8192)>>2);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data2)>>2);
         3'b011: if(dac_data3 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data3-14'd8192)>>2);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data3)>>2);
         3'b100: if(dac_data4 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data4-14'd8192)>>2);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data4)>>2);
         3'b101: if(dac_data5 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data5-14'd8192)>>2);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data5)>>2);
         3'b110: if(dac_data6 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data6-14'd8192)>>2);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data6)>>2);
         3'b111: if(dac_data7 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data7-14'd8192)>>2);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data7)>>2);
         default:;
     endcase
 end
 else if(amplitude == 8)
    begin
     case(wave_c)
         3'b000: if(dac_data0 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data0-14'd8192)>>3);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data0)>>3);
         3'b001: if(dac_data1 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data1-14'd8192)>>3);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data1)>>3);
         3'b010: if(dac_data2 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data2-14'd8192)>>3);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data2)>>3);
         3'b011: if(dac_data3 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data3-14'd8192)>>3);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data3)>>3);
         3'b100: if(dac_data4 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data4-14'd8192)>>3);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data4)>>3);
         3'b101: if(dac_data5 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data5-14'd8192)>>3);	//���ǲ�
                else    
                         dac_data <= 14'd8192 - ((14'd8192-dac_data5)>>3);
        3'b110: if(dac_data6 >= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data6-14'd8192)>>3);	//��ݲ�
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data6)>>3);
        3'b111: if(dac_data7>= 14'd8192)
                         dac_data <= 14'd8192 + ((dac_data7-14'd8192)>>3);	//����
                else     
                         dac_data <= 14'd8192 - ((14'd8192-dac_data7)>>3);
         default:;
     endcase
 end
   else
    begin
        case(wave_c)
            3'b000: if(dac_data0 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data0-14'd8192);	//���Ҳ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data0);
            3'b001: if(dac_data1 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data1-14'd8192);	//���ǲ�
                   else    
                            dac_data <= 14'd8192 - (14'd8192-dac_data1);
             3'b010: if(dac_data2 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data2-14'd8192);	//��ݲ�
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data2);
             3'b011: if(dac_data3 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data3-14'd8192);	//����
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data3);
            3'b100: if(dac_data4 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data4-14'd8192);	//���ݲ�    Ϊ����������ѹ�Ĳ��� ����ͬ���仯 ����12λ��0-4095    14λ��Ļ���14'd8192��Ӧ0v 
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data4);
            3'b101: if(dac_data5 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data5-14'd8192);	//���β�
                   else    
                            dac_data <= 14'd8192 - (14'd8192-dac_data5);
             3'b110: if(dac_data6 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data6-14'd8192);	//��˹������
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data6);
             3'b111: if(dac_data7 >= 14'd8192)
                            dac_data <= 14'd8192 + (dac_data7-14'd8192);	//г��
                   else     
                            dac_data <= 14'd8192 - (14'd8192-dac_data7);
            default:;
        endcase
    end
end

always @(*) begin
      case(amplitude)
5'd1,5'd2,5'd3,5'd4,5'd5:    if(dac_data_pwm0 >= 14'd8192)
                                    dac_data_pwm <=  14'd8192 + ((14'd9830-14'd8192)*amplitude);
                             else    
                                    dac_data_pwm <=  14'd8192 - ((14'd8192-14'd6554)*amplitude);
                    5'd6:    if(dac_data_pwm0 >= 14'd8192)
                                    dac_data_pwm <=  14'd8192 + ((14'd9830-14'd8192)>>1);
                             else    
                                    dac_data_pwm <=  14'd8192 - ((14'd8192-14'd6554)>>1);
                    5'd7:    if(dac_data_pwm0 >= 14'd8192)
                                    dac_data_pwm <=  14'd8192 + ((14'd9830-14'd8192)>>2);
                             else    
                                    dac_data_pwm <=  14'd8192 - ((14'd8192-14'd6554)>>2);
                    5'd8:    if(dac_data_pwm0 >= 14'd8192)
                                    dac_data_pwm <=  14'd8192 + ((14'd9830-14'd8192)>>3);
                             else    
                                    dac_data_pwm <=  14'd8192 - ((14'd8192-14'd6554)>>3);
                    5'd9:     if(dac_data_pwm0 >= 14'd8192)
                                    dac_data_pwm <=  14'd8192 + ((14'd9830-14'd8192)>>4);
                             else    
                                    dac_data_pwm <=  14'd8192 - ((14'd8192-14'd6554)>>4);
                    default : if(dac_data_pwm0 >= 14'd8192)
                                    dac_data_pwm <=  14'd8192 + ((14'd9830-14'd8192));
                            else    
                                    dac_data_pwm <=  14'd8192 - ((14'd8192-14'd6554));
        endcase
    end                         
                

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
       duty_cnt <= 32'd0;
    else if(duty_cnt <  (div_fractor - 1)) begin
       duty_cnt <= duty_cnt + 32'd1;
       begin
           if(duty_cnt < (((div_fractor * duty_cycle)/100)- 1))
              dac_data_pwm0 <=  14'd8192 + ((14'd9830-14'd8192));
           else 
              dac_data_pwm0 <=  14'd8192 - ((14'd8192-14'd6554));
           end 
       end
    else duty_cnt <=  32'd0;
end 


endmodule