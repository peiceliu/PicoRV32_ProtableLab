
module biankuang_display_a(
    input             lcd_pclk  ,               //lcd驱动时钟
    input             sys_rst_n ,               //复位信号
	input             wave_run      ,
    input      [9:0]  v_shift,         //波形竖直偏移量，bit[9]=0/1:上移/下移 
    input      [9:0]  h_shift, 
    //input      [4:0]  v_scale,         //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
    input             trig_edge,  // 触发边沿
    input      [1:0]  ch_choose,  //通道选择
    input      [10:0] pixel_xpos,               //像素点横坐标   在例化时将低位宽的像素坐标拼接0即可满足该模块的位宽
    input      [10:0] pixel_ypos,               //像素点纵坐标
    output            run_en,
    output            ch1_en,
    //output            ch2_en,
    output            edge_en,
    output            vshift_en,
    output            hshift_en,
    output reg [23:0] pixel_data_run,
    output reg [23:0] pixel_data_ch1,
    //output reg [23:0] pixel_data_ch2,
    output reg [23:0] pixel_data_edge,
    output reg [23:0] pixel_data_v,                   
    output reg [23:0] pixel_data_h                //对应h_shift的移动显示
   );
//parameter define  
localparam WHITE  = 24'hffffff;     //RGB565 白色    根据RGB565转RGB888的规则是对的上的
localparam BLUE   = 24'h0000ff;     //RGB565 蓝色
localparam GREEN  = 24'h00ff00;   
localparam BLACK  = 24'h000000; 
localparam RED    = 24'hff0000; 

localparam CHAR_X_START= 11'd590;     //字符起始点横坐标 暂停/启动 32x128
localparam CHAR_Y_START= 11'd50;    //字符起始点纵坐标
localparam CHAR_WIDTH = 11'd128;    //字符宽度, 48
localparam CHAR_HEIGHT = 11'd32;     //字符高度

localparam CHAR_Y_START_1= 11'd82;     //字符起始点纵坐标 zuoyou
localparam CHAR_Y_START_2= 11'd114;     //字符起始点纵坐标 上下
localparam CHAR_Y_START_3= 11'd146;     //字符起始点纵坐标 触发沿
localparam CHAR_Y_START_4= 11'd178;     //字符起始点纵坐标 CH1：开/关
//localparam CHAR_Y_START_5= 11'd210;     //字符起始点纵坐标 CH2：开/关
reg [127:0] char_run[31:0];//启动
reg [127:0] char_stop[31:0];//暂停
reg [127:0] char_noyidon[31:0];//没有移动
reg [127:0] char_shang[31:0];//向上移动
reg [127:0] char_xia[31:0];//向下移动
reg [127:0] char_zuo[31:0];//向左移动
reg [127:0] char_you[31:0];//向右移动
reg [127:0] char_eshang[31:0];//EDGE:上
reg [127:0] char_exia[31:0];//EDGE:下
reg [127:0] char_CH1kai[31:0];//CH1:开
reg [127:0] char_CH1guan[31:0];//CH1:关
//reg [127:0] char_CH2kai[31:0];//CH2:开
//reg [127:0] char_CH2guan[31:0];//CH2:关
//wire define   
wire  [10:0]  x_cnt;       //横坐标计数器
assign  x_cnt = pixel_xpos + 1'b1  - CHAR_X_START; //像素点相对于字符区域起始点水平坐标
wire  [10:0]  y_cnt;       //纵坐标计数器
assign  y_cnt = pixel_ypos - CHAR_Y_START; //像素点相对于字符区域起始点垂直坐标
wire  [10:0]  y_cnt1;       //纵坐标计数器
assign  y_cnt1 = pixel_ypos - CHAR_Y_START_1; //像素点相对于字符区域起始点垂直坐标
wire  [10:0]  y_cnt2;       //纵坐标计数器
assign  y_cnt2 = pixel_ypos - CHAR_Y_START_2; //像素点相对于字符区域起始点垂直坐标
wire  [10:0]  y_cnt3;       //纵坐标计数器
assign  y_cnt3 = pixel_ypos - CHAR_Y_START_3; //像素点相对于字符区域起始点垂直坐标
wire  [10:0]  y_cnt4;       //纵坐标计数器
assign  y_cnt4 = pixel_ypos - CHAR_Y_START_4; //像素点相对于字符区域起始点垂直坐标


