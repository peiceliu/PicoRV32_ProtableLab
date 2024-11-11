


module hdmi_display(                                  //显示字符和logo 目前打算添加背景网格+波形（由于这两部分可能出现叠加，所以要在一个模块并且需要判断优先级）
    input             lcd_pclk,     //时钟
    input             rst_n,        //复位，低电平有效
                                    
    input      [10:0] pixel_xpos,   //像素点横坐标
    input      [10:0] pixel_ypos,   //像素点纵坐标 
    output            back_en   ,   //显示这些固定背景的使能 
    output reg [23:0] pixel_data    //像素点数据,
);                                   
          //用于双通道指示其中一个通道                           
//parameter define                   
localparam PIC_X_START = 11'd730;     //图片起始点横坐标 紫光同创的logo
localparam PIC_Y_START = 11'd4;     //图片起始点纵坐标
localparam PIC_WIDTH   = 11'd64;    //图片宽度
localparam PIC_HEIGHT  = 11'd32;    //图片高度

localparam CHAR_X_START_v= 11'd605;     //字符起始点横坐标 电压： 16x48
localparam CHAR_WIDTH_v  = 11'd48;    //字符宽度, 48
localparam CHAR_X_START_shang= 11'd292;     //字符起始点横坐标 频率： 16x48
localparam CHAR_Y_START_shang= 11'd431;    //字符起始点纵坐标
localparam CHAR_WIDTH_shang  = 11'd16;    //字符宽度, 48

localparam CHAR_X_START_cy= 11'd415;     //字符起始点横坐标 采样
localparam CHAR_Y_START_cy= 11'd431;    //字符起始点纵坐标
localparam CHAR_WIDTH_cy  = 11'd80;    //字符宽度, 48
localparam CHAR_HEIGHT = 11'd16;     //字符高度

localparam CHAR_X_START_kd= 11'd50;     //字符起始点横坐标 采样
localparam CHAR_Y_START_kd= 11'd431;    //字符起始点纵坐标
localparam CHAR_WIDTH_kd  = 11'd80;    //字符宽度, 48


localparam CHAR_X_START_p= 11'd10;     //字符起始点横坐标 频率： 16x48
localparam CHAR_Y_START= 11'd1;    //字符起始点纵坐标
localparam CHAR_WIDTH_p  = 11'd48;    //字符宽度, 48

localparam CHAR_X_START_lc= 11'd525;     //字符起始点横坐标 
localparam CHAR_WIDTH_lc  = 11'd80;    //字符宽度, 48

localparam CHAR_X_START_M= 11'd285;//HOR:
localparam CHAR_WIDTH_M = 11'd64;

localparam CHAR_X_START_CH= 11'd405;//VER:
localparam CHAR_WIDTH_CH  = 11'd64;

localparam CHAR_X_START_vpp= 11'd160;     //字符起始点横坐标 峰峰值： 16x64
localparam CHAR_WIDTH_vpp  = 11'd64;    //字符宽度, 64

localparam CHAR_X_START_bk = 11'd740;     //字符起始点横坐标 双
localparam CHAR_Y_START_bkshuang= 11'd161;    //字符起始点纵坐标   示波器通道一
localparam CHAR_Y_START_bktong= 11'd193;    //字符起始点纵坐标
localparam CHAR_Y_START_bkdao= 11'd225;    //字符起始点纵坐标
localparam CHAR_Y_START_bkshi= 11'd257;    //字符起始点纵坐标
localparam CHAR_Y_START_bkbo= 11'd289;    //字符起始点纵坐标
localparam CHAR_Y_START_bkqi= 11'd321;    //字符起始点纵坐标
localparam CHAR_WIDTH_bk = 11'd32;    //字符宽度,32
localparam CHAR_HEIGHT_bk = 11'd32;     //字符高度
localparam BACK_COLOR1  = 24'h000000; //背景色，heise
localparam CHAR_COLOR1  = 24'hffffff; //字符颜色，baise   

//localparam BACK_COLOR  = 24'hffffff; //背景色，白色
//localparam CHAR_COLOR  = 24'hff0000; //字符颜色，红色
localparam BACK_COLOR  = 24'h0000ff; //背景色，蓝色
localparam CHAR_COLOR  = 24'hffffff; //字符颜色，baise
//reg define
reg   [11:0]  rom_addr  ;  //ROM地址
wire  [10:0]  x_cnt_cy;       //横坐标计数器
wire  [10:0]  y_cnt_cy;       //纵坐标计数器

assign  x_cnt_cy = pixel_xpos + 1'b1  - CHAR_X_START_cy; //像素点相对于字符区域起始点水平坐标
assign  y_cnt_cy = pixel_ypos   - CHAR_Y_START_cy; //像素点相对于字符区域起始点水平坐标

wire  [10:0]  x_cnt_kd;       //横坐标计数器
wire  [10:0]  y_cnt_kd;       //纵坐标计数器

assign  x_cnt_kd = pixel_xpos + 1'b1  - CHAR_X_START_kd; //像素点相对于字符区域起始点水平坐标
assign  y_cnt_kd = pixel_ypos   - CHAR_Y_START_kd; //像素点相对于字符区域起始点水平坐标

wire  [10:0]  x_cnt_shang;       //横坐标计数器
wire  [10:0]  y_cnt_shang;       //纵坐标计数器

