module picorc32_soc(
    input clk_50M,
    input resetn,
    input uart_rx,
    input core_clk_125M,
    input pll_lock,

    output uart_tx,
    output  [7:0]led,//����ָʾuart���ܵ�������
    input irq_5,
    input irq_6,
    input irq_7,
    // input rst_n,//��λ�ź�
    // input [7:0] parameter_id,//����ID
    // input [31:0] parameter_value,//����ֵ
    //�źŷ�����
    output [31:0] dds_frequency_A,//����Ƶ��
    output [13:0] dds_phase_A,//������λ
    output [4:0] dds_Amplitude_A,//���η���
    output [2:0] dds_wave_type_A,//��������
    
    output [31:0] dds_frequency_B,//����Ƶ��
    output [13:0] dds_phase_B,//������λ
    output [4:0] dds_Amplitude_B,//���η���
    output [2:0] dds_wave_type_B,//��������
     output dds_choose_en_A,//��λ������or���ذ�������
    output [13:0] vol_bias_A,//��ѹƫ��
    output [7:0] duty_cycle_A,//ռ�ձ�
    output [31:0] div_fractor_A,//��Ƶϵ��
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
   //�߼�������
    output        sample_run     ,//�߼������ǲ�������
    output [31:0] sample_num     ,//�߼������ǲ������
    output [3:0] sample_clk_cfg  ,//�߼������ǲ���������
    output [1:0] trigger_edge    ,//�߼������Ǵ�����������
    output [2:0] trigger_channel//�߼������Ǵ���ͨ������
);

    wire   reset_n0;
    reg    reset_n/* synthesis syn_maxfan=3 */;
	reg [5:0] reset_cnt = 0;
	wire resetn0 = &reset_cnt;

	always @(posedge clk_50M) begin
	  reset_cnt <= reset_cnt + !resetn0;
	end

    assign reset_n0 = resetn0 && resetn && pll_lock; 

	always @(posedge core_clk_125M) begin
	  reset_n <= reset_n0;
	end

/*--------- picorv32��� ------------*/
parameter integer MEM_WORD = 1024;
parameter [31:0] STACKADDR = (4*MEM_WORD);//��ջ�� 4kbit
parameter [31:0] PROGADDR_RESET = 32'h0000_1000;//����λ��ʼ��ַ

wire mem_valid;
wire mem_instr;
wire mem_ready;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [3:0] mem_wstrb;
wire [31:0] mem_rdata;
reg [31:0] irq;

always@*begin
    irq = 0;
    irq[5] = ~irq_5;
    irq[6] = ~irq_6;
    irq[7] = ~irq_7;
end
picorv32  #(
    .STACKADDR(STACKADDR),
    .PROGADDR_RESET(PROGADDR_RESET),
	.PROGADDR_IRQ(32'h0000_0000),//ָ����ʼ��ַ 32'h0000 ~ 32'h1000 = 2^12 = 4kbit
	.BARREL_SHIFTER(1), 
	.COMPRESSED_ISA(1),
	.ENABLE_MUL(1),
	.ENABLE_DIV(1),
	.ENABLE_IRQ(1),
	.ENABLE_IRQ_QREGS(0)
) picorv32_core(
	.clk(core_clk_125M), 
    .resetn(reset_n),
    .mem_valid(mem_valid),
    .mem_instr(mem_instr),
    .mem_ready(mem_ready),
	.mem_addr(mem_addr),
	.mem_wdata(mem_wdata),
	.mem_wstrb(mem_wstrb),
	.mem_rdata(mem_rdata),
	.irq(irq)
);
/*--------- cmd mem ------------*/
parameter integer CMD_NUM = 8192;
parameter [31:0] perp_base_addr = (4*CMD_NUM);//�������ַ 64kbit = 2^16 ����ջ��4kbit ������ 64kbit - 4kbit = 60kbit

reg ram_ready;
wire ram_en;
reg [31:0]ram_rdata;
reg [31:0] memory [0:CMD_NUM-1];
assign ram_en = mem_valid && !mem_ready && mem_addr < perp_base_addr;