assign run_en =((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)&& (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT));
assign edge_en =((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)&& (pixel_ypos >= CHAR_Y_START_3) && (pixel_ypos < CHAR_Y_START_3 + CHAR_HEIGHT));
assign ch1_en =((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)&& (pixel_ypos >= CHAR_Y_START_4) && (pixel_ypos < CHAR_Y_START_4 + CHAR_HEIGHT));
assign hshift_en =((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)&& (pixel_ypos >= CHAR_Y_START_1) && (pixel_ypos < CHAR_Y_START_1 + CHAR_HEIGHT)); 
assign vshift_en = ((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)&& (pixel_ypos >= CHAR_Y_START_2) && (pixel_ypos < CHAR_Y_START_2 + CHAR_HEIGHT));
//启动   32x128
always @(posedge lcd_pclk) begin
char_run[0 ]  <=   128'h00000000000000000000000000000000;
char_run[1 ]  <=   128'h00000000000000000000000000000000;
char_run[2 ]  <=   128'h00000000000300000000080000000000;
char_run[3 ]  <=   128'h000000000001800000000E0000000000;
char_run[4 ]  <=   128'h000000000000C00000000C0000000000;
char_run[5 ]  <=   128'h000000000000C000000C0C0000000000;
char_run[6 ]  <=   128'h00000000010080401FFE0C0000000000;
char_run[7 ]  <=   128'h0000000001FFFFE000000C0000000000;
char_run[8 ]  <=   128'h000000000180004000000C0000000000;
char_run[9 ]  <=   128'h000000000180004000000C0000000000;
char_run[10]  <=   128'h00000000018000400000FFFC00000000;
char_run[11]  <=   128'h000000000180004000020C1800000000;
char_run[12]  <=   128'h00000000018000403FFF0C1800000000;
char_run[13]  <=   128'h0000000001FFFFC000800C1800000000;
char_run[14]  <=   128'h000000000180004001E00C1800000000;
char_run[15]  <=   128'h000000000180000001800C1800000000;
char_run[16]  <=   128'h00000000018000000300081800000000;
char_run[17]  <=   128'h00000000019000000300081800000000;
char_run[18]  <=   128'h00000000011FFFE00610181800000000;
char_run[19]  <=   128'h00000000031800C00408181800000000;
char_run[20]  <=   128'h00000000031800C00C0C101800000000;
char_run[21]  <=   128'h00000000031800C00806101800000000;
char_run[22]  <=   128'h00000000031800C0107F301000000000;
char_run[23]  <=   128'h00000000021800C03F83201000000000;
char_run[24]  <=   128'h00000000061800C03802601000000000;
char_run[25]  <=   128'h00000000061800C00000C03000000000;
char_run[26]  <=   128'h00000000041800C00001803000000000;
char_run[27]  <=   128'h00000000081FFFC000010C3000000000;
char_run[28]  <=   128'h00000000181800C0000603E000000000;
char_run[29]  <=   128'h00000000101800C0000801E000000000;
char_run[30]  <=   128'h00000000200000000010008000000000;
char_run[31]  <=   128'h00000000000000000000000000000000;
end 
//没有移动   32x128
always @(posedge lcd_pclk) begin
    char_noyidon[0 ]  <=   128'h00000000000000000000000000000000;
    char_noyidon[1 ]  <=   128'h00000000000000000000000000000000;
    char_noyidon[2 ]  <=   128'h00000000000200000000080000000800;
    char_noyidon[3 ]  <=   128'h0E0383800003800000381C0000000E00;
    char_noyidon[4 ]  <=   128'h0783FFC00003000000FC180000000C00;
    char_noyidon[5 ]  <=   128'h03C3C380000700101F803010000C0C00;
    char_noyidon[6 ]  <=   128'h03C3C3800006003800803FF81FFE0C00;
    char_noyidon[7 ]  <=   128'h01DB83803FFFFFFC0080403000000C00;
    char_noyidon[8 ]  <=   128'h01B38380000C00000080B06000000C00;
    char_noyidon[9 ]  <=   128'h00338380000C0000008118C000000C00;
    char_noyidon[10]  <=   128'h7833838000180000008A19800000FFFC;
    char_noyidon[11]  <=   128'h3C6783FC003001003FFC0B0000020C18;
    char_noyidon[12]  <=   128'h1E6703FE003FFF80018006003FFF0C18;
    char_noyidon[13]  <=   128'h0EEE00000060010001800C0000800C18;
    char_noyidon[14]  <=   128'h0EDC01C000E0010001801A0001E00C18;
    char_noyidon[15]  <=   128'h00FFFFE001E0010003E0630001800C18;
    char_noyidon[16]  <=   128'h01E781E00360010003B1860003000818;
    char_noyidon[17]  <=   128'h01C183C0067FFF00029A0C0803000818;
    char_noyidon[18]  <=   128'h038183800C600100068C1FFC06101818;
    char_noyidon[19]  <=   128'h0381C780106001000488301804081818;
    char_noyidon[20]  <=   128'h0380C70020600100088060380C0C1018;
    char_noyidon[21]  <=   128'h3F00EF00006001000880E03008061018;
    char_noyidon[22]  <=   128'h3F007E00007FFF0010811860107F3010;
    char_noyidon[23]  <=   128'h0F007C0000600100208218C03F832010;
    char_noyidon[24]  <=   128'h0F003C00006001002080098038026010;
    char_noyidon[25]  <=   128'h0F007E0000600100008003000000C030;
    char_noyidon[26]  <=   128'h0F01FF80006001000080060000018030;
    char_noyidon[27]  <=   128'h0F03C7E0006001000080180000010C30;
    char_noyidon[28]  <=   128'h0F0F83FE00603F0000807000000603E0;
    char_noyidon[29]  <=   128'h077E00FC0060070000C38000000801E0;
    char_noyidon[30]  <=   128'h01F0003800400200013C000000100080;
    char_noyidon[31]  <=   128'h00000000000000000000000000000000;
    end 
//暂停   32x128
always @(posedge lcd_pclk) begin
    char_stop[0 ]  <=   128'h00000000000000000000000000000000;
    char_stop[1 ]  <=   128'h00000000000000000000000000000000;
    char_stop[2 ]  <=   128'h00000000004000000100400000000000;
    char_stop[3 ]  <=   128'h0000000000E0007001C0300000000000;
    char_stop[4 ]  <=   128'h0000000000C023F80180300000000000;
    char_stop[5 ]  <=   128'h0000000000C13C000180101000000000;
    char_stop[6 ]  <=   128'h000000003FFFF000033FFFF800000000;
    char_stop[7 ]  <=   128'h00000000018030000300000000000000;
    char_stop[8 ]  <=   128'h00000000033030080204008000000000;
    char_stop[9 ]  <=   128'h0000000003383FFC0603FFC000000000;
    char_stop[10]  <=   128'h00000000063330C00702018000000000;
    char_stop[11]  <=   128'h0000000007FFB0C00E02018000000000;
    char_stop[12]  <=   128'h00000000003070C00E02018000000000;
    char_stop[13]  <=   128'h000000000030B0C00E03FF8000000000;
    char_stop[14]  <=   128'h00000000003F60C01602018000000000;
    char_stop[15]  <=   128'h000000003FF040C02620000800000000;
    char_stop[16]  <=   128'h000000001E30C0C0263FFFFC00000000;
    char_stop[17]  <=   128'h00000000003100800620001800000000;
    char_stop[18]  <=   128'h00000000003200800660001000000000;
    char_stop[19]  <=   128'h0000000000FFFFC0066000E000000000;
    char_stop[20]  <=   128'h0000000000C00180060FFFE000000000;
    char_stop[21]  <=   128'h0000000000C001800600180000000000;
    char_stop[22]  <=   128'h0000000000C001800600180000000000;
    char_stop[23]  <=   128'h0000000000C001800600180000000000;
    char_stop[24]  <=   128'h0000000000FFFF800600180000000000;
    char_stop[25]  <=   128'h0000000000C001800600180000000000;
    char_stop[26]  <=   128'h0000000000C001800600180000000000;
    char_stop[27]  <=   128'h0000000000C001800600180000000000;
    char_stop[28]  <=   128'h0000000000FFFF800601F80000000000;
    char_stop[29]  <=   128'h0000000000C001800600700000000000;
    char_stop[30]  <=   128'h00000000008001000400200000000000;
    char_stop[31]  <=   128'h00000000000000000000000000000000;
