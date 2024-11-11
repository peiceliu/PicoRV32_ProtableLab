module hdmi_display_b(                                  //显示字符和logo 目前打算添加背景网格+波形（由于这两部分可能出现叠加，所以要在一个模块并且需要判断优先级）
    input             lcd_pclk,     //时钟
    input             rst_n,        //复位，低电平有效
                                    
    input      [10:0] pixel_xpos,   //像素点横坐标
    input      [10:0] pixel_ypos,   //像素点纵坐标 
    output            back_en   ,   //显示这些固定背景的使能 
    output reg [23:0] pixel_data    //像素点数据,
);                                   
        
localparam CHAR_X_START_p= 11'd10;     //字符起始点横坐标 频率： 16x48
localparam CHAR_Y_START= 11'd446;    //字符起始点纵坐标
localparam CHAR_WIDTH_p  = 11'd48;    //字符宽度, 48
localparam CHAR_HEIGHT = 11'd16;     //字符高度

localparam CHAR_X_START_v= 11'd605;     //字符起始点横坐标 电压： 16x48
localparam CHAR_WIDTH_v  = 11'd48;    //字符宽度, 48

localparam CHAR_X_START_lc= 11'd520;     //字符起始点横坐标 电压： 16x48
localparam CHAR_WIDTH_lc  = 11'd80;    //字符宽度, 48

localparam CHAR_X_START_M= 11'd285;//HOR:
localparam CHAR_WIDTH_M = 11'd64;

localparam CHAR_X_START_CH= 11'd405;//VER:
localparam CHAR_WIDTH_CH  = 11'd64;

localparam CHAR_X_START_vpp= 11'd160;     //字符起始点横坐标 峰峰值： 16x64
localparam CHAR_WIDTH_vpp  = 11'd64;    //字符宽度, 64

localparam CHAR_X_START_bk = 11'd740;     //字符起始点横坐标 双
localparam CHAR_Y_START_bkshuang= 11'd161;    //字符起始点纵坐标
localparam CHAR_Y_START_bktong= 11'd193;    //字符起始点纵坐标
localparam CHAR_Y_START_bkdao= 11'd225;    //字符起始点纵坐标
localparam CHAR_Y_START_bkshi= 11'd257;    //字符起始点纵坐标
localparam CHAR_Y_START_bkbo= 11'd289;    //字符起始点纵坐标
localparam CHAR_Y_START_bkqi= 11'd321;    //字符起始点纵坐标
localparam CHAR_WIDTH_bk = 11'd32;    //字符宽度,32
localparam CHAR_HEIGHT_bk = 11'd32;     //字符高度

//localparam BACK_COLOR  = 24'hffffff; //背景色，白色
//localparam CHAR_COLOR  = 24'hff0000; //字符颜色，红色
localparam BACK_COLOR  = 24'h00ff00; //背景色，绿色
localparam CHAR_COLOR  = 24'hffffff; //字符颜色，baise
localparam BACK_COLOR1  = 24'h000000; //背景色，heise
localparam CHAR_COLOR1  = 24'hffffff; //字符颜色，baise                                    
//reg define


//wire define   
wire  [10:0]  x_cnt_v;       //横坐标计数器
wire  [10:0]  x_cnt_p;       //横坐标计数器
wire  [10:0]  x_cnt_vpp;       //横坐标计数器
wire  [10:0]  x_cnt_m;       //横坐标计数器
wire  [10:0]  x_cnt_ch;       //横坐标计数器
wire  [10:0]  x_cnt_lc;       //横坐标计数器
wire  [10:0]  y_cnt;       //纵坐标计数器
wire         back_en0;
wire         back_en1;
assign back_en =  (back_en0 || back_en1);
reg [63:0] char_ch[15:0];//CH：   VER
reg [63:0] char_M[15:0];//M：     HOR
reg [47:0] char_pin[15:0];//频率：
reg [47:0] char_vol[15:0];//电压：
reg [63:0] char_vpp[15:0];//峰峰值：
reg [31:0] char_shuang [31:0];//双
reg [31:0] char_tong [31:0];//双
reg [31:0] char_dao [31:0];//双
reg [31:0] char_shi [31:0];//双
reg [31:0] char_bo [31:0];//双
reg [31:0] char_qi [31:0];//双

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
//*****************************************************
//**                    main code
//*****************************************************
assign   back_en1  =  (((pixel_xpos >= CHAR_X_START_p - 1'b1) && (pixel_xpos < CHAR_X_START_p + CHAR_WIDTH_p - 1'b1)&& (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT))
                     ||((pixel_xpos >= CHAR_X_START_vpp - 1'b1) && (pixel_xpos < CHAR_X_START_vpp + CHAR_WIDTH_vpp - 1'b1) && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT))
                      ||((pixel_xpos >= CHAR_X_START_lc - 1'b1) && (pixel_xpos < CHAR_X_START_lc + CHAR_WIDTH_lc - 1'b1)&& (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT))
                     // ||((pixel_xpos >= CHAR_X_START_v - 1'b1) && (pixel_xpos < CHAR_X_START_v + CHAR_WIDTH_v - 1'b1)&& (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT))
                     ||((pixel_xpos >= CHAR_X_START_M - 1'b1) && (pixel_xpos < CHAR_X_START_M + CHAR_WIDTH_M - 1'b1)&& (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT))
                     ||((pixel_xpos >= CHAR_X_START_CH - 1'b1) && (pixel_xpos < CHAR_X_START_CH + CHAR_WIDTH_CH - 1'b1)&& (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)));
