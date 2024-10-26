module parameter_controller(
    input clk,
    input rst_n,//复位信号
    input [7:0] parameter_id,//参数ID
    input [31:0] parameter_value,//参数值
    //信号发生器
    output [31:0] dds_frequency_A,//波形频率
    output [13:0] dds_phase_A,//波形相位
    output [4:0] dds_Amplitude_A,//波形幅度
    output [1:0] dds_wave_type_A,//波形类型
    
    output [31:0] dds_frequency_B,//波形频率
    output [13:0] dds_phase_B,//波形相位
    output [4:0] dds_Amplitude_B,//波形幅度
    output [1:0] dds_wave_type_B,//波形类型
    //示波器
    output [9:0] deci_rate_A,//抽样率
    output [11:0] trig_level_A,//触发电平
    output [11:0] trig_line_A,//触发线位置
    output trig_edge_A,//触发边沿
    output wave_run_A,//run or stop
    output [9:0] h_shift_A,//水平偏移 bit[9]=0/1 左移/右移
    output [9:0] v_shift_A,//垂直偏移 bit[9]=0/1 上移/下移
    output [4:0] v_scale_A,//垂直缩放比例 bit[4]=0/1 缩小/放大
    output ad_outrange_A,//AD超范围

    output [9:0] deci_rate_B,//抽样率
    output [11:0] trig_level_B,//触发电平
    output [11:0] trig_line_B,//触发线位置
    output trig_edge_B,//触发边沿
    output wave_run_B,//run or stop
    output [9:0] h_shift_B,//水平偏移 bit[9]=0/1 左移/右移
    output [9:0] v_shift_B,//垂直偏移 bit[9]=0/1 上移/下移
    output [4:0] v_scale_B,//垂直缩放比例 bit[4]=0/1 缩小/放大
    output ad_outrange_B,//AD超范围
    output [2:0] display_mode,//显示模式

    output reg  sample_run,//逻辑分析仪采样运行
    output reg  [31:0] sample_num,//逻辑分析仪采样深度
    output reg  [3:0] sample_clk_cfg,//逻辑分析仪采样率配置
    output reg  [1:0] trigger_edge,//逻辑分析仪触发边沿配置
    output reg  [2:0] trigger_channel//逻辑分析仪触发通道配置
);
//信号发生器参数ID
localparam frequency_id = 8'h01;
localparam phase_id = 8'h02;
localparam wave_id = 8'h03;
localparam fuzhi_id = 8'h04;
localparam channel_id = 8'h05;
//示波器参数ID
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
//逻辑分析仪参数ID
localparam sample_num_id = 8'h30;
localparam sample_clk_cfg_id = 8'h31;
localparam trigger_edge_id = 8'h32;
localparam trigger_channel_id = 8'h33;
localparam sample_run_id = 8'h34;


//默认值
localparam dds_channel_default = 1'b0;

localparam dds_frequency_A_default = 32'd343597;//10khz
localparam dds_phase_A_default = 14'h0000;//0度
localparam dds_Amplitude_A_default = 5'b000;//1倍
localparam dds_wave_type_A_default = 2'b00;//正弦波

localparam dds_frequency_B_default = 32'd343597;//10khz
localparam dds_phase_B_default = 14'h0000;//0度
localparam dds_Amplitude_B_default = 5'b000;//1倍
localparam dds_wave_type_B_default = 2'b00;//正弦波

//示波器
localparam adc_channel_default = 1'b0;

localparam deci_rate_A_default = 12'd13;
localparam trig_level_A_default = 12'd2048;
localparam trig_line_A_default = 12'd228;
localparam trig_edge_A_default = 1'b0;
localparam wave_run_A_default = 1'b1;
localparam h_shift_A_default = 10'b0000_0000_0;
localparam v_shift_A_default = 10'b0000_0000_0;
localparam v_scale_A_default = 5'b00000;
localparam ad_outrange_A_default = 1'b0;