end 
//向上移动   32x128
always @(posedge lcd_pclk) begin
    char_shang[0 ]  <=   128'h00000000000000000000000000000000;
    char_shang[1 ]  <=   128'h00000000000000000000000000000000;
    char_shang[2 ]  <=   128'h00070000000200000000080000000800;
    char_shang[3 ]  <=   128'h000780000003800000381C0000000E00;
    char_shang[4 ]  <=   128'h000F00000003000000FC180000000C00;
    char_shang[5 ]  <=   128'h000E0000000300001F803010000C0C00;
    char_shang[6 ]  <=   128'h000C00000003000000803FF81FFE0C00;
    char_shang[7 ]  <=   128'h0C1C0070000300000080403000000C00;
    char_shang[8 ]  <=   128'h0FFFFFF8000300000080B06000000C00;
    char_shang[9 ]  <=   128'h0E00007000030000008118C000000C00;
    char_shang[10]  <=   128'h0E00007000030000008A19800000FFFC;
    char_shang[11]  <=   128'h0E000070000300003FFC0B0000020C18;
    char_shang[12]  <=   128'h0E000070000300C0018006003FFF0C18;
    char_shang[13]  <=   128'h0E301C700003FFE001800C0000800C18;
    char_shang[14]  <=   128'h0E3FFE700003000001801A0001E00C18;
    char_shang[15]  <=   128'h0E381C700003000003E0630001800C18;
    char_shang[16]  <=   128'h0E381C700003000003B1860003000818;
    char_shang[17]  <=   128'h0E381C7000030000029A0C0803000818;
    char_shang[18]  <=   128'h0E381C7000030000068C1FFC06101818;
    char_shang[19]  <=   128'h0E381C70000300000488301804081818;
    char_shang[20]  <=   128'h0E381C7000030000088060380C0C1018;
    char_shang[21]  <=   128'h0E3FFC70000300000880E03008061018;
    char_shang[22]  <=   128'h0E381C700003000010811860107F3010;
    char_shang[23]  <=   128'h0E381C7000030000208218C03F832010;
    char_shang[24]  <=   128'h0E300070000300002080098038026010;
    char_shang[25]  <=   128'h0E00007000030000008003000000C030;
    char_shang[26]  <=   128'h0E000070000300000080060000018030;
    char_shang[27]  <=   128'h0E000FF0000300180080180000010C30;
    char_shang[28]  <=   128'h0E000FF03FFFFFFC00807000000603E0;
    char_shang[29]  <=   128'h0E0001F00000000000C38000000801E0;
    char_shang[30]  <=   128'h0E0000E000000000013C000000100080;
    char_shang[31]  <=   128'h00000000000000000000000000000000;
    end 

//向下移动   32x128
        always @(posedge lcd_pclk) begin
            char_xia[0 ]  <=   128'h00000000000000000000000000000000;
            char_xia[1 ]  <=   128'h00000000000000000000000000000000;
            char_xia[2 ]  <=   128'h00070000000000000000080000000800;
            char_xia[3 ]  <=   128'h000780000000001000381C0000000E00;
            char_xia[4 ]  <=   128'h000F00000000003800FC180000000C00;
            char_xia[5 ]  <=   128'h000E00003FFFFFF81F803010000C0C00;
            char_xia[6 ]  <=   128'h000C00000003000000803FF81FFE0C00;
            char_xia[7 ]  <=   128'h0C1C0070000300000080403000000C00;
            char_xia[8 ]  <=   128'h0FFFFFF8000300000080B06000000C00;
            char_xia[9 ]  <=   128'h0E00007000030000008118C000000C00;
            char_xia[10]  <=   128'h0E00007000030000008A19800000FFFC;
            char_xia[11]  <=   128'h0E000070000300003FFC0B0000020C18;
            char_xia[12]  <=   128'h0E00007000038000018006003FFF0C18;
            char_xia[13]  <=   128'h0E301C700003700001800C0000800C18;
            char_xia[14]  <=   128'h0E3FFE7000031C0001801A0001E00C18;
            char_xia[15]  <=   128'h0E381C7000030F0003E0630001800C18;
            char_xia[16]  <=   128'h0E381C700003038003B1860003000818;
            char_xia[17]  <=   128'h0E381C70000301C0029A0C0803000818;
            char_xia[18]  <=   128'h0E381C70000300C0068C1FFC06101818;
            char_xia[19]  <=   128'h0E381C70000300C00488301804081818;
            char_xia[20]  <=   128'h0E381C7000030000088060380C0C1018;
            char_xia[21]  <=   128'h0E3FFC70000300000880E03008061018;
            char_xia[22]  <=   128'h0E381C700003000010811860107F3010;
            char_xia[23]  <=   128'h0E381C7000030000208218C03F832010;
            char_xia[24]  <=   128'h0E300070000300002080098038026010;
            char_xia[25]  <=   128'h0E00007000030000008003000000C030;
            char_xia[26]  <=   128'h0E000070000300000080060000018030;
            char_xia[27]  <=   128'h0E000FF0000300000080180000010C30;
            char_xia[28]  <=   128'h0E000FF00003000000807000000603E0;
            char_xia[29]  <=   128'h0E0001F00003000000C38000000801E0;
            char_xia[30]  <=   128'h0E0000E000020000013C000000100080;
            char_xia[31]  <=   128'h00000000000000000000000000000000;
            end 