assign  x_cnt_v = pixel_xpos + 1'b1  - CHAR_X_START_v; //像素点相对于字符区域起始点水平坐标
assign  x_cnt_vpp = pixel_xpos + 1'b1  - CHAR_X_START_vpp; //像素点相对于字符区域起始点水平坐标
assign  x_cnt_p = pixel_xpos + 1'b1  - CHAR_X_START_p; //像素点相对于字符区域起始点水平坐标
assign  x_cnt_m = pixel_xpos + 1'b1  - CHAR_X_START_M; //像素点相对于字符区域起始点水平坐标
assign  x_cnt_ch = pixel_xpos + 1'b1  - CHAR_X_START_CH; //像素点相对于字符区域起始点水平坐标
assign  y_cnt = pixel_ypos - CHAR_Y_START; //像素点相对于字符区域起始点垂直坐标
assign  x_cnt_lc = pixel_xpos + 1'b1  - CHAR_X_START_lc; //像素点相对于字符区域起始点水平坐标

assign   back_en0  = (((pixel_xpos >= CHAR_X_START_bk - 1'b1)  &&  (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1) && (pixel_ypos >= CHAR_Y_START_bkshuang) && (pixel_ypos < CHAR_Y_START_bkshuang + CHAR_HEIGHT_bk))
                     ||((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1) && (pixel_ypos >= CHAR_Y_START_bktong) && (pixel_ypos < CHAR_Y_START_bktong + CHAR_HEIGHT_bk))
                     ||((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)&& (pixel_ypos >= CHAR_Y_START_bkdao) && (pixel_ypos < CHAR_Y_START_bkdao + CHAR_HEIGHT_bk))
                     ||((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)&& (pixel_ypos >= CHAR_Y_START_bkshi) && (pixel_ypos < CHAR_Y_START_bkshi + CHAR_HEIGHT_bk))
                     ||((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1) && (pixel_ypos >= CHAR_Y_START_bkbo) && (pixel_ypos < CHAR_Y_START_bkbo + CHAR_HEIGHT_bk))
                     ||((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1) && (pixel_ypos >= CHAR_Y_START_bkqi) && (pixel_ypos < CHAR_Y_START_bkqi + CHAR_HEIGHT_bk)));
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
always @(posedge lcd_pclk) begin
    char_shuang[0 ]  <=   32'h00000000;
    char_shuang[1 ]  <=   32'h00000000;
    char_shuang[2 ]  <=   32'h00000000;
    char_shuang[3 ]  <=   32'h00000000;
    char_shuang[4 ]  <=   32'h00000000;
    char_shuang[5 ]  <=   32'h00060070;
    char_shuang[6 ]  <=   32'h3FFFFFF8;
    char_shuang[7 ]  <=   32'h180FF070;
    char_shuang[8 ]  <=   32'h000E7070;
    char_shuang[9 ]  <=   32'h000E3070;
    char_shuang[10]  <=   32'h080E30F0;
    char_shuang[11]  <=   32'h0C1E30E0;
    char_shuang[12]  <=   32'h061C30E0;
    char_shuang[13]  <=   32'h031C38E0;
    char_shuang[14]  <=   32'h03BC39E0;
    char_shuang[15]  <=   32'h01F819C0;
    char_shuang[16]  <=   32'h00F81DC0;
    char_shuang[17]  <=   32'h00F01DC0;
    char_shuang[18]  <=   32'h00F80F80;
    char_shuang[19]  <=   32'h00FC0F80;
    char_shuang[20]  <=   32'h01DC0F80;
    char_shuang[21]  <=   32'h03DE0F00;
    char_shuang[22]  <=   32'h038F0F80;
    char_shuang[23]  <=   32'h070F1FC0;
    char_shuang[24]  <=   32'h0E073DE0;
    char_shuang[25]  <=   32'h1C0771F0;
    char_shuang[26]  <=   32'h3801E0F8;
    char_shuang[27]  <=   32'h7003C07E;
    char_shuang[28]  <=   32'h40070038;
    char_shuang[29]  <=   32'h001C0000;
    char_shuang[30]  <=   32'h00000000;
    char_shuang[31]  <=   32'h00000000;
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

//为LCD不同显示区域绘制图片、字符和背景色
always @(posedge lcd_pclk or negedge rst_n) begin
    if (!rst_n)
        pixel_data <= BACK_COLOR; 
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
        if((pixel_xpos >= CHAR_X_START_lc - 1'b1) && (pixel_xpos < CHAR_X_START_lc + CHAR_WIDTH_lc - 1'b1)
             && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
            if(char_lc[y_cnt][CHAR_WIDTH_lc -1'b1 - x_cnt_lc])
                pixel_data <= CHAR_COLOR;    //显示字符 
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
        if((pixel_xpos >= CHAR_X_START_M - 1'b1) && (pixel_xpos < CHAR_X_START_M + CHAR_WIDTH_M - 1'b1)
             && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
            if(char_M[y_cnt][CHAR_WIDTH_M -1'b1 - x_cnt_m])
                pixel_data <= CHAR_COLOR;    //显示字符 M： HOR
            else
                    pixel_data <= BACK_COLOR;    //显示字符区域的背景色
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
            if(char_shuang[y_cnt_bk0][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                pixel_data <= CHAR_COLOR1;    //显示字符 shuang
            else
                    pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
             end  
 else 
                if((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)
                     && (pixel_ypos >= CHAR_Y_START_bktong) && (pixel_ypos < CHAR_Y_START_bktong + CHAR_HEIGHT_bk)) begin
                    if(char_tong[y_cnt_bk1][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                        pixel_data <= CHAR_COLOR1;    //显示字符 通
                    else
                            pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
                     end  
 else 
                if((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)
                             && (pixel_ypos >= CHAR_Y_START_bkdao) && (pixel_ypos < CHAR_Y_START_bkdao + CHAR_HEIGHT_bk)) begin
                if(char_dao[y_cnt_bk2][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                    pixel_data <= CHAR_COLOR1;    //显示字符 shuang
                else
                        pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
                 end  
 else 
            if((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)
                 && (pixel_ypos >= CHAR_Y_START_bkshi) && (pixel_ypos < CHAR_Y_START_bkshi + CHAR_HEIGHT_bk)) begin
                if(char_shi[y_cnt_bk3][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                    pixel_data <= CHAR_COLOR1;    //显示字符 通
                else
                        pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
                 end  
else 
            if((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)
                                 && (pixel_ypos >= CHAR_Y_START_bkbo) && (pixel_ypos < CHAR_Y_START_bkbo + CHAR_HEIGHT_bk)) begin
                    if(char_bo[y_cnt_bk4][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                        pixel_data <= CHAR_COLOR1;    //显示字符 shuang
                    else
                            pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
                     end  

     else 
                if((pixel_xpos >= CHAR_X_START_bk - 1'b1) && (pixel_xpos < CHAR_X_START_bk + CHAR_WIDTH_bk - 1'b1)
                     && (pixel_ypos >= CHAR_Y_START_bkqi) && (pixel_ypos < CHAR_Y_START_bkqi + CHAR_HEIGHT_bk)) begin
                    if(char_qi[y_cnt_bk5][CHAR_WIDTH_bk -1'b1 - x_cnt_bk])
                        pixel_data <= CHAR_COLOR1;    //显示字符 通
                    else
                            pixel_data <= BACK_COLOR1;    //显示字符区域的背景色
                     end  

   else
        pixel_data <= BACK_COLOR;        //屏幕背景色
end


endmodule 















