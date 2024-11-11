module picorv32_soc(
    input clk_50M,
    // input core_clk_125M,
    input resetn,
    input uart_rx,

    output uart_tx,
    output  [7:0]led,//用来指示uart接受到的数据
    input irq_5,
    input irq_6,
    input irq_7,
    //信号发生器
    output [31:0]   dds_frequency_A,//波形频率
    output [13:0]   dds_phase_A,//波形相位
    output [4:0]    dds_Amplitude_A,//波形幅度
    output [2:0]    dds_wave_type_A,//波形类型
    output dds_choose_en_A,//上位机控制or本地按键控制
    output [13:0] vol_bias_A,//电压偏置
    output [7:0] duty_cycle_A,//占空比
    output [31:0] div_fractor_A,//分频系数
    
    output [31:0]   dds_frequency_B,//波形频率
    output [13:0]   dds_phase_B,//波形相位
    output [4:0]    dds_Amplitude_B,//波形幅度
    output [2:0]    dds_wave_type_B,//波形类型
    output dds_choose_en_B,//上位机控制or本地按键控制
    output [13:0] vol_bias_B,//电压偏置
    output [7:0] duty_cycle_B,//占空比
    output [31:0] div_fractor_B,//分频系数

    output [1:0] dds_pwm_choose,//PWM选择

    output [31:0] pinlv_a,//频率
    output [31:0] xiangwei_a,//相位
    output [31:0] v_max_a,//最大电压
    output [31:0] v_min_a,//最小电压
    output [31:0] v_bias_a,//电压偏置

    output [31:0] pinlv_b,//频率
    output [31:0] xiangwei_b,//相位
    output [31:0] v_max_b,//最大电压
    output [31:0] v_min_b,//最小电压
    output [31:0] v_bias_b,//电压偏置

    //示波器
    output grid_change,//网格变化
    //示波器
    output [11:0]    deci_rate_A,//抽样率
    output [11:0]   trig_level_A,//触发电平
    output [11:0]   trig_line_A,//触发线位置
    output          trig_edge_A,//触发边沿
    output          wave_run_A,//run or stop
    output [9:0]    h_shift_A,//水平偏移 bit[9]=0/1 左移/右移
    output [9:0]    v_shift_A,//垂直偏移 bit[9]=0/1 上移/下移
    output [4:0]    v_scale_A,//垂直缩放比例 bit[4]=0/1 缩小/放大
    output          ad_outrange_A,//AD超范围

    output [11:0]    deci_rate_B,//抽样率
    output [11:0]   trig_level_B,//触发电平
    output [11:0]   trig_line_B,//触发线位置
    output          trig_edge_B,//触发边沿
    output          wave_run_B,//run or stop
    output [9:0]    h_shift_B,//水平偏移 bit[9]=0/1 左移/右移
    output [9:0]    v_shift_B,//垂直偏移 bit[9]=0/1 上移/下移
    output [4:0]    v_scale_B,//垂直缩放比例 bit[4]=0/1 缩小/放大
    output          ad_outrange_B,//AD超范围
    output [2:0]    display_mode,//显示模式

    output sample_run,//逻辑分析仪采样运行
    output [31:0] sample_num,//逻辑分析仪采样深度
    output [3:0] sample_clk_cfg,//逻辑分析仪采样率配置
    output [1:0] trigger_edge,//逻辑分析仪触发边沿配置
    output [2:0] trigger_channel//逻辑分析仪触发通道配置
);
/*---------pll 生成125M时钟提供给core ----------*/
// wire core_clk_125M;
// wire pll_lock;//pll锁定，目前未设计相关逻辑
// u_pll u_pll (
//     .clkin1(clk_50M),
//     .clkout0(core_clk_125M),
//     .pll_lock(pll_lock)
// );
//     wire   reset_n0;
//     reg    reset_n/* synthesis syn_maxfan=3 */;
// 	reg [5:0] reset_cnt = 0;
// 	wire resetn0 = &reset_cnt;

// 	always @(posedge clk_50M) begin
// 	  reset_cnt <= reset_cnt + !resetn0;
// 	end

//     assign reset_n0 = resetn0 && resetn && pll_lock; 

// 	always @(posedge core_clk_125M) begin
// 	  reset_n <= reset_n0;
// 	end

/*--------- picorv32软核 ------------*/
parameter integer MEM_WORD = 1024;
parameter [31:0] STACKADDR = (4*MEM_WORD);//堆栈区 4kbit
parameter [31:0] PROGADDR_RESET = 32'h0000_1000;//程序复位起始地址

wire mem_valid;
wire mem_instr;
wire mem_ready;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [3:0] mem_wstrb;
wire [31:0] mem_rdata;
reg [31:0] irq;
wire core_clk_125M = clk_50M;

always@*begin
    irq = 0;
    irq[5] = ~irq_5;
    irq[6] = ~irq_6;
    irq[7] = ~irq_7;