//向左移动   32x128
        always @(posedge lcd_pclk) begin
                char_zuo[0 ]  <=   128'h00000000000000000000000000000000;
                char_zuo[1 ]  <=   128'h00000000000000000000000000000000;
                char_zuo[2 ]  <=   128'h00070000000800000000080000000800;
                char_zuo[3 ]  <=   128'h00078000000E000000381C0000000E00;
                char_zuo[4 ]  <=   128'h000F0000000C000000FC180000000C00;
                char_zuo[5 ]  <=   128'h000E0000000C00001F803010000C0C00;
                char_zuo[6 ]  <=   128'h000C0000000C002000803FF81FFE0C00;
                char_zuo[7 ]  <=   128'h0C1C0070000C00700080403000000C00;
                char_zuo[8 ]  <=   128'h0FFFFFF81FFFFFF80080B06000000C00;
                char_zuo[9 ]  <=   128'h0E00007000180000008118C000000C00;
                char_zuo[10]  <=   128'h0E00007000180000008A19800000FFFC;
                char_zuo[11]  <=   128'h0E000070001800003FFC0B0000020C18;
                char_zuo[12]  <=   128'h0E00007000100000018006003FFF0C18;
                char_zuo[13]  <=   128'h0E301C700030000001800C0000800C18;
                char_zuo[14]  <=   128'h0E3FFE700030000001801A0001E00C18;
                char_zuo[15]  <=   128'h0E381C700020000003E0630001800C18;
                char_zuo[16]  <=   128'h0E381C700060018003B1860003000818;
                char_zuo[17]  <=   128'h0E381C70005FFFC0029A0C0803000818;
                char_zuo[18]  <=   128'h0E381C7000C06000068C1FFC06101818;
                char_zuo[19]  <=   128'h0E381C70008060000488301804081818;
                char_zuo[20]  <=   128'h0E381C7001806000088060380C0C1018;
                char_zuo[21]  <=   128'h0E3FFC70010060000880E03008061018;
                char_zuo[22]  <=   128'h0E381C700200600010811860107F3010;
                char_zuo[23]  <=   128'h0E381C7006006000208218C03F832010;
                char_zuo[24]  <=   128'h0E300070040060002080098038026010;
                char_zuo[25]  <=   128'h0E00007008006000008003000000C030;
                char_zuo[26]  <=   128'h0E000070100060000080060000018030;
                char_zuo[27]  <=   128'h0E000FF0200060300080180000010C30;
                char_zuo[28]  <=   128'h0E000FF003FFFFF800807000000603E0;
                char_zuo[29]  <=   128'h0E0001F00000000000C38000000801E0;
                char_zuo[30]  <=   128'h0E0000E000000000013C000000100080;
                char_zuo[31]  <=   128'h00000000000000000000000000000000;
                end 
//向右移动   32x128
        always @(posedge lcd_pclk) begin
            char_you[0 ]  <=   128'h00000000000000000000000000000000;
            char_you[1 ]  <=   128'h00000000000000000000000000000000;
            char_you[2 ]  <=   128'h00070000000200000000080000000800;
            char_you[3 ]  <=   128'h000780000003800000381C0000000E00;
            char_you[4 ]  <=   128'h000F00000003000000FC180000000C00;
            char_you[5 ]  <=   128'h000E0000000300001F803010000C0C00;
            char_you[6 ]  <=   128'h000C00000006001000803FF81FFE0C00;
            char_you[7 ]  <=   128'h0C1C0070000600380080403000000C00;
            char_you[8 ]  <=   128'h0FFFFFF83FFFFFFC0080B06000000C00;
            char_you[9 ]  <=   128'h0E00007000040000008118C000000C00;
            char_you[10]  <=   128'h0E000070000C0000008A19800000FFFC;
            char_you[11]  <=   128'h0E000070000800003FFC0B0000020C18;
            char_you[12]  <=   128'h0E00007000180000018006003FFF0C18;
            char_you[13]  <=   128'h0E301C700010000001800C0000800C18;
            char_you[14]  <=   128'h0E3FFE700030000001801A0001E00C18;
            char_you[15]  <=   128'h0E381C70002000C003E0630001800C18;
            char_you[16]  <=   128'h0E381C70007FFFE003B1860003000818;
            char_you[17]  <=   128'h0E381C7000F000C0029A0C0803000818;
            char_you[18]  <=   128'h0E381C7000B000C0068C1FFC06101818;
            char_you[19]  <=   128'h0E381C7001B000C00488301804081818;
            char_you[20]  <=   128'h0E381C70033000C0088060380C0C1018;
            char_you[21]  <=   128'h0E3FFC70063000C00880E03008061018;
            char_you[22]  <=   128'h0E381C700C3000C010811860107F3010;
            char_you[23]  <=   128'h0E381C70183000C0208218C03F832010;
            char_you[24]  <=   128'h0E300070203000C02080098038026010;
            char_you[25]  <=   128'h0E000070003000C0008003000000C030;
            char_you[26]  <=   128'h0E000070003000C00080060000018030;
            char_you[27]  <=   128'h0E000FF0003FFFC00080180000010C30;
            char_you[28]  <=   128'h0E000FF0003000C000807000000603E0;
            char_you[29]  <=   128'h0E0001F00030008000C38000000801E0;
            char_you[30]  <=   128'h0E0000E000000000013C000000100080;
            char_you[31]  <=   128'h00000000000000000000000000000000;
            end   
