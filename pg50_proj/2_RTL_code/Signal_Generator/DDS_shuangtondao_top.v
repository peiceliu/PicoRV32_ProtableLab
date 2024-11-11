module DDS_shuangtondao_top(
	input					clk	 	,//125m
	input					rst_n		,
	input					key0_in		,
	input					key1_in		,
	input					key2_in		,
//信号发生器 上位机
    input [31:0]  f_word_A_reg    ,//波形频率
    input [13:0] dds_phase_A_reg  ,//波形相位
    input [4:0] amplitude_A_reg   ,//波形幅度
     input [2:0] wave_A_reg       ,//波形类型
     input       [7:0]   duty_cycle_A_reg  , //占空比
     input       [7:0]   duty_cycle_B_reg  , //占空比
    input       [31:0]  div_fractor_A_reg, //分频系数
    input       [31:0]  div_fractor_B_reg,
    input [31:0] f_word_B_reg     ,//波形频率
    input [13:0] dds_phase_B_reg  ,//波形相位
    input [4:0] amplitude_B_reg   ,//波形幅度
    input [2:0] wave_B_reg        ,//波形类型
    input       dds_choose_en_A_reg,
    input       dds_choose_en_B_reg,
    input [13:0]      vol_bias_B_reg,
    input [13:0]      vol_bias_A_reg,
    input [1:0]       dds_pwm_choose_reg,
	output	wire	      [13:0]  DataA	    ,
    output	wire	        CLKA	    ,
    output	wire	        WRTA	    ,
    output	wire	      [13:0]  DataB	    ,
    output	wire	        CLKB	    ,
    output	wire	        WRTB	  
	);
//按键
    wire    [13:0] vol_bias;
	wire	[2:0]	wave_c	;
	wire	[31:0]	f_word;//频率控制字应该不用改位宽    
	wire	[4:0]	amplitude ;
    wire	[2:0]	wave_c_b	;
    wire	[2:0]	wave_c_c	;

	wire	[31:0]	f_word_b;//频率控制字应该不用改位宽    
	wire	[4:0]	amplitude_b ;
    wire	[13:0]	dac_data_keya ;
    wire	[13:0]	dac_data_keyb ;
    wire    [13:0] vol_bias_b;
   assign  wave_c_c = wave_c_b + 3'b1;
   assign  vol_bias = 14'd0;
   assign  vol_bias_b = 14'd0;

    wire  [31:0] f_word_A       ;//波形频率
    wire  [13:0] dds_phase_A    ;//波形相位
    wire  [4:0]  amplitude_A     ;//波形幅度
    wire  [2:0]  wave_A          ;//波形类型
    wire  [31:0] f_word_B        ;//波形频率
    wire  [13:0] dds_phase_B     ;//波形相位
    wire  [4:0]  amplitude_B     ;//波形幅度
    wire  [2:0]  wave_B          ;//波形类型
    wire         dds_choose_en_A;
    wire         dds_choose_en_B;
    wire  [13:0]      vol_bias_B;
    wire  [13:0]      vol_bias_A;
    wire   [13:0]	dac_dataxin_pwm_A;	//输出的波形数据给到DAC模块
    wire   [13:0]	dac_dataxin_pwm_B;
    wire         [1:0]  dds_pwm_choose;
    wire         [7:0]   duty_cycle_A;
    wire         [7:0] duty_cycle_B;
    wire       [31:0]  div_fractor_A;
    wire      [31:0]  div_fractor_B;

    wire	[13:0]	dac_data0;
    wire	[13:0]	dac_data1;
    wire	[13:0]	dac_data2;
    wire	[13:0]	dac_data3;
    wire	[13:0]	dac_data4;
    wire	[13:0]	dac_data5;
    wire	[13:0]	dac_data6;
    wire	[13:0]	dac_data7;
    wire	[13:0]	dac_data01;
    wire	[13:0]	dac_data11;
    wire	[13:0]	dac_data21;
    wire	[13:0]	dac_data31;
    wire	[13:0]	dac_data41;
    wire	[13:0]	dac_data51;
    wire	[13:0]	dac_data61;
    wire	[13:0]	dac_data71;