end
picorv32  #(
    .STACKADDR(STACKADDR),
    .PROGADDR_RESET(PROGADDR_RESET),
	.PROGADDR_IRQ(32'h0000_0000),//指令起始地址 32'h0000 ~ 32'h1000 = 2^12 = 4kbit
	.BARREL_SHIFTER(1), 
	.COMPRESSED_ISA(1),
	.ENABLE_MUL(1),
	.ENABLE_DIV(1),
	.ENABLE_IRQ(1),
	.ENABLE_IRQ_QREGS(0)
) picorv32_core(
	.clk(core_clk_125M), 
    .resetn(resetn),
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
parameter [31:0] perp_base_addr = (4*CMD_NUM);//外设基地址 64kbit = 2^16 即堆栈区4kbit 程序区 64kbit - 4kbit = 60kbit

reg ram_ready;
wire ram_en;
reg [31:0]ram_rdata;
reg [31:0] memory [0:CMD_NUM-1];
assign ram_en = mem_valid && !mem_ready && mem_addr < perp_base_addr;

initial begin
    $readmemh("E:/project/fpga_dasai/2024_11_08_test/board_adc/ram.hex",memory,1024);
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
    .resetn(resetn),
    .ser_tx(uart_tx),
    .ser_rx(uart_rx),
    .reg_div_we(reg_div_we),//波特率使能
    .reg_div_di(mem_wdata),//波特率参数输入
    .reg_div_do(reg_div_do),//波特率输出
    .reg_dat_we(reg_dat_we),//uart发送数据使能
    .reg_dat_re(reg_dat_re),//uart接收数据使能
    .reg_dat_di(mem_wdata),//uart发送数据输入
    .reg_dat_do(reg_dat_do),//uart接收数据输出
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
    .resetn(resetn),
    .gpio_data(mem_wdata),
    .gpio_out_we(gpio_out_we),
    .gpio_out_data(gpio_out_data),//gpio根据mem_wdata位选的输出
    .ex_data(ex_data),//外部输入给gpio的数据，即开发板上的GPIO的1、0状态
    .gpio_in_we(gpio_in_we),
    .gpio_in_data(gpio_in_data)//输出ex_data
);

/*--------- parameter_controller ------------*/
parameter_controller parameter_controller(
    .clk(core_clk_125M),
    .rst_n(resetn),
    .parameter_id(parameter_id[7:0]),
    .parameter_value(parameter_value),
    .dds_frequency_A(dds_frequency_A),
    .dds_phase_A(dds_phase_A),
    .dds_Amplitude_A(dds_Amplitude_A),
    .dds_wave_type_A(dds_wave_type_A),
    .dds_choose_en_A(dds_choose_en_A),//上位机控制or本地按键控制
    .vol_bias_A(vol_bias_A),//电压偏置
    .duty_cycle_A(duty_cycle_A),//占空比
    .div_fractor_A(div_fractor_A),//分频系数

    .pinlv_a(pinlv_a),
    .xiangwei_a(xiangwei_a),
    .v_max_a(v_max_a),
    .v_min_a(v_min_a),
    .v_bias_a(v_bias_a),
    
    .pinlv_b(pinlv_b),
    .xiangwei_b(xiangwei_b),
    .v_max_b(v_max_b),
    .v_min_b(v_min_b),
    .v_bias_b(v_bias_b),
    .dds_pwm_choose(dds_pwm_choose),
    // .grid_change(grid_change),
    
    .dds_frequency_B(dds_frequency_B),
    .dds_phase_B(dds_phase_B),
    .dds_Amplitude_B(dds_Amplitude_B),
    .dds_wave_type_B(dds_wave_type_B),
    .dds_choose_en_B(dds_choose_en_B),//上位机控制or本地按键控制
    .vol_bias_B(vol_bias_B),//电压偏置
    .duty_cycle_B(duty_cycle_B),//占空比
    .div_fractor_B(div_fractor_B),//分频系数

    .grid_change(grid_change),
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

    .sample_run(sample_run),
    .sample_num(sample_num),
    .sample_clk_cfg(sample_clk_cfg),
    .trigger_edge(trigger_edge),
    .trigger_channel(trigger_channel)
);
/*--------- BUS_control ------------*/
assign mem_ready = ram_ready || simpleuart_reg_div_sel || (simpleuart_reg_txdat_sel && !reg_dat_wait) || (reg_dat_re ) || gpio_out_sel || gpio_in_sel || parameter_id_enable || parameter_value_enable;
assign mem_rdata = ram_ready ? ram_rdata : simpleuart_reg_div_sel ? reg_div_do : simpleuart_reg_rxdat_sel ? reg_dat_do : gpio_out_sel ? gpio_out_data : gpio_in_sel ? gpio_in_data :
       parameter_id_enable ? parameter_id : parameter_value_enable ? parameter_value : 32'h0000_0000;
                                                                                // reg_dat_re ? reg_dat_do 
/*--------- led ------------*/
//assign led = (simpleuart_reg_dat_sel) ? reg_dat_do[7:0] : led;//led指示uart接收到的数据
assign led = gpio_out_sel ? gpio_out_data[7:0] : led ;//led指示uart接收到的数据
endmodule