//EDGE：上
always @(posedge lcd_pclk) begin
    char_eshang[0 ]  <=   128'h00000000000000000000000000000000;
    char_eshang[1 ]  <=   128'h00000000000000000000000000000000;
    char_eshang[2 ]  <=   128'h00000000000000000000000200000000;
    char_eshang[3 ]  <=   128'h00000000000000000000000380000000;
    char_eshang[4 ]  <=   128'h00000000000000000000000300000000;
    char_eshang[5 ]  <=   128'h00000000000000000000000300000000;
    char_eshang[6 ]  <=   128'hFFFC7FC003C07FFC0000000300000000;
    char_eshang[7 ]  <=   128'h3C3C18700C30180C0000000300000000;
    char_eshang[8 ]  <=   128'h3C0E1818081018040000000300000000;
    char_eshang[9 ]  <=   128'h3C0E1808181818020000000300000000;
    char_eshang[10]  <=   128'h3C06180C300818020000000300000000;
    char_eshang[11]  <=   128'h3C00180C300818000000000300000000;
    char_eshang[12]  <=   128'h3C101806200018000000000300C00000;
    char_eshang[13]  <=   128'h3C3018066000181001800003FFE00000;
    char_eshang[14]  <=   128'h3C3018066000181003C0000300000000;
    char_eshang[15]  <=   128'h3C7018066000183003C0000300000000;
    char_eshang[16]  <=   128'h3FF0180660001FF00180000300000000;
    char_eshang[17]  <=   128'h3C701806600018300000000300000000;
    char_eshang[18]  <=   128'h3C301806607E18100000000300000000;
    char_eshang[19]  <=   128'h3C301806601818100000000300000000;
    char_eshang[20]  <=   128'h3C301806601818000000000300000000;
    char_eshang[21]  <=   128'h3C001804201818000000000300000000;
    char_eshang[22]  <=   128'h3C02180C301818000000000300000000;
    char_eshang[23]  <=   128'h3C07180C301818020000000300000000;
    char_eshang[24]  <=   128'h3C061818101818020180000300000000;
    char_eshang[25]  <=   128'h3C0E18181818180403C0000300000000;
    char_eshang[26]  <=   128'h3C3E18600C20180C03C0000300000000;
    char_eshang[27]  <=   128'hFFFE7FC007C07FFC0180000300180000;
    char_eshang[28]  <=   128'h000000000000000000003FFFFFFC0000;
    char_eshang[29]  <=   128'h00000000000000000000000000000000;
    char_eshang[30]  <=   128'h00000000000000000000000000000000;
    char_eshang[31]  <=   128'h00000000000000000000000000000000;
    end 
//EDGE：下
    always @(posedge lcd_pclk) begin
        char_exia[0 ]  <=   128'h00000000000000000000000000000000;
        char_exia[1 ]  <=   128'h00000000000000000000000000000000;
        char_exia[2 ]  <=   128'h00000000000000000000000000000000;
        char_exia[3 ]  <=   128'h00000000000000000000000000100000;
        char_exia[4 ]  <=   128'h00000000000000000000000000380000;
        char_exia[5 ]  <=   128'h000000000000000000003FFFFFF80000;
        char_exia[6 ]  <=   128'hFFFC7FC003C07FFC0000000300000000;
        char_exia[7 ]  <=   128'h3C3C18700C30180C0000000300000000;
        char_exia[8 ]  <=   128'h3C0E1818081018040000000300000000;
        char_exia[9 ]  <=   128'h3C0E1808181818020000000300000000;
        char_exia[10]  <=   128'h3C06180C300818020000000300000000;
        char_exia[11]  <=   128'h3C00180C300818000000000300000000;
        char_exia[12]  <=   128'h3C101806200018000000000380000000;
        char_exia[13]  <=   128'h3C301806600018100180000370000000;
        char_exia[14]  <=   128'h3C3018066000181003C000031C000000;
        char_exia[15]  <=   128'h3C7018066000183003C000030F000000;
        char_exia[16]  <=   128'h3FF0180660001FF00180000303800000;
        char_exia[17]  <=   128'h3C701806600018300000000301C00000;
        char_exia[18]  <=   128'h3C301806607E18100000000300C00000;
        char_exia[19]  <=   128'h3C301806601818100000000300C00000;
        char_exia[20]  <=   128'h3C301806601818000000000300000000;
        char_exia[21]  <=   128'h3C001804201818000000000300000000;
        char_exia[22]  <=   128'h3C02180C301818000000000300000000;
        char_exia[23]  <=   128'h3C07180C301818020000000300000000;
        char_exia[24]  <=   128'h3C061818101818020180000300000000;
        char_exia[25]  <=   128'h3C0E18181818180403C0000300000000;
        char_exia[26]  <=   128'h3C3E18600C20180C03C0000300000000;
        char_exia[27]  <=   128'hFFFE7FC007C07FFC0180000300000000;
        char_exia[28]  <=   128'h00000000000000000000000300000000;
        char_exia[29]  <=   128'h00000000000000000000000300000000;
        char_exia[30]  <=   128'h00000000000000000000000200000000;
        char_exia[31]  <=   128'h00000000000000000000000000000000;
        end 
//CH1:开
always @(posedge lcd_pclk) begin
    char_CH1kai[0 ]  <=   128'h00000000000000000000000000000000;
    char_CH1kai[1 ]  <=   128'h00000000000000000000000000000000;
    char_CH1kai[2 ]  <=   128'h00000000000000000000000000000000;
    char_CH1kai[3 ]  <=   128'h00000000000000000000000000200000;
    char_CH1kai[4 ]  <=   128'h00000000000000000000000000700000;
    char_CH1kai[5 ]  <=   128'h000000000000000000001FFFFFF80000;
    char_CH1kai[6 ]  <=   128'h000003E0FC3F0080000000300C000000;
    char_CH1kai[7 ]  <=   128'h0000061C300C0180000000300C000000;
    char_CH1kai[8 ]  <=   128'h0000080C300C1F80000000300C000000;
    char_CH1kai[9 ]  <=   128'h00001806300C0180000000300C000000;
    char_CH1kai[10]  <=   128'h00003002300C0180000000300C000000;
    char_CH1kai[11]  <=   128'h00003002300C0180000000300C000000;
    char_CH1kai[12]  <=   128'h00003000300C0180000000300C000000;
    char_CH1kai[13]  <=   128'h00006000300C0180018000300C000000;
    char_CH1kai[14]  <=   128'h00006000300C018003C000300C180000;
    char_CH1kai[15]  <=   128'h00006000300C018003C03FFFFFFC0000;
    char_CH1kai[16]  <=   128'h000060003FFC0180018000300C000000;
    char_CH1kai[17]  <=   128'h00006000300C0180000000300C000000;
    char_CH1kai[18]  <=   128'h00006000300C0180000000300C000000;
    char_CH1kai[19]  <=   128'h00006000300C0180000000300C000000;
    char_CH1kai[20]  <=   128'h00006000300C0180000000300C000000;
    char_CH1kai[21]  <=   128'h00006000300C0180000000200C000000;
    char_CH1kai[22]  <=   128'h00003002300C0180000000600C000000;
    char_CH1kai[23]  <=   128'h00003002300C0180000000600C000000;
    char_CH1kai[24]  <=   128'h00001004300C0180018000C00C000000;
    char_CH1kai[25]  <=   128'h00001808300C018003C000800C000000;
    char_CH1kai[26]  <=   128'h00000C10300C03C003C001000C000000;
    char_CH1kai[27]  <=   128'h000003E0FC3F1FF8018002000C000000;
    char_CH1kai[28]  <=   128'h0000000000000000000004000C000000;
    char_CH1kai[29]  <=   128'h0000000000000000000018000C000000;
    char_CH1kai[30]  <=   128'h00000000000000000000200008000000;
    char_CH1kai[31]  <=   128'h00000000000000000000000000000000;
    end 