assign  x_cnt_shang = pixel_xpos + 1'b1  - CHAR_X_START_shang; //像素点相对于字符区域起始点水平坐标
assign  y_cnt_shang = pixel_ypos  - CHAR_Y_START_shang; //像素点相对于字符区域起始点水平坐标
//wire define   
wire  [10:0]  x_cnt_v;       //横坐标计数器
wire  [10:0]  x_cnt_p;       //横坐标计数器
wire  [10:0]  x_cnt_vpp;       //横坐标计数器
wire  [10:0]  x_cnt_m;       //横坐标计数器
wire  [10:0]  x_cnt_ch;       //横坐标计数器
wire  [10:0]  x_cnt_lc;       //横坐标计数器
wire  [10:0]  y_cnt;       //纵坐标计数器
wire          rom_rd_en ;  //ROM读使能信号
wire  [23:0]  rom_rd_data ;//ROM数据
wire         back_en0;
wire         back_en1;

reg [63:0] char_ch[15:0];//CH：
reg [63:0] char_M[15:0];//M：
reg [47:0] char_pin[15:0];//频率：
//reg [47:0] char_vol[15:0];//电压：
reg [63:0] char_vpp[15:0];//峰峰值：

reg [31:0] char_tong [31:0];//双
reg [31:0] char_dao [31:0];//双
reg [31:0] char_shi [31:0];//双
reg [31:0] char_bo [31:0];//双
reg [31:0] char_qi [31:0];//双
reg [31:0] char_yi [31:0];//yi
//*****************************************************
//**                    main code
//*****************************************************
assign   back_en1  =  (((pixel_xpos >= PIC_X_START - 1'b1) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 1'b1) && (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT))
                     ||((pixel_xpos >= CHAR_X_START_p - 1'b1) && (pixel_xpos < CHAR_X_START_p + CHAR_WIDTH_p - 1'b1)&& (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT))
                     ||((pixel_xpos >= CHAR_X_START_vpp - 1'b1) && (pixel_xpos < CHAR_X_START_vpp + CHAR_WIDTH_vpp - 1'b1) && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT))
                    // ||((pixel_xpos >= CHAR_X_START_v - 1'b1) && (pixel_xpos < CHAR_X_START_v + CHAR_WIDTH_v - 1'b1)&& (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT))
                     ||((pixel_xpos >= CHAR_X_START_kd - 1'b1) && (pixel_xpos < CHAR_X_START_kd + CHAR_WIDTH_kd - 1'b1)&& (pixel_ypos >= CHAR_Y_START_kd) && (pixel_ypos < CHAR_Y_START_kd + CHAR_HEIGHT))
                     ||((pixel_xpos >= CHAR_X_START_shang - 1'b1) && (pixel_xpos < CHAR_X_START_shang + CHAR_WIDTH_shang - 1'b1)&& (pixel_ypos >= CHAR_Y_START_shang) && (pixel_ypos < CHAR_Y_START_shang + CHAR_HEIGHT))
                     ||((pixel_xpos >= CHAR_X_START_lc - 1'b1) && (pixel_xpos < CHAR_X_START_lc + CHAR_WIDTH_lc - 1'b1)&& (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT))
                     ||((pixel_xpos >= CHAR_X_START_cy - 1'b1) && (pixel_xpos < CHAR_X_START_cy+ CHAR_WIDTH_cy - 1'b1)&& (pixel_ypos >= CHAR_Y_START_cy) && (pixel_ypos < CHAR_Y_START_cy + CHAR_HEIGHT))
                     ||((pixel_xpos >= CHAR_X_START_M - 1'b1) && (pixel_xpos < CHAR_X_START_M + CHAR_WIDTH_M - 1'b1)&& (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT))
                     ||((pixel_xpos >= CHAR_X_START_CH - 1'b1) && (pixel_xpos < CHAR_X_START_CH + CHAR_WIDTH_CH - 1'b1)&& (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)));

                     wire  [10:0]  x_cnt_bk;       //横坐标计数器
                     assign  x_cnt_bk = pixel_xpos + 1'b1  - CHAR_X_START_bk; //像素点相对于字符区域起始点水平坐标
                     wire  [10:0]  y_cnt_bk0;       //纵坐标计数器
                     assign  y_cnt_bk0 = pixel_ypos - CHAR_Y_START_bkshuang; //像素点相对于字符区域起始点垂直坐标
                     wire  [10:0]  y_cnt_bk1;       //纵坐标计数器
                     assign  y_cnt_bk1 = pixel_ypos - CHAR_Y_START_bktong; //像素点相对于字符区域起始点垂直坐标
                     wire  [10:0]  y_cnt_bk2;       //纵坐标计数器
                     assign  y_cnt_bk2 = pixel_ypos - CHAR_Y_START_bkdao; //像素点相对于字符区域起始点垂直坐标
                     wire  [10:0]  y_cnt_bk3;       //纵坐标计数器
                     assign  y_cnt_bk3 = pixel_ypos - CHAR_Y_START_bkshi; //像素点相对于字符区域起始点垂直坐标
                     wire  [10:0]  y_cnt_bk4;       //纵坐标计数器
                     assign  y_cnt_bk4 = pixel_ypos - CHAR_Y_START_bkbo; //像素点相对于字符区域起始点垂直坐标
                     wire  [10:0]  y_cnt_bk5;       //纵坐标计数器
                     assign  y_cnt_bk5 = pixel_ypos - CHAR_Y_START_bkqi; //像素点相对于字符区域起始点垂直坐标
