module parameter_controller(
    input rst_n,//��λ�ź�
    input [7:0] parameter_id,//����ID
    input [31:0] parameter_value,//����ֵ
    //�źŷ�����
    output [31:0] dds_frequency_A,//����Ƶ��
    output [13:0] dds_phase_A,//������λ
    output [4:0] dds_Amplitude_A,//���η���
    output [2:0] dds_wave_type_A,//��������
    output dds_choose_en_A,//��λ������or���ذ�������
    output [13:0] vol_bias_A,//��ѹƫ��
    output [7:0] duty_cycle_A,//ռ�ձ�
    output [31:0] div_fractor_A,//��Ƶϵ��
    
    output [31:0] dds_frequency_B,//����Ƶ��
    output [13:0] dds_phase_B,//������λ
    output [4:0] dds_Amplitude_B,//���η���
    output [2:0] dds_wave_type_B,//��������
    output dds_choose_en_B,//��λ������or���ذ�������
    output [13:0] vol_bias_B,//��ѹƫ��
    output [7:0] duty_cycle_B,//ռ�ձ�
    output [31:0] div_fractor_B,//��Ƶϵ��

    output [1:0] dds_pwm_choose,//PWMѡ��

    //ʾ����
    output [9:0] deci_rate_A,//������
    output [11:0] trig_level_A,//������ƽ
    output [11:0] trig_line_A,//������λ��
    output trig_edge_A,//��������
    output wave_run_A,//run or stop
    output [9:0] h_shift_A,//ˮƽƫ�� bit[9]=0/1 ����/����
    output [9:0] v_shift_A,//��ֱƫ�� bit[9]=0/1 ����/����
    output [4:0] v_scale_A,//��ֱ���ű��� bit[4]=0/1 ��С/�Ŵ�
    output ad_outrange_A,//AD����Χ

    output [9:0] deci_rate_B,//������
    output [11:0] trig_level_B,//������ƽ
    output [11:0] trig_line_B,//������λ��
    output trig_edge_B,//��������
    output wave_run_B,//run or stop
    output [9:0] h_shift_B,//ˮƽƫ�� bit[9]=0/1 ����/����
    output [9:0] v_shift_B,//��ֱƫ�� bit[9]=0/1 ����/����
    output [4:0] v_scale_B,//��ֱ���ű��� bit[4]=0/1 ��С/�Ŵ�
    output ad_outrange_B,//AD����Χ
    output [2:0] display_mode,//��ʾģʽ

    output sample_run,//�߼������ǲ�������
    output [31:0] sample_num,//�߼������ǲ������
    output [3:0] sample_clk_cfg,//�߼������ǲ���������
    output [1:0] trigger_edge,//�߼������Ǵ�����������
    output [2:0] trigger_channel//�߼������Ǵ���ͨ������
);
//�źŷ���������ID
localparam frequency_id = 8'h01;
localparam phase_id = 8'h02;
localparam wave_id = 8'h03;
localparam fuzhi_id = 8'h04;
localparam channel_id = 8'h05;
localparam dds_choose_id = 8'h06;
localparam vol_bias_id = 8'h07;
localparam duty_cycle_id = 8'h08;
localparam div_fractor_id = 8'h09;
localparam dds_pwm_choose_id = 8'h0a;
//ʾ��������ID
localparam up_down_id = 8'h10;
localparam left_right_id = 8'h11;
localparam run_stop_id = 8'h12;
localparam edge_id = 8'h13;
localparam deci_rate_id = 8'h14;
localparam voltage_id = 8'h15;
localparam trigger_id = 8'h16;
localparam trigger_line_id = 8'h17;
localparam adc_channel_id = 8'h18;
localparam display_mode_id = 8'h19;
//�߼������ǲ���ID
localparam sample_num_id = 8'h30;
localparam sample_clk_cfg_id = 8'h31;
localparam trigger_edge_id = 8'h32;
localparam trigger_channel_id = 8'h33;
localparam sample_run_id = 8'h34;
//�źŷ�����Ĭ��ͨ��
localparam dds_channel_default = 1'b0;
//�źŷ�����Aͨ��Ĭ��ֵ
localparam dds_frequency_A_default = 32'd343597;//10khz
localparam dds_phase_A_default = 14'h0000;//0��
localparam dds_Amplitude_A_default = 5'b000;//1��
localparam dds_wave_type_A_default = 3'b000;//���Ҳ�
localparam dds_choose_en_A_default = 1'b0;
localparam vol_bias_A_default = 14'h0000;//0V��ѹƫ��
localparam duty_cycle_A_default = 8'd25;//25%ռ�ձ�
localparam div_fractor_A_default = 32'd10000;//��Ƶϵ��
//�źŷ�����Bͨ��Ĭ��ֵ
localparam dds_frequency_B_default = 32'd343597;//10khz
localparam dds_phase_B_default = 14'h0000;//0��
localparam dds_Amplitude_B_default = 5'b000;//1��
localparam dds_wave_type_B_default = 3'b000;//���Ҳ�
localparam dds_choose_en_B_default = 1'b0;
localparam vol_bias_B_default = 14'h0000;//0V��ѹƫ��
localparam duty_cycle_B_default = 8'd25;//25%ռ�ձ�;
localparam div_fractor_B_default = 32'd10000;//��Ƶϵ��

localparam dds_pwm_choose_default = 2'b00;
//ʾ����
localparam adc_channel_default = 1'b0;
//ʾ����Aͨ��Ĭ��ֵ
localparam deci_rate_A_default = 12'd13;
localparam trig_level_A_default = 12'd2048;
localparam trig_line_A_default = 12'd228;
localparam trig_edge_A_default = 1'b0;
localparam wave_run_A_default = 1'b1;
localparam h_shift_A_default = 10'b0000_0000_0;
localparam v_shift_A_default = 10'b0000_0000_0;
localparam v_scale_A_default = 5'b00000;
localparam ad_outrange_A_default = 1'b0;
//ʾ����Bͨ��Ĭ��ֵ
localparam deci_rate_B_default = 12'd13;
localparam trig_level_B_default = 12'd2048;
localparam trig_line_B_default = 12'd228;
localparam trig_edge_B_default = 1'b0;
localparam wave_run_B_default = 1'b1;
localparam h_shift_B_default = 10'b0000_0000_0;
localparam v_shift_B_default = 10'b0000_0000_0;
localparam v_scale_B_default = 5'b00000;
localparam ad_outrange_B_default = 1'b0;
//Ĭ����ʾģʽ
localparam display_mode_default = 3'b011;//ʾ����˫ͨ��
//�߼�������
localparam sample_num_default = 32'd20_000;//20ksa
localparam sample_clk_cfg_default = 4'h5;//1Mhz
localparam trigger_edge_default = 2'b00;//�ߵ�ƽ����
localparam trigger_channel_default = 3'b000;//ͨ��0����
localparam sample_run_default = 1'b0;//�߼�������ֹͣ
//logic control
wire dds_channel;
assign dds_channel = (!rst_n) ? dds_channel_default :(parameter_id == channel_id) ? parameter_value[0:0] : dds_channel;
wire [1:0] pwm_choose;
assign pwm_choose = (!rst_n) ? dds_pwm_choose_default : (parameter_id == dds_pwm_choose_id) ? parameter_value[1:0] : pwm_choose;
assign dds_pwm_choose = pwm_choose;
//�źŷ�����Aͨ��
assign dds_frequency_A = (!rst_n) ? dds_frequency_A_default : ((dds_channel == 1'b0) && (parameter_id == frequency_id)) ? parameter_value : dds_frequency_A;
assign dds_phase_A = (!rst_n) ? dds_phase_A_default : ((dds_channel == 1'b0) && (parameter_id == phase_id)) ? parameter_value[13:0] : dds_phase_A;
assign dds_wave_type_A = (!rst_n) ? dds_wave_type_A_default : ((dds_channel == 1'b0) && (parameter_id == wave_id)) ? parameter_value[2:0] : dds_wave_type_A;
assign dds_Amplitude_A = (!rst_n) ? dds_Amplitude_A_default : ((dds_channel == 1'b0) && (parameter_id == fuzhi_id)) ? parameter_value[4:0] : dds_Amplitude_A;
assign dds_choose_en_A = (!rst_n) ? dds_choose_en_A_default : ((dds_channel == 1'b0) && (parameter_id == dds_choose_id)) ? parameter_value[0:0] : dds_choose_en_A;
assign vol_bias_A = (!rst_n) ? vol_bias_A_default : ((dds_channel == 1'b0) && (parameter_id == vol_bias_id)) ? parameter_value[13:0] : vol_bias_A;

assign duty_cycle_A = (!rst_n) ? duty_cycle_A_default : ((pwm_choose == 2'b01) && (parameter_id == duty_cycle_id)) ? parameter_value[7:0] : duty_cycle_A;
assign div_fractor_A = (!rst_n) ? div_fractor_A_default : ((pwm_choose == 2'b01) && (parameter_id == div_fractor_id)) ? parameter_value : div_fractor_A;
//�źŷ�����Bͨ��
assign dds_frequency_B = (!rst_n) ? dds_frequency_B_default : ((dds_channel == 1'b1) && (parameter_id == frequency_id)) ? parameter_value : dds_frequency_B;
assign dds_phase_B = (!rst_n) ? dds_phase_B_default : ((dds_channel == 1'b1) && (parameter_id == phase_id)) ? parameter_value[13:0] : dds_phase_B;
assign dds_wave_type_B = (!rst_n) ? dds_wave_type_B_default : ((dds_channel == 1'b1) && (parameter_id == wave_id)) ? parameter_value[2:0] : dds_wave_type_B;
assign dds_Amplitude_B = (!rst_n) ? dds_Amplitude_B_default : ((dds_channel == 1'b1) && (parameter_id == fuzhi_id)) ? parameter_value[4:0] : dds_Amplitude_B;
assign dds_choose_en_B = (!rst_n) ? dds_choose_en_B_default : ((dds_channel == 1'b1) && (parameter_id == dds_choose_id)) ? parameter_value[0:0] : dds_choose_en_B;
assign vol_bias_B = (!rst_n) ? vol_bias_B_default : ((dds_channel == 1'b1) && (parameter_id == vol_bias_id)) ? parameter_value[13:0] : vol_bias_B;

assign duty_cycle_B = (!rst_n) ? duty_cycle_B_default : ((pwm_choose == 2'b10) && (parameter_id == duty_cycle_id)) ? parameter_value[7:0] : duty_cycle_B;
assign div_fractor_B = (!rst_n) ? div_fractor_B_default : ((pwm_choose == 2'b10) && (parameter_id == div_fractor_id)) ? parameter_value : div_fractor_B;
//ʾ����ͨ��ѡ��
wire adc_channel;
assign adc_channel = (!rst_n) ? adc_channel_default : (parameter_id == adc_channel_id) ? parameter_value[0:0] : adc_channel;
//ʾ����Aͨ��
assign deci_rate_A = (!rst_n) ? deci_rate_A_default : ((adc_channel == 1'b0) && (parameter_id == deci_rate_id)) ? parameter_value[9:0] : deci_rate_A;
assign trig_level_A = (!rst_n) ? trig_level_A_default : ((adc_channel == 1'b0) && (parameter_id == trigger_id)) ? parameter_value[11:0] : trig_level_A;
assign trig_line_A = (!rst_n) ? trig_line_A_default : ((adc_channel == 1'b0) && (parameter_id == trigger_line_id)) ? parameter_value[11:0] : trig_line_A;
assign trig_edge_A = (!rst_n) ? trig_edge_A_default : ((adc_channel == 1'b0) && (parameter_id == edge_id)) ? parameter_value[0:0] : trig_edge_A;
assign wave_run_A = (!rst_n) ? wave_run_A_default : ((adc_channel == 1'b0) && (parameter_id == run_stop_id)) ? parameter_value[0:0] : wave_run_A;
assign h_shift_A = (!rst_n) ? h_shift_A_default : ((adc_channel == 1'b0) && (parameter_id == left_right_id)) ? parameter_value[9:0] : h_shift_A;
assign v_shift_A = (!rst_n) ? v_shift_A_default : ((adc_channel == 1'b0) && (parameter_id == up_down_id)) ? parameter_value[9:0] : v_shift_A;
assign v_scale_A = (!rst_n) ? v_scale_A_default : ((adc_channel == 1'b0) && (parameter_id == voltage_id)) ? parameter_value[4:0] : v_scale_A;
assign ad_outrange_A = (!rst_n) ? ad_outrange_A_default : 1'b0;
//ʾ����Bͨ��
assign deci_rate_B = (!rst_n) ? deci_rate_B_default : ((adc_channel == 1'b1) && (parameter_id == deci_rate_id)) ? parameter_value[9:0] : deci_rate_B;
assign trig_level_B = (!rst_n) ? trig_level_B_default : ((adc_channel == 1'b1) && (parameter_id == trigger_id)) ? parameter_value[11:0] : trig_level_B;
assign trig_line_B = (!rst_n) ? trig_line_B_default : ((adc_channel == 1'b1) && (parameter_id == trigger_line_id)) ? parameter_value[11:0] : trig_line_B;
assign trig_edge_B = (!rst_n) ? trig_edge_B_default : ((adc_channel == 1'b1) && (parameter_id == edge_id)) ? parameter_value[0:0] : trig_edge_B;
assign wave_run_B = (!rst_n) ? wave_run_B_default : ((adc_channel == 1'b1) && (parameter_id == run_stop_id)) ? parameter_value[0:0] : wave_run_B;
assign h_shift_B = (!rst_n) ? h_shift_B_default : ((adc_channel == 1'b1) && (parameter_id == left_right_id)) ? parameter_value[9:0] : h_shift_B;
assign v_shift_B = (!rst_n) ? v_shift_B_default : ((adc_channel == 1'b1) && (parameter_id == up_down_id)) ? parameter_value[9:0] : v_shift_B;
assign v_scale_B = (!rst_n) ? v_scale_B_default : ((adc_channel == 1'b1) && (parameter_id == voltage_id)) ? parameter_value[4:0] : v_scale_B;
assign ad_outrange_B = (!rst_n) ? ad_outrange_B_default : 1'b0;
//HDMI��ʾģʽ
assign display_mode = (!rst_n) ? display_mode_default : (parameter_id == display_mode_id) ? parameter_value[2:0] : display_mode;
//�߼�������
assign sample_run = (!rst_n) ? sample_run_default : (parameter_id == sample_run_id) ? parameter_value[0:0] : sample_run;
assign sample_num = (!rst_n) ? sample_num_default : (parameter_id == sample_num_id) ? parameter_value : sample_num;
assign sample_clk_cfg = (!rst_n) ? sample_clk_cfg_default : (parameter_id == sample_clk_cfg_id) ? parameter_value[3:0] : sample_clk_cfg;
assign trigger_edge = (!rst_n) ? trigger_edge_default : (parameter_id == trigger_edge_id) ? parameter_value[1:0] : trigger_edge;
assign trigger_channel = (!rst_n) ? trigger_channel_default : (parameter_id == trigger_channel_id) ? parameter_value[2:0] : trigger_channel;
endmodule