localparam deci_rate_B_default = 12'd13;
localparam trig_level_B_default = 12'd2048;
localparam trig_line_B_default = 12'd228;
localparam trig_edge_B_default = 1'b0;
localparam wave_run_B_default = 1'b1;
localparam h_shift_B_default = 10'b0000_0000_0;
localparam v_shift_B_default = 10'b0000_0000_0;
localparam v_scale_B_default = 5'b00000;
localparam ad_outrange_B_default = 1'b0;
//默认显示模式
localparam display_mode_default = 3'b011;//示波器双通道
//逻辑分析仪
localparam sample_num_default = 32'd20_000;//2ksa
localparam sample_clk_cfg_default = 4'hc;//250Mhz
localparam trigger_edge_default = 2'b00;//高电平触发
localparam trigger_channel_default = 3'b000;//通道0触发
localparam sample_run_default = 1'b0;//逻辑分析仪停止
//logic control
wire dds_channel;
assign dds_channel = (!rst_n) ? dds_channel_default :(parameter_id == channel_id) ? parameter_value[0:0] : dds_channel;

assign dds_frequency_A = (!rst_n) ? dds_frequency_A_default : ((dds_channel == 1'b0) && (parameter_id == frequency_id)) ? parameter_value : dds_frequency_A;
assign dds_phase_A = (!rst_n) ? dds_phase_A_default : ((dds_channel == 1'b0) && (parameter_id == phase_id)) ? parameter_value[13:0] : dds_phase_A;
assign dds_wave_type_A = (!rst_n) ? dds_wave_type_A_default : ((dds_channel == 1'b0) && (parameter_id == wave_id)) ? parameter_value[1:0] : dds_wave_type_A;
assign dds_Amplitude_A = (!rst_n) ? dds_Amplitude_A_default : ((dds_channel == 1'b0) && (parameter_id == fuzhi_id)) ? parameter_value[4:0] : dds_Amplitude_A;
assign dds_frequency_B = (!rst_n) ? dds_frequency_B_default : ((dds_channel == 1'b1) && (parameter_id == frequency_id)) ? parameter_value : dds_frequency_B;
assign dds_phase_B = (!rst_n) ? dds_phase_B_default : ((dds_channel == 1'b1) && (parameter_id == phase_id)) ? parameter_value[13:0] : dds_phase_B;
assign dds_wave_type_B = (!rst_n) ? dds_wave_type_B_default : ((dds_channel == 1'b1) && (parameter_id == wave_id)) ? parameter_value[1:0] : dds_wave_type_B;
assign dds_Amplitude_B = (!rst_n) ? dds_Amplitude_B_default : ((dds_channel == 1'b1) && (parameter_id == fuzhi_id)) ? parameter_value[4:0] : dds_Amplitude_B;

wire adc_channel;
assign adc_channel = (!rst_n) ? adc_channel_default : (parameter_id == adc_channel_id) ? parameter_value[0:0] : adc_channel;

assign deci_rate_A = (!rst_n) ? deci_rate_A_default : ((adc_channel == 1'b0) && (parameter_id == deci_rate_id)) ? parameter_value[9:0] : deci_rate_A;
assign trig_level_A = (!rst_n) ? trig_level_A_default : ((adc_channel == 1'b0) && (parameter_id == trigger_id)) ? parameter_value[11:0] : trig_level_A;
assign trig_line_A = (!rst_n) ? trig_line_A_default : ((adc_channel == 1'b0) && (parameter_id == trigger_line_id)) ? parameter_value[11:0] : trig_line_A;
assign trig_edge_A = (!rst_n) ? trig_edge_A_default : ((adc_channel == 1'b0) && (parameter_id == edge_id)) ? parameter_value[0:0] : trig_edge_A;
assign wave_run_A = (!rst_n) ? wave_run_A_default : ((adc_channel == 1'b0) && (parameter_id == run_stop_id)) ? parameter_value[0:0] : wave_run_A;
assign h_shift_A = (!rst_n) ? h_shift_A_default : ((adc_channel == 1'b0) && (parameter_id == left_right_id)) ? parameter_value[9:0] : h_shift_A;
assign v_shift_A = (!rst_n) ? v_shift_A_default : ((adc_channel == 1'b0) && (parameter_id == up_down_id)) ? parameter_value[9:0] : v_shift_A;
assign v_scale_A = (!rst_n) ? v_scale_A_default : ((adc_channel == 1'b0) && (parameter_id == voltage_id)) ? parameter_value[4:0] : v_scale_A;
assign ad_outrange_A = (!rst_n) ? ad_outrange_A_default : 1'b0;

assign deci_rate_B = (!rst_n) ? deci_rate_B_default : ((adc_channel == 1'b1) && (parameter_id == deci_rate_id)) ? parameter_value[9:0] : deci_rate_B;
assign trig_level_B = (!rst_n) ? trig_level_B_default : ((adc_channel == 1'b1) && (parameter_id == trigger_id)) ? parameter_value[11:0] : trig_level_B;
assign trig_line_B = (!rst_n) ? trig_line_B_default : ((adc_channel == 1'b1) && (parameter_id == trigger_line_id)) ? parameter_value[11:0] : trig_line_B;
assign trig_edge_B = (!rst_n) ? trig_edge_B_default : ((adc_channel == 1'b1) && (parameter_id == edge_id)) ? parameter_value[0:0] : trig_edge_B;
assign wave_run_B = (!rst_n) ? wave_run_B_default : ((adc_channel == 1'b1) && (parameter_id == run_stop_id)) ? parameter_value[0:0] : wave_run_B;
assign h_shift_B = (!rst_n) ? h_shift_B_default : ((adc_channel == 1'b1) && (parameter_id == left_right_id)) ? parameter_value[9:0] : h_shift_B;
assign v_shift_B = (!rst_n) ? v_shift_B_default : ((adc_channel == 1'b1) && (parameter_id == up_down_id)) ? parameter_value[9:0] : v_shift_B;
assign v_scale_B = (!rst_n) ? v_scale_B_default : ((adc_channel == 1'b1) && (parameter_id == voltage_id)) ? parameter_value[4:0] : v_scale_B;
assign ad_outrange_B = (!rst_n) ? ad_outrange_B_default : 1'b0;

assign display_mode = (!rst_n) ? display_mode_default : (parameter_id == display_mode_id) ? parameter_value[2:0] : display_mode;

//逻辑分析仪
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sample_run <= sample_run_default;
    end else begin
        if (parameter_id == sample_run_id) begin
            sample_run <= parameter_value[0:0];
        end else begin
            sample_run <= sample_run;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sample_num <= sample_num_default;
    end else begin
        if (parameter_id == sample_num_id) begin
            sample_num <= parameter_value;
        end else begin
            sample_num <= sample_num;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sample_clk_cfg <= sample_clk_cfg_default;
    end else begin
        if (parameter_id == sample_clk_cfg_id) begin
            sample_clk_cfg <= parameter_value[3:0];
        end else begin
            sample_clk_cfg <= sample_clk_cfg;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        trigger_edge <= trigger_edge_default;
    end else begin
        if (parameter_id == trigger_edge_id) begin
            trigger_edge <= parameter_value[1:0];
        end else begin
            trigger_edge <= trigger_edge;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        trigger_channel <= trigger_channel_default;
    end else begin
        if (parameter_id == trigger_channel_id) begin
            trigger_channel <= parameter_value[2:0];
        end else begin
            trigger_channel <= trigger_channel;
        end
    end
end
// assign sample_run = (!rst_n) ? sample_run_default : (parameter_id == sample_run_id) ? parameter_value[0:0] : sample_run;
// assign sample_num = (!rst_n) ? sample_num_default : (parameter_id == sample_num_id) ? parameter_value : sample_num;
// assign sample_clk_cfg = (!rst_n) ? sample_clk_cfg_default : (parameter_id == sample_clk_cfg_id) ? parameter_value[3:0] : sample_clk_cfg;
// assign trigger_edge = (!rst_n) ? trigger_edge_default : (parameter_id == trigger_edge_id) ? parameter_value[1:0] : trigger_edge;
// assign trigger_channel = (!rst_n) ? trigger_channel_default : (parameter_id == trigger_channel_id) ? parameter_value[2:0] : trigger_channel;
endmodule