assign   back_en0  = (((pixel_xpos >= CHAR_X_START_bk - 1'b1)  &&  (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1) && (pixel_ypos >= CHAR_Y_START_bkshuang) && (pixel_ypos < CHAR_Y_START_bkshuang + CHAR_HEIGHT_bk))
                     ||((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1) && (pixel_ypos >= CHAR_Y_START_bktong) && (pixel_ypos < CHAR_Y_START_bktong + CHAR_HEIGHT_bk))
                     ||((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)&& (pixel_ypos >= CHAR_Y_START_bkdao) && (pixel_ypos < CHAR_Y_START_bkdao + CHAR_HEIGHT_bk))
                     ||((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)&& (pixel_ypos >= CHAR_Y_START_bkshi) && (pixel_ypos < CHAR_Y_START_bkshi + CHAR_HEIGHT_bk))
                     ||((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1) && (pixel_ypos >= CHAR_Y_START_bkbo) && (pixel_ypos < CHAR_Y_START_bkbo + CHAR_HEIGHT_bk))
                     ||((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1) && (pixel_ypos >= CHAR_Y_START_bkqi) && (pixel_ypos < CHAR_Y_START_bkqi + CHAR_HEIGHT_bk)));
assign back_en =  (back_en0 || back_en1);

assign  x_cnt_v = pixel_xpos + 1'b1  - CHAR_X_START_v; //像素点相对于字符区域起始点水平坐标
assign  x_cnt_vpp = pixel_xpos + 1'b1  - CHAR_X_START_vpp; //像素点相对于字符区域起始点水平坐标
assign  x_cnt_p = pixel_xpos + 1'b1  - CHAR_X_START_p; //像素点相对于字符区域起始点水平坐标
assign  x_cnt_m = pixel_xpos + 1'b1  - CHAR_X_START_M; //像素点相对于字符区域起始点水平坐标
assign  x_cnt_ch = pixel_xpos + 1'b1  - CHAR_X_START_CH; //像素点相对于字符区域起始点水平坐标
assign  x_cnt_lc = pixel_xpos + 1'b1  - CHAR_X_START_lc; //像素点相对于字符区域起始点水平坐标
assign  y_cnt = pixel_ypos - CHAR_Y_START; //像素点相对于字符区域起始点垂直坐标
assign  rom_rd_en = 1'b1;                  //读使能拉高，即一直读ROM数据

reg [15:0] char_shang [15:0];
//箭头上
always @(posedge lcd_pclk) begin
    char_shang[0 ]  <=   16'h0100;
    char_shang[1 ]  <=   16'h0100;
    char_shang[2 ]  <=   16'h0380;
    char_shang[3 ]  <=   16'h0380;
    char_shang[4 ]  <=   16'h07C0;
    char_shang[5 ]  <=   16'h0540;
    char_shang[6 ]  <=   16'h0920;
    char_shang[7 ]  <=   16'h0100;
    char_shang[8 ]  <=   16'h0100;
    char_shang[9 ]  <=   16'h0100;
    char_shang[10]  <=   16'h0100;
    char_shang[11]  <=   16'h0100;
    char_shang[12]  <=   16'h0100;
    char_shang[13]  <=   16'h0100;
    char_shang[14]  <=   16'h0100;
    char_shang[15]  <=   16'h0100;
    end 
    reg [79:0] char_kd [15:0];
    //箭头上
    always @(posedge lcd_pclk) begin
        char_kd[0 ]  <=   80'h10040100101008800000;
        char_kd[1 ]  <=   80'h08040080082008400000;
        char_kd[2 ]  <=   80'h00043FFE044008400000;
        char_kd[3 ]  <=   80'hFFA422203FF8100000E7;
        char_kd[4 ]  <=   80'h08242220210817FC0042;
        char_kd[5 ]  <=   80'h11243FFC210830000042;
        char_kd[6 ]  <=   80'h212422203FF830081844;
        char_kd[7 ]  <=   80'h7E242220210852081824;
        char_kd[8 ]  <=   80'h042423E0210892080024;
        char_kd[9 ]  <=   80'h092420003FF811100028;
        char_kd[10]  <=   80'h12242FF0010011100028;
        char_kd[11]  <=   80'h24242410010011100018;
        char_kd[12]  <=   80'hCC044220FFFE11201810;
        char_kd[13]  <=   80'h120441C0010010201810;
        char_kd[14]  <=   80'h2114863001001FFE0000;
        char_kd[15]  <=   80'hC088380E010010000000;
        end 


//频率：   16x48
always @(posedge lcd_pclk) begin
char_pin[0 ]  <=   48'h100002000000;
char_pin[1 ]  <=   48'h11FE01000000;
char_pin[2 ]  <=   48'h50207FFC0000;
char_pin[3 ]  <=   48'h5C4002000000;
char_pin[4 ]  <=   48'h51FC44440000;
char_pin[5 ]  <=   48'h51042F880000;
char_pin[6 ]  <=   48'hFF2411100000;
char_pin[7 ]  <=   48'h012422480000;
char_pin[8 ]  <=   48'h11244FE40000;
char_pin[9 ]  <=   48'h552400203000;
char_pin[10]  <=   48'h552401003000;
char_pin[11]  <=   48'h5544FFFE0000;
char_pin[12]  <=   48'h845001003000;
char_pin[13]  <=   48'h088801003000;
char_pin[14]  <=   48'h310401000000;
char_pin[15]  <=   48'hC20201000000;
end 
reg [79:0] char_caiyang [15:0];
//采样时间：
always @(posedge lcd_pclk) begin
    char_caiyang[0 ]  <=   80'h00101104000820000000;
    char_caiyang[1 ]  <=   80'h00F81084000813FC0000;
    char_caiyang[2 ]  <=   80'h3F0010887C0810040000;
    char_caiyang[3 ]  <=   80'h02001000440840040000;
    char_caiyang[4 ]  <=   80'h1110FBFE45FE47C40000;
    char_caiyang[5 ]  <=   80'h09101020440844440000;
    char_caiyang[6 ]  <=   80'h08203020440844440000;
    char_caiyang[7 ]  <=   80'h010039FC7C0844440000;
    char_caiyang[8 ]  <=   80'h7FFC5420448847C40000;
    char_caiyang[9 ]  <=   80'h03805020444844443000;
    char_caiyang[10]  <=   80'h054093FE444844443000;
    char_caiyang[11]  <=   80'h09201020440844440000;
    char_caiyang[12]  <=   80'h111010207C0847C43000;
    char_caiyang[13]  <=   80'h21081020440840043000;
    char_caiyang[14]  <=   80'hC1061020002840140000;
    char_caiyang[15]  <=   80'h01001020001040080000;
end 


reg [79:0] char_lc [15:0];
//量程+—5v
always @(posedge lcd_pclk) begin
    char_lc[0 ]  <=   80'h00000800000000000000;
    char_lc[1 ]  <=   80'h1FF01DFC000000000000;
    char_lc[2 ]  <=   80'h1010F104000001000000;
    char_lc[3 ]  <=   80'h1FF01104000001007E00;
    char_lc[4 ]  <=   80'h10101104000001004000;
    char_lc[5 ]  <=   80'hFFFEFDFC000001004000;
    char_lc[6 ]  <=   80'h0000100000001FF04000;
    char_lc[7 ]  <=   80'h1FF030000000010078EE;
    char_lc[8 ]  <=   80'h111039FE000001004444;
    char_lc[9 ]  <=   80'h1FF05420300001000244;
    char_lc[10]  <=   80'h11105420300001000228;
    char_lc[11]  <=   80'h1FF091FC000000004228;
    char_lc[12]  <=   80'h0100102030001FF04410;
    char_lc[13]  <=   80'h1FF01020300000003810;
    char_lc[14]  <=   80'h010013FE000000000000;
    char_lc[15]  <=   80'h7FFC1000000000000000;
    end 
//峰峰值：
always @(posedge lcd_pclk) begin
char_vpp[0 ]  <=   64'h1040104008400000;
char_vpp[1 ]  <=   64'h1040104008400000;
char_vpp[2 ]  <=   64'h10FC10FC0FFC0000;
char_vpp[3 ]  <=   64'h1088108810400000;
char_vpp[4 ]  <=   64'h5550555010400000;
char_vpp[5 ]  <=   64'h5420542033F80000;
char_vpp[6 ]  <=   64'h54D854D832080000;
char_vpp[7 ]  <=   64'h5726572653F80000;
char_vpp[8 ]  <=   64'h54F854F892080000;
char_vpp[9 ]  <=   64'h5420542013F83000;
char_vpp[10]  <=   64'h54F854F812083000;
char_vpp[11]  <=   64'h5C205C2013F80000;
char_vpp[12]  <=   64'h67FE67FE12083000;
char_vpp[13]  <=   64'h0020002012083000;
char_vpp[14]  <=   64'h002000201FFE0000;
char_vpp[15]  <=   64'h0020002010000000;
end 

//M：   16x32
always @(posedge lcd_pclk) begin
    char_M[0 ]  <=   64'h0000000000000000;
    char_M[1 ]  <=   64'h0000000000000000;
    char_M[2 ]  <=   64'h0000000000000000;
    char_M[3 ]  <=   64'hFC7F07F03FF00000;
    char_M[4 ]  <=   64'h781C1818180C0000;
    char_M[5 ]  <=   64'h781C300C180C0000;
    char_M[6 ]  <=   64'h781C7006180C0180;
    char_M[7 ]  <=   64'h781C700618380380;
    char_M[8 ]  <=   64'h7FFC70061FC00000;
    char_M[9 ]  <=   64'h781C700618600000;
    char_M[10]  <=   64'h781C300618600000;
    char_M[11]  <=   64'h781C300C18300000;
    char_M[12]  <=   64'h781C181818180380;
    char_M[13]  <=   64'hFE7F07E07E0E0380;
    char_M[14]  <=   64'h0000000000000000;
    char_M[15]  <=   64'h0000000000000000;
    end 
//M：   16x48
always @(posedge lcd_pclk) begin
    char_ch[0 ]  <=   64'h0000000000000000;
    char_ch[1 ]  <=   64'h0000000000000000;
    char_ch[2 ]  <=   64'h0000000000000000;
    char_ch[3 ]  <=   64'hFC3F3FFC3FF00000;
    char_ch[4 ]  <=   64'h381C1804180C0000;
    char_ch[5 ]  <=   64'h3C181800180C0000;
    char_ch[6 ]  <=   64'h1C381810180C0180;
    char_ch[7 ]  <=   64'h1E30183018380380;
    char_ch[8 ]  <=   64'h0E601FF01FC00000;
    char_ch[9 ]  <=   64'h0F60181018600000;
    char_ch[10]  <=   64'h07C0180018600000;
    char_ch[11]  <=   64'h07C0180218300000;
    char_ch[12]  <=   64'h0380180418180380;
    char_ch[13]  <=   64'h03807FFC7E0E0380;
    char_ch[14]  <=   64'h0000000000000000;
    char_ch[15]  <=   64'h0000000000000000;
    end 
    always @(posedge lcd_pclk) begin
        char_tong[0 ]  <=   32'h00000000;
        char_tong[1 ]  <=   32'h00000000;
        char_tong[2 ]  <=   32'h000000E0;
        char_tong[3 ]  <=   32'h1C1FFFF0;
        char_tong[4 ]  <=   32'h0E0C01F0;
        char_tong[5 ]  <=   32'h0F01C780;
        char_tong[6 ]  <=   32'h0700FE00;
        char_tong[7 ]  <=   32'h07007C00;
        char_tong[8 ]  <=   32'h07183C30;
        char_tong[9 ]  <=   32'h001FFFF8;
        char_tong[10]  <=   32'h001C3878;
        char_tong[11]  <=   32'h001C3878;
        char_tong[12]  <=   32'h031C3878;
        char_tong[13]  <=   32'h7F9FFFF8;
        char_tong[14]  <=   32'h379C3878;
        char_tong[15]  <=   32'h079C3878;
        char_tong[16]  <=   32'h079C3878;
        char_tong[17]  <=   32'h079C3878;
        char_tong[18]  <=   32'h079FFFF8;
        char_tong[19]  <=   32'h079C3878;
        char_tong[20]  <=   32'h079C3878;
        char_tong[21]  <=   32'h079C3878;
        char_tong[22]  <=   32'h079C3878;
        char_tong[23]  <=   32'h079C3BF8;
        char_tong[24]  <=   32'h079C3BF0;
        char_tong[25]  <=   32'h1FD830F0;
        char_tong[26]  <=   32'h3CF00060;
        char_tong[27]  <=   32'h787FFFFF;
        char_tong[28]  <=   32'h701FFFFC;
        char_tong[29]  <=   32'h0003FFF8;
        char_tong[30]  <=   32'h00000000;
        char_tong[31]  <=   32'h00000000;
    end 
    always @(posedge lcd_pclk) begin
        char_dao[0 ]  <=   32'h00000000;
        char_dao[1 ]  <=   32'h00000000;
        char_dao[2 ]  <=   32'h08060180;
        char_dao[3 ]  <=   32'h0E0783E0;
        char_dao[4 ]  <=   32'h0F03C3C0;
        char_dao[5 ]  <=   32'h0781C780;
        char_dao[6 ]  <=   32'h0781C700;
        char_dao[7 ]  <=   32'h0381CE3C;
        char_dao[8 ]  <=   32'h017FFFFE;
        char_dao[9 ]  <=   32'h00307800;
        char_dao[10]  <=   32'h00007000;
        char_dao[11]  <=   32'h038670E0;
        char_dao[12]  <=   32'h7FC7FFF0;
        char_dao[13]  <=   32'h378700E0;
        char_dao[14]  <=   32'h078700E0;
        char_dao[15]  <=   32'h0787FFE0;
        char_dao[16]  <=   32'h078700E0;
        char_dao[17]  <=   32'h078700E0;
        char_dao[18]  <=   32'h078700E0;
        char_dao[19]  <=   32'h0787FFE0;
        char_dao[20]  <=   32'h078700E0;
        char_dao[21]  <=   32'h078700E0;
        char_dao[22]  <=   32'h078700E0;
        char_dao[23]  <=   32'h0787FFE0;
        char_dao[24]  <=   32'h0F8700E0;
        char_dao[25]  <=   32'h3CE700C0;
        char_dao[26]  <=   32'h78700000;
        char_dao[27]  <=   32'h303F801E;
        char_dao[28]  <=   32'h001FFFFE;
        char_dao[29]  <=   32'h0003FFF8;
        char_dao[30]  <=   32'h00000000;
        char_dao[31]  <=   32'h00000000;
    end 
    always @(posedge lcd_pclk) begin
        char_shi[0 ]  <=   32'h00000000;
        char_shi[1 ]  <=   32'h00000000;
        char_shi[2 ]  <=   32'h00000000;
        char_shi[3 ]  <=   32'h000000C0;
        char_shi[4 ]  <=   32'h000001E0;
        char_shi[5 ]  <=   32'h07FFFFF0;
        char_shi[6 ]  <=   32'h03000000;
        char_shi[7 ]  <=   32'h00000000;
        char_shi[8 ]  <=   32'h00000000;
        char_shi[9 ]  <=   32'h00000000;
        char_shi[10]  <=   32'h00000000;
        char_shi[11]  <=   32'h00000018;
        char_shi[12]  <=   32'h0000003C;
        char_shi[13]  <=   32'h7FFFFFFE;
        char_shi[14]  <=   32'h3003C000;
        char_shi[15]  <=   32'h0003C000;
        char_shi[16]  <=   32'h0043C000;
        char_shi[17]  <=   32'h00F3DC00;
        char_shi[18]  <=   32'h00FBCE00;
        char_shi[19]  <=   32'h01E3C700;
        char_shi[20]  <=   32'h01C3C3C0;
        char_shi[21]  <=   32'h03C3C1E0;
        char_shi[22]  <=   32'h0783C0F0;
        char_shi[23]  <=   32'h0703C0F8;
        char_shi[24]  <=   32'h0E03C078;
        char_shi[25]  <=   32'h1C03C03C;
        char_shi[26]  <=   32'h3803C038;
        char_shi[27]  <=   32'h707FC000;
        char_shi[28]  <=   32'h003FC000;
        char_shi[29]  <=   32'h000F8000;
        char_shi[30]  <=   32'h00070000;
        char_shi[31]  <=   32'h00000000;
    end 
    always @(posedge lcd_pclk) begin
        char_bo[0 ]  <=   32'h00000000;
        char_bo[1 ]  <=   32'h00000000;
        char_bo[2 ]  <=   32'h00001C00;
        char_bo[3 ]  <=   32'h0E001C00;
        char_bo[4 ]  <=   32'h0F001C00;
        char_bo[5 ]  <=   32'h07801C00;
        char_bo[6 ]  <=   32'h03801C00;
        char_bo[7 ]  <=   32'h039C1C38;
        char_bo[8 ]  <=   32'h003FFFFC;
        char_bo[9 ]  <=   32'h003E1C7C;
        char_bo[10]  <=   32'h707E1C70;
        char_bo[11]  <=   32'h3C7E1CE0;
        char_bo[12]  <=   32'h1CFE1CC0;
        char_bo[13]  <=   32'h1EDE1C00;
        char_bo[14]  <=   32'h0EDE1C60;
        char_bo[15]  <=   32'h0DDFFFF0;
        char_bo[16]  <=   32'h019EC0F0;
        char_bo[17]  <=   32'h039EC0E0;
        char_bo[18]  <=   32'h039CE1E0;
        char_bo[19]  <=   32'h071C61C0;
        char_bo[20]  <=   32'h071C7380;
        char_bo[21]  <=   32'h7E1C3780;
        char_bo[22]  <=   32'h7E1C3F00;
        char_bo[23]  <=   32'h1E381E00;
        char_bo[24]  <=   32'h0E381E00;
        char_bo[25]  <=   32'h1E703F80;
        char_bo[26]  <=   32'h1E70F7C0;
        char_bo[27]  <=   32'h1EE1E3F0;
        char_bo[28]  <=   32'h1FC7C0FE;
        char_bo[29]  <=   32'h1F9F007C;
        char_bo[30]  <=   32'h03780010;
        char_bo[31]  <=   32'h00000000;
    end 
    always @(posedge lcd_pclk) begin
        char_qi[0 ]  <=   32'h00000000;
        char_qi[1 ]  <=   32'h00000000;
        char_qi[2 ]  <=   32'h00000000;
        char_qi[3 ]  <=   32'h060E60E0;
        char_qi[4 ]  <=   32'h07FF7FF0;
        char_qi[5 ]  <=   32'h070E70E0;
        char_qi[6 ]  <=   32'h070E70E0;
        char_qi[7 ]  <=   32'h070E70E0;
        char_qi[8 ]  <=   32'h070E70E0;
        char_qi[9 ]  <=   32'h07FE7FE0;
        char_qi[10]  <=   32'h070E70E0;
        char_qi[11]  <=   32'h070FFE00;
        char_qi[12]  <=   32'h00078710;
        char_qi[13]  <=   32'h000F0738;
        char_qi[14]  <=   32'h3FFFFFFC;
        char_qi[15]  <=   32'h181E3000;
        char_qi[16]  <=   32'h003C3C00;
        char_qi[17]  <=   32'h00781E00;
        char_qi[18]  <=   32'h00F00F80;
        char_qi[19]  <=   32'h03E007FE;
        char_qi[20]  <=   32'h0F8EE1FE;
        char_qi[21]  <=   32'h3FFFFFF8;
        char_qi[22]  <=   32'h778EF0E0;
        char_qi[23]  <=   32'h078EF0E0;
        char_qi[24]  <=   32'h078EF0E0;
        char_qi[25]  <=   32'h078EF0E0;
        char_qi[26]  <=   32'h078EF0E0;
        char_qi[27]  <=   32'h07FEFFE0;
        char_qi[28]  <=   32'h078EF0E0;
        char_qi[29]  <=   32'h070CF0C0;
        char_qi[30]  <=   32'h00000000;
        char_qi[31]  <=   32'h00000000;
end 
reg [47:0]  char_vol[15:0];
//电压：
always @(posedge lcd_pclk) begin
char_vol[0 ]  <=   48'h010000000000;
char_vol[1 ]  <=   48'h01003FFE0000;
char_vol[2 ]  <=   48'h010020000000;
char_vol[3 ]  <=   48'h3FF820800000;
char_vol[4 ]  <=   48'h210820800000;
char_vol[5 ]  <=   48'h210820800000;
char_vol[6 ]  <=   48'h210820800000;
char_vol[7 ]  <=   48'h3FF82FFC0000;
char_vol[8 ]  <=   48'h210820800000;
char_vol[9 ]  <=   48'h210820803000;
char_vol[10]  <=   48'h210820903000;
char_vol[11]  <=   48'h3FF820880000;
char_vol[12]  <=   48'h210A20883000;
char_vol[13]  <=   48'h010240803000;
char_vol[14]  <=   48'h01025FFE0000;
char_vol[15]  <=   48'h00FE80000000;
end
always @(posedge lcd_pclk) begin
    char_yi[0 ]  <=   32'h00000000;
    char_yi[1 ]  <=   32'h00000000;
    char_yi[2 ]  <=   32'h00000000;
    char_yi[3 ]  <=   32'h00000000;
    char_yi[4 ]  <=   32'h00000000;
    char_yi[5 ]  <=   32'h00000000;
    char_yi[6 ]  <=   32'h00000000;
    char_yi[7 ]  <=   32'h00000000;
    char_yi[8 ]  <=   32'h00000000;
    char_yi[9 ]  <=   32'h00000000;
    char_yi[10]  <=   32'h00000000;
    char_yi[11]  <=   32'h00000000;
    char_yi[12]  <=   32'h00000000;
    char_yi[13]  <=   32'h00000030;
    char_yi[14]  <=   32'h3FFFFFFC;
    char_yi[15]  <=   32'h00000000;
    char_yi[16]  <=   32'h00000000;
    char_yi[17]  <=   32'h00000000;
    char_yi[18]  <=   32'h00000000;
    char_yi[19]  <=   32'h00000000;
    char_yi[20]  <=   32'h00000000;
    char_yi[21]  <=   32'h00000000;
    char_yi[22]  <=   32'h00000000;
    char_yi[23]  <=   32'h00000000;
    char_yi[24]  <=   32'h00000000;
    char_yi[25]  <=   32'h00000000;
    char_yi[26]  <=   32'h00000000;
    char_yi[27]  <=   32'h00000000;
    char_yi[28]  <=   32'h00000000;
    char_yi[29]  <=   32'h00000000;
    char_yi[30]  <=   32'h00000000;
    char_yi[31]  <=   32'h00000000;
end 

//为LCD不同显示区域绘制图片、字符和背景色
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n)
        pixel_data <= BACK_COLOR;
    else if( (pixel_xpos >= PIC_X_START - 1'b1) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 1'b1) 
          && (pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) )
        pixel_data <= rom_rd_data ;  //显示图片
    else if((pixel_xpos >= CHAR_X_START_p - 1'b1) && (pixel_xpos < CHAR_X_START_p + CHAR_WIDTH_p - 1'b1)
         && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
        if(char_pin[y_cnt][CHAR_WIDTH_p -1'b1 - x_cnt_p])
            pixel_data <= CHAR_COLOR;    //显示字符 频率：
        else
                pixel_data <= BACK_COLOR;    //显示字符区域的背景色
         end
    else 
        if((pixel_xpos >= CHAR_X_START_vpp - 1'b1) && (pixel_xpos < CHAR_X_START_vpp + CHAR_WIDTH_vpp - 1'b1)
         && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
        if(char_vpp[y_cnt][CHAR_WIDTH_vpp -1'b1 - x_cnt_vpp])
            pixel_data <= CHAR_COLOR;    //显示字符 峰峰值：
        else
                pixel_data <= BACK_COLOR;    //显示字符区域的背景色
         end 
 else 
        if((pixel_xpos >= CHAR_X_START_v - 1'b1) && (pixel_xpos < CHAR_X_START_v + CHAR_WIDTH_v - 1'b1)
             && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
            if(char_vol[y_cnt][CHAR_WIDTH_v -1'b1 - x_cnt_v])
                pixel_data <= CHAR_COLOR;    //显示字符 电压：
            else
                    pixel_data <= BACK_COLOR;    //显示字符区域的背景色
             end 
    else 
        if((pixel_xpos >= CHAR_X_START_lc - 1'b1) && (pixel_xpos < CHAR_X_START_lc + CHAR_WIDTH_lc - 1'b1)
             && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
            if(char_lc[y_cnt][CHAR_WIDTH_lc -1'b1 - x_cnt_lc])
                pixel_data <= CHAR_COLOR;    //显示字符 
            else
                    pixel_data <= BACK_COLOR;    //显示字符区域的背景色
             end 
    else 
        if((pixel_xpos >= CHAR_X_START_M - 1'b1) && (pixel_xpos < CHAR_X_START_M + CHAR_WIDTH_M - 1'b1)
             && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
            if(char_M[y_cnt][CHAR_WIDTH_M -1'b1 - x_cnt_m])
                pixel_data <= CHAR_COLOR;    //显示字符 M： HOR
            else
                    pixel_data <= BACK_COLOR;    //显示字符区域的背景色
             end 
   else 
        if((pixel_xpos >= CHAR_X_START_cy - 1'b1) && (pixel_xpos < CHAR_X_START_cy + CHAR_WIDTH_cy - 1'b1)
             && (pixel_ypos >= CHAR_Y_START_cy) && (pixel_ypos < CHAR_Y_START_cy + CHAR_HEIGHT)) begin
            if(char_caiyang[y_cnt_cy][CHAR_WIDTH_cy -1'b1 - x_cnt_cy])
                pixel_data <= CHAR_COLOR;    //显示字符 caiyang
            else
                    pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
             end 
     else 
        if((pixel_xpos >= CHAR_X_START_kd - 1'b1) && (pixel_xpos < CHAR_X_START_kd + CHAR_WIDTH_kd - 1'b1)
             && (pixel_ypos >= CHAR_Y_START_kd) && (pixel_ypos < CHAR_Y_START_kd + CHAR_HEIGHT)) begin
            if(char_kd[y_cnt_kd][CHAR_WIDTH_kd -1'b1 - x_cnt_kd])
                pixel_data <= CHAR_COLOR;    //显示字符 caiyang
            else
                    pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
             end 
   else 
         if((pixel_xpos >= CHAR_X_START_shang - 1'b1) && (pixel_xpos < CHAR_X_START_shang + CHAR_WIDTH_shang - 1'b1)
              && (pixel_ypos >= CHAR_Y_START_shang) && (pixel_ypos < CHAR_Y_START_shang + CHAR_HEIGHT)) begin
             if(char_shang[y_cnt_shang][CHAR_WIDTH_shang -1'b1 - x_cnt_shang])
                 pixel_data <= CHAR_COLOR;    //显示字符 caiyang
             else
                     pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
              end 
    else 
        if((pixel_xpos >= CHAR_X_START_CH - 1'b1) && (pixel_xpos < CHAR_X_START_CH + CHAR_WIDTH_CH - 1'b1)
             && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
            if(char_ch[y_cnt][CHAR_WIDTH_CH -1'b1 - x_cnt_ch])
                pixel_data <= CHAR_COLOR;    //显示字符 CH： VER
            else
                    pixel_data <= BACK_COLOR;    //显示字符区域的背景色
           end 
             else 
                if((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)
                     && (pixel_ypos >= CHAR_Y_START_bkshuang) && (pixel_ypos < CHAR_Y_START_bkshuang + CHAR_HEIGHT_bk)) begin
                    if(char_shi[y_cnt_bk0][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                        pixel_data <= CHAR_COLOR1;    //显示字符 shuang
                    else
                            pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
                     end  
         else 
                        if((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)
                             && (pixel_ypos >= CHAR_Y_START_bktong) && (pixel_ypos < CHAR_Y_START_bktong + CHAR_HEIGHT_bk)) begin
                            if(char_bo[y_cnt_bk1][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                                pixel_data <= CHAR_COLOR1;    //显示字符 通
                            else
                                    pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
                             end  
         else 
                        if((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)
                                     && (pixel_ypos >= CHAR_Y_START_bkdao) && (pixel_ypos < CHAR_Y_START_bkdao + CHAR_HEIGHT_bk)) begin
                        if(char_qi[y_cnt_bk2][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                            pixel_data <= CHAR_COLOR1;    //显示字符 shuang
                        else
                                pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
                         end  
         else 
                    if((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)
                         && (pixel_ypos >= CHAR_Y_START_bkshi) && (pixel_ypos < CHAR_Y_START_bkshi + CHAR_HEIGHT_bk)) begin
                        if(char_tong[y_cnt_bk3][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                            pixel_data <= CHAR_COLOR1;    //显示字符 通
                        else
                                pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
                         end  
        else 
                    if((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)
                                         && (pixel_ypos >= CHAR_Y_START_bkbo) && (pixel_ypos < CHAR_Y_START_bkbo + CHAR_HEIGHT_bk)) begin
                            if(char_dao[y_cnt_bk4][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                                pixel_data <= CHAR_COLOR1;    //显示字符 shuang
                            else
                                    pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
                             end  
             else 
                        if((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)
                             && (pixel_ypos >= CHAR_Y_START_bkqi) && (pixel_ypos < CHAR_Y_START_bkqi + CHAR_HEIGHT_bk)) begin
                            if(char_yi[y_cnt_bk5][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                                pixel_data <= CHAR_COLOR1;    //显示字符 通
                            else
                                    pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
                             end  
          else
                            pixel_data <= BACK_COLOR;        //屏幕背景色
end

//根据当前扫描点的横纵坐标为ROM地址赋值
always @(posedge lcd_pclk or negedge rst_n) begin
    if(!rst_n)
        rom_addr <= 11'd0;
    //当横纵坐标位于图片显示区域时,累加ROM地址    
    else if((pixel_ypos >= PIC_Y_START) && (pixel_ypos < PIC_Y_START + PIC_HEIGHT) 
        && (pixel_xpos >= PIC_X_START - 2'd2) && (pixel_xpos < PIC_X_START + PIC_WIDTH - 2'd2)) 
        rom_addr <= rom_addr + 1'b1;
    //当横纵坐标位于图片区域最后一个像素点时,ROM地址清零    
    else if((pixel_ypos >= PIC_Y_START + PIC_HEIGHT))
        rom_addr <= 11'd0;
end

//ROM：存储图片
ziguanrom2 ziguanrom2_inst (
  .addr(rom_addr),          // input [10:0]
  .clk(lcd_pclk),            // input
  .rst(~rst_n),            // input
  .rd_data(rom_rd_data)     // output [23:0]
);

endmodule 