assign  f_word_A         = (!rst_n) ? 32'd343597 : f_word_A_reg ;
assign  dds_phase_A     = (!rst_n) ? 14'd0 : dds_phase_A_reg ;
assign  amplitude_A     = (!rst_n) ? 5'd1 : amplitude_A_reg ;
assign  wave_A          = (!rst_n) ? 3'd0 : wave_A_reg ;
assign  f_word_B        = (!rst_n) ? 32'd343597 : f_word_B_reg ;
assign  dds_phase_B     = (!rst_n) ? 14'd0 : dds_phase_B_reg ;
assign  amplitude_B     = (!rst_n) ? 5'd1 : amplitude_B_reg ;
assign  wave_B          = (!rst_n) ? 3'd0 : wave_B_reg ;
assign  dds_choose_en_A = (!rst_n) ? 1'd1 : dds_choose_en_A_reg ;
assign  dds_choose_en_B = (!rst_n) ? 1'd1 : dds_choose_en_B_reg ;
assign  vol_bias_B      = (!rst_n) ? 14'd0 : vol_bias_B_reg ;
assign  vol_bias_A      = (!rst_n) ? 14'd0 : vol_bias_A_reg ; 

assign  dds_pwm_choose  = (!rst_n) ? 2'b00 : dds_pwm_choose_reg;
assign  duty_cycle_A    = (!rst_n) ? 8'd25 : duty_cycle_A_reg  ; 
assign  duty_cycle_B    = (!rst_n) ? 8'd25 : duty_cycle_B_reg  ; 
assign  div_fractor_A   = (!rst_n) ? 32'd10000 : div_fractor_A_reg  ; 
assign  div_fractor_B   = (!rst_n) ? 32'd10000 : div_fractor_B_reg  ; 



/*

//为了仿真故意这么写的
assign  f_word_A         =(!rst_n) ? 32'd343597  :32'd343597  ;
assign  dds_phase_A     = (!rst_n) ? 14'd0      :14'd1024       ;
assign  amplitude_A     = (!rst_n) ? 5'd2       :5'd3        ;
assign  wave_A          = (!rst_n) ? 3'd0        :3'd0        ;
assign  f_word_B        = (!rst_n) ? 32'd343597  :32'd343597  ;
assign  dds_phase_B     = (!rst_n) ? 14'd0       :14'd0       ;
assign  amplitude_B     = (!rst_n) ? 5'd1       :5'd2        ;
assign  wave_B          = (!rst_n) ? 3'd0        :3'd6        ;
assign  dds_choose_en_A = (!rst_n) ? 1'd1        :1'd1        ;
assign  dds_choose_en_B = (!rst_n) ? 1'd1        :1'd0        ;
assign  vol_bias_B      = (!rst_n) ? 14'd0       :14'd1024       ;
assign  vol_bias_A      = (!rst_n) ? 14'd0       :14'd512       ;
assign  dds_pwm_choose  = (!rst_n) ? 2'b00       :2'b00       ;
assign  duty_cycle_A    = (!rst_n) ? 8'd70       :8'd30       ;
assign  duty_cycle_B    = (!rst_n) ? 8'd50       :8'd50       ;
assign  div_fractor_A   = (!rst_n) ? 32'd10000 : 10000  ; 
assign  div_fractor_B   = (!rst_n) ? 32'd10000 : 10000  ; 
*/


//上位机 
    wire	[13:0]	dac_data_SWJA ;
    wire	[13:0]	dac_data_SWJB ;

    wire	[13:0]	dac_data_xina_d ;
    wire	[13:0]	dac_data_xinb_d ;
assign dac_data_xina_d = dds_choose_en_A ? dac_data_SWJA : dac_data_keya;
assign dac_data_xinb_d = dds_choose_en_B ? dac_data_SWJB : dac_data_keyb;
    wire	[13:0]	dac_data_xina ;
    wire	[13:0]	dac_data_xinb ;