//CH1:关
always @(posedge lcd_pclk) begin
    char_CH1guan[0 ]  <=   128'h00000000000000000000000000000000;
    char_CH1guan[1 ]  <=   128'h00000000000000000000000000000000;
    char_CH1guan[2 ]  <=   128'h00000000000000000000000008000000;
    char_CH1guan[3 ]  <=   128'h0000000000000000000000600E000000;
    char_CH1guan[4 ]  <=   128'h0000000000000000000000300E000000;
    char_CH1guan[5 ]  <=   128'h0000000000000000000000180C000000;
    char_CH1guan[6 ]  <=   128'h000003E0FC3F00800000001C18000000;
    char_CH1guan[7 ]  <=   128'h0000061C300C01800000000C10000000;
    char_CH1guan[8 ]  <=   128'h0000080C300C1F800000000C30000000;
    char_CH1guan[9 ]  <=   128'h00001806300C01800000000020300000;
    char_CH1guan[10]  <=   128'h00003002300C018000000FFFFFF80000;
    char_CH1guan[11]  <=   128'h00003002300C01800000000180000000;
    char_CH1guan[12]  <=   128'h00003000300C01800000000180000000;
    char_CH1guan[13]  <=   128'h00006000300C01800180000180000000;
    char_CH1guan[14]  <=   128'h00006000300C018003C0000180000000;
    char_CH1guan[15]  <=   128'h00006000300C018003C0000180000000;
    char_CH1guan[16]  <=   128'h000060003FFC01800180000180180000;
    char_CH1guan[17]  <=   128'h00006000300C018000003FFFFFFC0000;
    char_CH1guan[18]  <=   128'h00006000300C01800000000340000000;
    char_CH1guan[19]  <=   128'h00006000300C01800000000320000000;
    char_CH1guan[20]  <=   128'h00006000300C01800000000320000000;
    char_CH1guan[21]  <=   128'h00006000300C01800000000610000000;
    char_CH1guan[22]  <=   128'h00003002300C01800000000C18000000;
    char_CH1guan[23]  <=   128'h00003002300C01800000000C08000000;
    char_CH1guan[24]  <=   128'h00001004300C0180018000180C000000;
    char_CH1guan[25]  <=   128'h00001808300C018003C0003007000000;
    char_CH1guan[26]  <=   128'h00000C10300C03C003C0006003800000;
    char_CH1guan[27]  <=   128'h000003E0FC3F1FF80180018001E00000;
    char_CH1guan[28]  <=   128'h00000000000000000000030000FC0000;
    char_CH1guan[29]  <=   128'h000000000000000000000C0000380000;
    char_CH1guan[30]  <=   128'h00000000000000000000300000000000;
    char_CH1guan[31]  <=   128'h00000000000000000000000000000000;
    end 