initial begin
    $readmemh("C:/Users/yxndz/Desktop/ziguan/ram2.hex",memory,1024);
end

always@(posedge core_clk_125M) begin
    ram_ready <= 0;
    if(ram_en) ram_ready <= 1;
end
always@(posedge core_clk_125M)begin
    if(ram_en) ram_rdata <= memory[mem_addr >> 2];
end
always@(posedge core_clk_125M)begin
    if(ram_en)begin
        if(mem_wstrb[0]) memory[mem_addr >> 2][7:0] <= mem_wdata[7:0];
        if(mem_wstrb[1]) memory[mem_addr >> 2][15:8] <= mem_wdata[15:8];
        if(mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
        if(mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
    end
end
/*--------- mem_map ------------*/
parameter [31:0] uart_reg_div_addr = (perp_base_addr + 32'h0000_0000);
parameter [31:0] uart_reg_txdat_addr = (perp_base_addr + 32'h0000_0010);
parameter [31:0] uart_reg_rxdat_addr = (perp_base_addr + 32'h0000_0020);
parameter [31:0] gpio_out_addr = (perp_base_addr + 32'h0000_0070);
parameter [31:0] gpio_in_addr = (perp_base_addr + 32'h0000_0080);

parameter [31:0] parameter_id_addr = (perp_base_addr + 32'h0000_0030);
parameter [31:0] parameter_value_addr = (perp_base_addr + 32'h0000_0040);

wire parameter_id_enable;
wire parameter_value_enable;
wire [31:0] parameter_id;
wire [31:0] parameter_value;

assign parameter_id_enable = (mem_valid && mem_addr == parameter_id_addr);
assign parameter_value_enable = (mem_valid && mem_addr == parameter_value_addr);
assign parameter_id = (mem_valid && mem_addr == parameter_id_addr &&(mem_wstrb == 4'b1111))? mem_wdata : parameter_id;
assign parameter_value = (mem_valid && mem_addr == parameter_value_addr &&(mem_wstrb == 4'b1111) )? mem_wdata : parameter_value;
/*--------- mem_map reg control ------------*/
wire simpleuart_reg_div_sel;
wire simpleuart_reg_txdat_sel;
wire simpleuart_reg_rxdat_sel;
wire gpio_out_sel;
wire gpio_in_sel;

assign simpleuart_reg_div_sel = mem_valid && (mem_addr == uart_reg_div_addr);
assign simpleuart_reg_txdat_sel = mem_valid && (mem_addr == uart_reg_txdat_addr);
assign simpleuart_reg_rxdat_sel = mem_valid && (mem_addr == uart_reg_rxdat_addr);

assign gpio_out_sel = mem_valid && (mem_addr == gpio_out_addr);
assign gpio_in_sel = mem_valid && (mem_addr == gpio_in_addr);
/*--------- uart ------------*/
wire [3:0]reg_div_we;
wire [31:0]reg_div_do;
wire rx_data_valid;
wire reg_dat_we;
wire reg_dat_re;
wire [31:0]reg_dat_do;
wire reg_dat_wait;

assign reg_div_we = simpleuart_reg_div_sel ? mem_wstrb : 4'b0000;
assign reg_dat_we = simpleuart_reg_txdat_sel ? mem_wstrb[0] : 1'b0;
assign reg_dat_re = simpleuart_reg_rxdat_sel && (mem_wstrb == 4'b0000) && rx_data_valid;
simpleuart simpleuart (
    .clk(core_clk_125M),
    .resetn(reset_n),
    .ser_tx(uart_tx),
    .ser_rx(uart_rx),
    .reg_div_we(reg_div_we),//������ʹ��
    .reg_div_di(mem_wdata),//�����ʲ�������
    .reg_div_do(reg_div_do),//���������
    .reg_dat_we(reg_dat_we),//uart��������ʹ��
    .reg_dat_re(reg_dat_re),//uart��������ʹ��
    .reg_dat_di(mem_wdata),//uart������������
    .reg_dat_do(reg_dat_do),//uart�����������
    .reg_dat_wait(reg_dat_wait),
    .rx_data_valid(rx_data_valid)
);
/*--------- gpio ------------*/
wire gpio_out_we;
wire gpio_in_we;
wire [31:0] gpio_out_data;
wire [31:0] gpio_in_data;

assign gpio_out_we = gpio_out_sel ? mem_wstrb : 4'b0000;
assign gpio_in_we = gpio_in_sel ? 4'b1111 : 4'b0000;

gpio gpio(
    .clk(core_clk_125M),
    .resetn(reset_n),
    .gpio_data(mem_wdata),
    .gpio_out_we(gpio_out_we),
    .gpio_out_data(gpio_out_data),//gpio����mem_wdataλѡ�����
    .ex_data(ex_data),//�ⲿ�����gpio�����ݣ����������ϵ�GPIO��1��0״̬
    .gpio_in_we(gpio_in_we),
    .gpio_in_data(gpio_in_data)//���ex_data
);

/*--------- parameter_controller ------------*/
parameter_controller parameter_controller(
    .rst_n(reset_n),
    .parameter_id(parameter_id[7:0]),
    .parameter_value(parameter_value),
    .dds_frequency_A(dds_frequency_A),
    .dds_phase_A(dds_phase_A),
    .dds_Amplitude_A(dds_Amplitude_A),
    .dds_wave_type_A(dds_wave_type_A),
    .dds_frequency_B(dds_frequency_B),
    .dds_phase_B(dds_phase_B),
    .dds_Amplitude_B(dds_Amplitude_B),
    .dds_wave_type_B(dds_wave_type_B),

    .dds_choose_en_A(dds_choose_en_A),
    .vol_bias_A (vol_bias_A),
    .duty_cycle_A(duty_cycle_A),
    .div_fractor_A(div_fractor_A),

    .dds_choose_en_B(dds_choose_en_B),
    .vol_bias_B (vol_bias_B),
    .duty_cycle_B(duty_cycle_B),
    .div_fractor_B(div_fractor_B),

    .dds_pwm_choose(dds_pwm_choose),
    .deci_rate_A(deci_rate_A),
    .trig_level_A(trig_level_A),
    .trig_line_A(trig_line_A),
    .trig_edge_A(trig_edge_A),
    .wave_run_A(wave_run_A),
    .h_shift_A(h_shift_A),
    .v_shift_A(v_shift_A),
    .v_scale_A(v_scale_A),
    .ad_outrange_A(ad_outrange_A),

    .deci_rate_B(deci_rate_B),
    .trig_level_B(trig_level_B),
    .trig_line_B(trig_line_B),
    .trig_edge_B(trig_edge_B),
    .wave_run_B(wave_run_B),
    .h_shift_B(h_shift_B),
    .v_shift_B(v_shift_B),
    .v_scale_B(v_scale_B),
    .ad_outrange_B(ad_outrange_B),
    
    .display_mode(display_mode),
    .sample_run    (sample_run),
    .sample_num    (sample_num),
    .sample_clk_cfg (sample_clk_cfg ),
    .trigger_edge   (trigger_edge   ),
    .trigger_channel(trigger_channel) 
);
/*--------- BUS_control ------------*/
assign mem_ready = ram_ready || simpleuart_reg_div_sel || (simpleuart_reg_txdat_sel && !reg_dat_wait) || (reg_dat_re ) || gpio_out_sel || gpio_in_sel || parameter_id_enable || parameter_value_enable;
assign mem_rdata = ram_ready ? ram_rdata : simpleuart_reg_div_sel ? reg_div_do : simpleuart_reg_rxdat_sel ? reg_dat_do : gpio_out_sel ? gpio_out_data : gpio_in_sel ? gpio_in_data :
       parameter_id_enable ? parameter_id : parameter_value_enable ? parameter_value : 32'h0000_0000;
                                                                                // reg_dat_re ? reg_dat_do 
/*--------- led ------------*/
//assign led = (simpleuart_reg_dat_sel) ? reg_dat_do[7:0] : led;//ledָʾuart���յ�������
assign led = gpio_out_sel ? gpio_out_data[7:0] : led ;//ledָʾuart���յ�������
endmodule