assign dac_data_xina = (dds_pwm_choose == 2'b01) ? dac_dataxin_pwm_A:dac_data_xina_d;
assign dac_data_xinb = (dds_pwm_choose == 2'b10) ? dac_dataxin_pwm_B:dac_data_xinb_d;

//按键控制下的DDS 存储的波形数据会有点不同于上位机
	DDS inst_DDS
	(
		.clk      (clk),
		.rst_n    (rst_n),
        .vol_bias (vol_bias),
		.f_word   (f_word),
		.wave_c   (wave_c),
		.p_word   (dds_phase_A),
		.amplitude(amplitude),
        .dac_data0(dac_data0),
        .dac_data1(dac_data1),
        .dac_data2(dac_data2),
        .dac_data3(dac_data3),
        .dac_data4(dac_data4),
        .dac_data5(dac_data5),
        .dac_data6(dac_data6),
        .dac_data7(dac_data7),
		.dac_dataxin (dac_data_keya)
	);

DDS_B inst_DDS_b
	(
		.clk      (clk),
		.rst_n    (rst_n),
        .vol_bias (vol_bias_b),
		.f_word   (f_word_b),
		.wave_c   (wave_c_c),
		.p_word   (dds_phase_B),
		.amplitude(amplitude_b),
        .dac_data0(dac_data0),
        .dac_data1(dac_data1),
        .dac_data2(dac_data2),
        .dac_data3(dac_data3),
        .dac_data4(dac_data4),
        .dac_data5(dac_data5),
        .dac_data6(dac_data6),
        .dac_data7(dac_data7),
		.dac_dataxin (dac_data_keyb)
	);


F_word_set inst_F_word_set 
	(
		.clk(clk), 
		.rst_n(rst_n), 
		.key1_in(key1_in), 
		.f_word(f_word)
	);
F_word_set inst_F_word_set_b 
	(
		.clk(clk), 
		.rst_n(rst_n), 
		.key1_in(key1_in), 
		.f_word(f_word_b)
	);
	wave_set inst_wave_set 
	(
		.clk(clk), 
		.rst_n(rst_n), 
		.key0_in(key0_in), 
		.wave_c(wave_c)
	);
wave_set inst_wave_set_b
	(
		.clk(clk), 
		.rst_n(rst_n), 
		.key0_in(key0_in), 
		.wave_c(wave_c_b)
	);
	amplitude_set inst_amplitude_set(
		.clk	(clk)		,
		.rst_n	(rst_n)		,
		.key2_in(key2_in)	,

		.amplitude(amplitude)	
	);
amplitude_set inst_amplitude_set_b(
		.clk	(clk)		,
		.rst_n	(rst_n)		,
		.key2_in(key2_in)	,

		.amplitude(amplitude_b)	
	);

//上位机控制
DDS_swj inst_DDS_swj
	(
		.clk      (clk), //125m
		.rst_n    (rst_n),
        .vol_bias (vol_bias_A),
		.f_word   (f_word_A),
		.wave_c   (wave_A),
		.p_word   (dds_phase_A),
        .duty_cycle(duty_cycle_A),
        .dac_dataxin_pwm(dac_dataxin_pwm_A),
		.amplitude(amplitude_A),
        .div_fractor(div_fractor_A),
        .dac_data0(dac_data0),
        .dac_data1(dac_data1),
        .dac_data2(dac_data2),
        .dac_data3(dac_data3),
        .dac_data4(dac_data4),
        .dac_data5(dac_data5),
        .dac_data6(dac_data6),
        .dac_data7(dac_data7),
		.dac_dataxin (dac_data_SWJA)
	);
DDS_swj_b inst_DDS_swj_b
	(
		.clk      (clk),
		.rst_n    (rst_n),
        .vol_bias (vol_bias_B),
		.f_word   (f_word_B),
		.wave_c   (wave_B),
		.p_word   (dds_phase_B),
        .duty_cycle(duty_cycle_B),
        .div_fractor(div_fractor_B),
        .dac_dataxin_pwm(dac_dataxin_pwm_B),
		.amplitude(amplitude_B),
        .dac_data0(dac_data0),
        .dac_data1(dac_data1),
        .dac_data2(dac_data2),
        .dac_data3(dac_data3),
        .dac_data4(dac_data4),
        .dac_data5(dac_data5),
        .dac_data6(dac_data6),
        .dac_data7(dac_data7),
		.dac_dataxin (dac_data_SWJB)
	);


//在选择使能按钮下 判断数据是上位机/按键给入

    DAC DAC_inst(
    .dac_data_0(dac_data_xina ),//DDS从rom中读出的波形数据
    .dac_data_1(dac_data_xinb),//DDS从rom中读出的波形数据
   . rsr_n(rst_n),
   . clk(clk), //125M 需要和DSS时钟同步 这样不需要用FIFO缓存 直接将DDS输出给到驱动就行DA转换
   . DataA(DataA),  //小梅哥DAC有两个通道，目前是考虑单通道
   . ClkA(CLKA),
   . WRTA(WRTA),
   . DataB(DataB),  //小梅哥DAC有两个通道，目前是考虑单通道
   . ClkB(CLKB),
   . WRTB(WRTB)
   );

//相位累加器
   reg   [13:0]   addr;
   reg   [13:0]   addr_1;
	reg	[31:0]	fre_acc_swja;
   reg   [13:0]   addr_swja;
	reg	[31:0]	fre_acc_swjb;
   reg   [13:0]   addr_swjb;
   reg	[31:0]	fre_acc_keya;
   reg   [13:0]   addr_keya;
	reg	[31:0]	fre_acc_keyb;
   reg   [13:0]   addr_keyb;

   //swjA
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			fre_acc_swja <= 0;
		end
		else begin
			fre_acc_swja <= fre_acc_swja + f_word_A;
		end
	end

	//生成查找表地址
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			addr_swja <= 0;
		end
		else begin
			addr_swja <= fre_acc_swja [31:18] + dds_phase_A; //不考虑溢出
		end
	end

//相位累加器   swjb
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			fre_acc_swjb <= 0;
		end
		else begin
			fre_acc_swjb <= fre_acc_swjb + f_word_B;
		end
	end

	//生成查找表地址
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			addr_swjb <= 0;
		end
		else begin
			addr_swjb <= fre_acc_swjb [31:18] + dds_phase_B; //不考虑溢出
		end
	end
//keya
   always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			fre_acc_keya <= 0;
		end
		else begin
			fre_acc_keya <= fre_acc_keya + f_word;
		end
	end

	//生成查找表地址
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			addr_keya <= 0;
		end
		else begin
			addr_keya <= fre_acc_keya [31:18] + dds_phase_A; //不考虑溢出
		end
	end

//相位累加器 keyb 
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			fre_acc_keyb <= 0;
		end
		else begin
			fre_acc_keyb <= fre_acc_keyb + f_word_b;
		end
	end

	//生成查找表地址
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			addr_keyb <= 0;
		end
		else begin
			addr_keyb <= fre_acc_keyb [31:18] + dds_phase_B; //不考虑溢出
		end
	end
/*
    always @(*)           
        begin                                        
          case(dds_choose_en_A)         
      1'b1: addr <= addr_swja;                       //两个都选择上位机
      1'b0: addr <= addr_keya;
      default : addr <= addr_swja;
          endcase
        end               
  always @(*)           
        begin                                        
          case(dds_choose_en_B)         
      1'b1: addr_1 <= addr_swjb;
      1'b0: addr_1 <= addr_keyb;
      default : addr_1 <= addr_swjb;
          endcase
        end                                       
*/
 always @(*)           
        begin                                        
          case({dds_choose_en_A,dds_choose_en_B})         
      2'b11: addr <= addr_swja;                       //两个都选择上位机
      2'b10: addr <= addr_swja;
      2'b01: addr <= addr_swjb;
      2'b00: addr <= addr_keya;
      default : addr <= addr_swja;
          endcase
        end               
                



	//正弦波
	sin_rom sin_rom_inst (
		.addr(addr),          // input [13:0]
        .clk(clk),            // input
        .rst(~rst_n),            // input
        .rd_data(dac_data0)     // output [13:0]
	);

	//三角波
   sanjiao_rom sanjiao_rom_inst (
       .addr(addr),          // input [13:0]
       .clk(clk),            // input
       .rst(~rst_n),            // input
       .rd_data(dac_data1)     // output [13:0]
   );

	//锯齿波
	juchi_rom juchi_rom_inst (
       .addr(addr),          // input [13:0]
       .clk(clk),            // input
       .rst(~rst_n),            // input
       .rd_data(dac_data2)     // output [13:0]
    );
	//方波
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


/*
//正弦波
sin_rom sin_rom_inst1 (
   .addr(addr_1),          // input [13:0]
     .clk(clk),            // input
     .rst(~rst_n),            // input
     .rd_data(dac_data01)     // output [13:0]
);

//三角波
sanjiao_rom sanjiao_rom_inst1 (
    .addr(addr_1),          // input [13:0]
    .clk(clk),            // input
    .rst(~rst_n),            // input
    .rd_data(dac_data11)     // output [13:0]
);

//锯齿波
juchi_rom juchi_rom_inst1 (
    .addr(addr_1),          // input [13:0]
    .clk(clk),            // input
    .rst(~rst_n),            // input
    .rd_data(dac_data21)     // output [13:0]
 );
//方波
 fangbo_rom fangbo_rom_inst1 (
    .addr(addr_1),          // input [13:0]
    .clk(clk),            // input
    .rst(~rst_n),            // input
    .rd_data(dac_data31)     // output [13:0]
  );

jieti_rom jieti_rom_inst1 (
.addr(addr_1),          // input [13:0]
.clk(clk),            // input
.rst(~rst_n),            // input
.rd_data(dac_data41)     // output [13:0]
);

tixing_rom tixing_rom_inst1 (
.addr(addr_1),          // input [13:0]
.clk(clk),            // input
.rst(~rst_n),            // input
.rd_data(dac_data51)     // output [13:0]
);
gauss_rom gauss_rom_inst1 (
.addr(addr_1),          // input [13:0]
.clk(clk),            // input
.rst(~rst_n),            // input
.rd_data(dac_data61)     // output [13:0]
);
xiebo_rom xiebo_rom_inst1 (
.addr(addr_1),          // input [13:0]
.clk(clk),            // input
.rst(~rst_n),            // input
.rd_data(dac_data71)     // output [13:0]
);
*/

endmodule