/*
//CH2:关
always @(posedge lcd_pclk) begin
    char_CH2guan[0 ]  <=   128'h00000000000000000000000000000000;
    char_CH2guan[1 ]  <=   128'h00000000000000000000000000000000;
    char_CH2guan[2 ]  <=   128'h00000000000000000000000008000000;
    char_CH2guan[3 ]  <=   128'h0000000000000000000000600E000000;
    char_CH2guan[4 ]  <=   128'h0000000000000000000000300E000000;
    char_CH2guan[5 ]  <=   128'h0000000000000000000000180C000000;
    char_CH2guan[6 ]  <=   128'h000003E0FC3F07E00000001C18000000;
    char_CH2guan[7 ]  <=   128'h0000061C300C08380000000C10000000;
    char_CH2guan[8 ]  <=   128'h0000080C300C10180000000C30000000;
    char_CH2guan[9 ]  <=   128'h00001806300C200C0000000020300000;
    char_CH2guan[10]  <=   128'h00003002300C200C00000FFFFFF80000;
    char_CH2guan[11]  <=   128'h00003002300C300C0000000180000000;
    char_CH2guan[12]  <=   128'h00003000300C300C0000000180000000;
    char_CH2guan[13]  <=   128'h00006000300C000C0180000180000000;
    char_CH2guan[14]  <=   128'h00006000300C001803C0000180000000;
    char_CH2guan[15]  <=   128'h00006000300C001803C0000180000000;
    char_CH2guan[16]  <=   128'h000060003FFC00300180000180180000;
    char_CH2guan[17]  <=   128'h00006000300C006000003FFFFFFC0000;
    char_CH2guan[18]  <=   128'h00006000300C00C00000000340000000;
    char_CH2guan[19]  <=   128'h00006000300C01800000000320000000;
    char_CH2guan[20]  <=   128'h00006000300C03000000000320000000;
    char_CH2guan[21]  <=   128'h00006000300C02000000000610000000;
    char_CH2guan[22]  <=   128'h00003002300C04040000000C18000000;
    char_CH2guan[23]  <=   128'h00003002300C08040000000C08000000;
    char_CH2guan[24]  <=   128'h00001004300C1004018000180C000000;
    char_CH2guan[25]  <=   128'h00001808300C200C03C0003007000000;
    char_CH2guan[26]  <=   128'h00000C10300C3FF803C0006003800000;
    char_CH2guan[27]  <=   128'h000003E0FC3F3FF80180018001E00000;
    char_CH2guan[28]  <=   128'h00000000000000000000030000FC0000;
    char_CH2guan[29]  <=   128'h000000000000000000000C0000380000;
    char_CH2guan[30]  <=   128'h00000000000000000000300000000000;
    char_CH2guan[31]  <=   128'h00000000000000000000000000000000;
    end 
//CH2:开
always @(posedge lcd_pclk) begin
    char_CH2kai[0 ]  <=   128'h00000000000000000000000000000000;
    char_CH2kai[1 ]  <=   128'h00000000000000000000000000000000;
    char_CH2kai[2 ]  <=   128'h00000000000000000000000000000000;
    char_CH2kai[3 ]  <=   128'h00000000000000000000000000200000;
    char_CH2kai[4 ]  <=   128'h00000000000000000000000000700000;
    char_CH2kai[5 ]  <=   128'h000000000000000000001FFFFFF80000;
    char_CH2kai[6 ]  <=   128'h000003E0FC3F07E0000000300C000000;
    char_CH2kai[7 ]  <=   128'h0000061C300C0838000000300C000000;
    char_CH2kai[8 ]  <=   128'h0000080C300C1018000000300C000000;
    char_CH2kai[9 ]  <=   128'h00001806300C200C000000300C000000;
    char_CH2kai[10]  <=   128'h00003002300C200C000000300C000000;
    char_CH2kai[11]  <=   128'h00003002300C300C000000300C000000;
    char_CH2kai[12]  <=   128'h00003000300C300C000000300C000000;
    char_CH2kai[13]  <=   128'h00006000300C000C018000300C000000;
    char_CH2kai[14]  <=   128'h00006000300C001803C000300C180000;
    char_CH2kai[15]  <=   128'h00006000300C001803C03FFFFFFC0000;
    char_CH2kai[16]  <=   128'h000060003FFC0030018000300C000000;
    char_CH2kai[17]  <=   128'h00006000300C0060000000300C000000;
    char_CH2kai[18]  <=   128'h00006000300C00C0000000300C000000;
    char_CH2kai[19]  <=   128'h00006000300C0180000000300C000000;
    char_CH2kai[20]  <=   128'h00006000300C0300000000300C000000;
    char_CH2kai[21]  <=   128'h00006000300C0200000000200C000000;
    char_CH2kai[22]  <=   128'h00003002300C0404000000600C000000;
    char_CH2kai[23]  <=   128'h00003002300C0804000000600C000000;
    char_CH2kai[24]  <=   128'h00001004300C1004018000C00C000000;
    char_CH2kai[25]  <=   128'h00001808300C200C03C000800C000000;
    char_CH2kai[26]  <=   128'h00000C10300C3FF803C001000C000000;
    char_CH2kai[27]  <=   128'h000003E0FC3F3FF8018002000C000000;
    char_CH2kai[28]  <=   128'h0000000000000000000004000C000000;
    char_CH2kai[29]  <=   128'h0000000000000000000018000C000000;
    char_CH2kai[30]  <=   128'h00000000000000000000200008000000;
    char_CH2kai[31]  <=   128'h00000000000000000000000000000000;
    end 
*/
//为LCD不同显示区域绘制图片、字符和背景色
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        pixel_data_run <= BLACK;
    else case(wave_run)
    1'b1: if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
         && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
        if(char_run[y_cnt][CHAR_WIDTH -1'b1 - x_cnt])
            pixel_data_run <= WHITE;    //显示字符 暂停/启动
        else
                pixel_data_run <= BLUE;    //显示字符区域的背景色
         end
        else    pixel_data_run <= BLACK;
    1'b0:
            if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
            && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
           if(char_stop[y_cnt][CHAR_WIDTH -1'b1 - x_cnt])
                  pixel_data_run <= WHITE;    //显示字符 暂停/启动
           else
                  pixel_data_run <= BLUE;    //显示字符区域的背景色
            end
            else  pixel_data_run <= BLACK;
    default: if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
         && (pixel_ypos >= CHAR_Y_START) && (pixel_ypos < CHAR_Y_START + CHAR_HEIGHT)) begin
        if(char_run[y_cnt][CHAR_WIDTH -1'b1 - x_cnt])
            pixel_data_run <= WHITE;    //显示字符 暂停/启动
        else
                pixel_data_run <= BLUE;    //显示字符区域的背景色
         end
        else    pixel_data_run <= BLACK;
    endcase
end             
           
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        pixel_data_edge <= BLACK;
    else case(trig_edge)
    1'b1:  if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
            && (pixel_ypos >= CHAR_Y_START_3) && (pixel_ypos < CHAR_Y_START_3 + CHAR_HEIGHT)) begin
               if(char_exia[y_cnt3][CHAR_WIDTH -1'b1 - x_cnt])
               pixel_data_edge <= WHITE;    //显示字符 下
            else
                pixel_data_edge <= BLUE;    //显示字符区域的背景色
        end
            else pixel_data_edge <= BLACK;
    1'b0:  if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
                && (pixel_ypos >= CHAR_Y_START_3) && (pixel_ypos < CHAR_Y_START_3 + CHAR_HEIGHT)) begin
                   if(char_eshang[y_cnt3][CHAR_WIDTH -1'b1 - x_cnt])
                   pixel_data_edge <= WHITE;    //显示字符 上
                else
                    pixel_data_edge <= BLUE;    //显示字符区域的背景色
            end
                else pixel_data_edge <= BLACK;
    default:  if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
                    && (pixel_ypos >= CHAR_Y_START_3) && (pixel_ypos < CHAR_Y_START_3 + CHAR_HEIGHT)) begin
                       if(char_exia[y_cnt3][CHAR_WIDTH -1'b1 - x_cnt])
                       pixel_data_edge <= WHITE;    //显示字符 下
                    else
                        pixel_data_edge <= BLUE;    //显示字符区域的背景色
                end
                    else pixel_data_edge <= BLACK;
    endcase
end   
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        pixel_data_ch1 <= BLACK;
    else case(ch_choose[0])
    1'b1:  if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
            && (pixel_ypos >= CHAR_Y_START_4) && (pixel_ypos < CHAR_Y_START_4 + CHAR_HEIGHT)) begin
            if(char_CH1kai[y_cnt4][CHAR_WIDTH -1'b1 - x_cnt])
            pixel_data_ch1 <= WHITE;    //显示字符  CH1:开
        else
            pixel_data_ch1 <= BLUE;    //显示字符区域的背景色
    end
        else    pixel_data_ch1 <= BLACK;
    1'b0:  if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
            && (pixel_ypos >= CHAR_Y_START_4) && (pixel_ypos < CHAR_Y_START_4 + CHAR_HEIGHT)) begin
            if(char_CH1guan[y_cnt4][CHAR_WIDTH -1'b1 - x_cnt])
            pixel_data_ch1 <= WHITE;    //显示字符  CH1:开
        else
            pixel_data_ch1 <= BLUE;    //显示字符区域的背景色
    end
        else    pixel_data_ch1 <= BLACK;
    default: if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
    && (pixel_ypos >= CHAR_Y_START_4) && (pixel_ypos < CHAR_Y_START_4 + CHAR_HEIGHT)) begin
    if(char_CH1kai[y_cnt4][CHAR_WIDTH -1'b1 - x_cnt])
    pixel_data_ch1 <= WHITE;    //显示字符  CH1:开
    else
    pixel_data_ch1 <= BLUE;    //显示字符区域的背景色
    end
else    pixel_data_ch1 <= BLACK;
    endcase
end             
/*
always @(posedge lcd_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        pixel_data_ch2 <= BLACK;
    else case(ch_choose[1])
    1'b1:  if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
              && (pixel_ypos >= CHAR_Y_START_5) && (pixel_ypos < CHAR_Y_START_5 + CHAR_HEIGHT)) begin
             if(char_CH2kai[y_cnt5][CHAR_WIDTH -1'b1 - x_cnt])
             pixel_data_ch2 <= WHITE;    //显示字符  CH2:开
   else
             pixel_data_ch2 <= GREEN;    //显示字符区域的背景色
    end
        else    pixel_data_ch2 <= BLACK;
    1'b0:  if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
            && (pixel_ypos >= CHAR_Y_START_5) && (pixel_ypos < CHAR_Y_START_5 + CHAR_HEIGHT)) begin
           if(char_CH2guan[y_cnt5][CHAR_WIDTH -1'b1 - x_cnt])
           pixel_data_ch2 <= WHITE;    //显示字符  CH2:开
 else
           pixel_data_ch2 <= GREEN;    //显示字符区域的背景色
  end
      else    pixel_data_ch2 <= BLACK;
    default: if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
    && (pixel_ypos >= CHAR_Y_START_5) && (pixel_ypos < CHAR_Y_START_5 + CHAR_HEIGHT)) begin
   if(char_CH2guan[y_cnt5][CHAR_WIDTH -1'b1 - x_cnt])
   pixel_data_ch2 <= WHITE;    //显示字符  CH2:guan
else
   pixel_data_ch2 <= GREEN;    //显示字符区域的背景色
end
else    pixel_data_ch2 <= BLACK;
    endcase
end             
*/

always @(posedge lcd_pclk or negedge sys_rst_n) begin
 if (!sys_rst_n)
    pixel_data_h <= BLACK;
    else 
        begin if(h_shift == 10'b0 ) begin
            if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
             && (pixel_ypos >= CHAR_Y_START_1) && (pixel_ypos < CHAR_Y_START_1 + CHAR_HEIGHT)) begin
            if(char_noyidon[y_cnt1][CHAR_WIDTH -1'b1 - x_cnt])
                pixel_data_h <= WHITE;    //显示字符 没有移动
            else
                    pixel_data_h <= BLUE;    //显示字符区域的背景色
             end
            end
            else if(h_shift[9] == 1'b0 && (h_shift[8:0]> 9'd0) ) begin
                if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
                && (pixel_ypos >= CHAR_Y_START_1) && (pixel_ypos < CHAR_Y_START_1 + CHAR_HEIGHT)) begin
               if(char_zuo[y_cnt1][CHAR_WIDTH -1'b1 - x_cnt])
                   pixel_data_h <= RED;    //显示字符 向zuo移动
               else
                       pixel_data_h <= BLUE;    //显示字符区域的背景色
                end
            end
            else if(h_shift[9] == 1'b1 && (h_shift[8:0]> 9'd0) ) begin
                if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
                && (pixel_ypos >= CHAR_Y_START_1) && (pixel_ypos < CHAR_Y_START_1 + CHAR_HEIGHT)) begin
               if(char_you[y_cnt1][CHAR_WIDTH -1'b1 - x_cnt])
                   pixel_data_h <= RED;    //显示字符 向you移动
               else
                       pixel_data_h <= BLUE;    //显示字符区域的背景色
                end
            end
            end
end    
always @(posedge lcd_pclk or negedge sys_rst_n) begin
 if (!sys_rst_n)
    pixel_data_v <= BLACK;
    else 
        begin if(v_shift == 10'b0 ) begin
            if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
             && (pixel_ypos >= CHAR_Y_START_2) && (pixel_ypos < CHAR_Y_START_2 + CHAR_HEIGHT)) begin
            if(char_noyidon[y_cnt2][CHAR_WIDTH -1'b1 - x_cnt])
                pixel_data_v <= WHITE;    //显示字符 没有移动
            else
                    pixel_data_v <= BLUE;    //显示字符区域的背景色
             end
            end
            else if(v_shift[9] == 1'b0 && (v_shift[8:0]> 9'd0) ) begin
                if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
                && (pixel_ypos >= CHAR_Y_START_2) && (pixel_ypos < CHAR_Y_START_2 + CHAR_HEIGHT)) begin
               if(char_shang[y_cnt2][CHAR_WIDTH -1'b1 - x_cnt])
                   pixel_data_v <= RED;    //显示字符 向上移动
               else
                       pixel_data_v <= BLUE;    //显示字符区域的背景色
                end
            end
            else if(v_shift[9] == 1'b1 && (v_shift[8:0]> 9'd0) ) begin
                if((pixel_xpos >= CHAR_X_START - 1'b1) && (pixel_xpos < CHAR_X_START + CHAR_WIDTH - 1'b1)
                && (pixel_ypos >= CHAR_Y_START_2) && (pixel_ypos < CHAR_Y_START_2 + CHAR_HEIGHT)) begin
               if(char_xia[y_cnt2][CHAR_WIDTH -1'b1 - x_cnt])
                   pixel_data_v <= RED;    //显示字符 向下移动
               else
                       pixel_data_v <= BLUE;    //显示字符区域的背景色
                end
            end
            end
end

endmodule