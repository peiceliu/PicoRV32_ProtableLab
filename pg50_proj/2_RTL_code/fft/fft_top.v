
`timescale 1ns / 1ps

module fft_top #(
    parameter                                   RAM_DATA_WIDTH      = 16     ,
    parameter                                   RAM_ADDR_WIDTH      = 8      ,
    parameter                                   INOUT_DATA_WIDTH    = 12     ,
    parameter                                   MUTI                = 1

)
(
    input                                                       clk                     ,
    input                                                       rst_n                   ,
//======================== 输入端口 =====================================
    input      signed   [INOUT_DATA_WIDTH-1:0]                  fft_data_in             ,
    input               [RAM_ADDR_WIDTH-1:0]                    fft_addr_in             ,
    input                                                       fft_data_in_en          ,
    input                                                       ad_clk                  ,
    output reg                                                  s_axis_data_tready      ,
//======================== 输出端口 =====================================
    input                                                       fft_data_out_en         ,   //data_req
    output reg                                                  fft_data_out_last       ,   //fft_eop
    output              [INOUT_DATA_WIDTH-1:0]                  fft_data_out            ,   
    input               [RAM_ADDR_WIDTH-1:0]                    fft_addr_out            ,   //fft_point_cnt
    input                                                       hdmi_clk                ,

    // input                                                       start                   ,   //本轮fft计算开始
    output reg                                                  fft_done                ,   //本轮fft计算完成
    output reg          [RAM_ADDR_WIDTH-1:0]                    ram_waddr_max1          ,   //主频
    output reg          [RAM_ADDR_WIDTH-1:0]                    ram_waddr_max2              //副频
);  

reg  signed             [2*MUTI*RAM_DATA_WIDTH-1:0]             ram_in                  ;
wire signed             [2*MUTI*RAM_DATA_WIDTH-1:0]             ram_out                 ;
wire                                                            ram_wen                 ;
wire                                                            ram_wen_f               ;
wire                                                            ram_ren                 ;
wire                                                            ram_ren_f               ;
wire                    [RAM_ADDR_WIDTH-1:0]                    ram_waddr               ;
wire                    [RAM_ADDR_WIDTH-1:0]                    ram_waddr_f             ;
reg                     [RAM_ADDR_WIDTH-1:0]                    ram_raddr               ;
wire                    [RAM_ADDR_WIDTH-1:0]                    ram_raddr_f             ;
wire                    [15:0]                                  loop_cnt                ;
wire                    [2*MUTI*RAM_DATA_WIDTH-1:0]             ram_in_fr               ;
// wire                    [2*MUTI*RAM_DATA_WIDTH-1:0]             ram_out_fr              ;
wire                                                            ram_wen_fr              ;
wire                                                            ram_ren_fr              ;
// wire                    [RAM_ADDR_WIDTH-1:0]                    ram_waddr_fr            ;
// wire                    [RAM_ADDR_WIDTH-1:0]                    ram_raddr_fr            ;
// wire                                                            fft_valid               ;
reg                     [15:0]                                  loop_cnt_r              ;
wire signed             [MUTI*RAM_DATA_WIDTH-1:0]               ram_out_real            ;
wire signed             [MUTI*RAM_DATA_WIDTH-1:0]               ram_out_imag            ;
reg                     [INOUT_DATA_WIDTH-1:0]                  data_out_max1           ;
reg                     [INOUT_DATA_WIDTH-1:0]                  data_out_max2           ;
reg                     [INOUT_DATA_WIDTH-1:0]                  data_out                ;
reg                     [7:0]                                   fft_data_in_cnt         ;
wire                    [INOUT_DATA_WIDTH-1:0]                  data_in                 ;
reg                     [7:0]                                   fft_data_out_cnt        ;
reg                                                             fft_start               ;
wire                                                            fft_done_r0             ;
reg                                                             fft_done_r1             ;
reg                                                             fft_done_r2             ;
reg                                                             ram_in_full             ;
reg                                                             ram_empty               ;

parameter                                                       DLY = 1                 ;

//=============== 实数虚数分别取绝对值 ====================
assign ram_out_real = (ram_out[MUTI*RAM_DATA_WIDTH-1])? (~ram_out[MUTI*RAM_DATA_WIDTH-1:0]+1) : ram_out[MUTI*RAM_DATA_WIDTH-1:0];
assign ram_out_imag = (ram_out[2*MUTI*RAM_DATA_WIDTH-1])? (~ram_out[2*MUTI*RAM_DATA_WIDTH-1:MUTI*RAM_DATA_WIDTH]+1) : ram_out[2*MUTI*RAM_DATA_WIDTH-1:MUTI*RAM_DATA_WIDTH];


//=============== 复数取绝对值 输出 ==========================
always @(*) begin
    data_out = 'd0;
    ram_in = 'd0;
    if (loop_cnt_r == 'd0) begin
        ram_in[2*MUTI*RAM_DATA_WIDTH-1:0] = {20'b0,data_in};
    end else begin
        ram_in = ram_in_fr;
    end
    if (loop_cnt_r >= 'h007f) begin
        if (ram_out_imag >= (ram_out_real << 1)) begin
            data_out = ram_out_imag[INOUT_DATA_WIDTH-1:0];
        end else if ((ram_out_real >> 1) < ram_out_imag && ram_out_imag < (ram_out_real << 1)) begin
            data_out = (ram_out_imag[INOUT_DATA_WIDTH-1:0] >> 2) + (ram_out_real[INOUT_DATA_WIDTH-1:0] >> 2) + (ram_out_imag[INOUT_DATA_WIDTH-1:0] >> 1) + (ram_out_real[INOUT_DATA_WIDTH-1:0] >> 1);
        end else if (ram_out_imag <= (ram_out_real >> 1)) begin
            data_out = ram_out_real[INOUT_DATA_WIDTH-1:0];
        end
    end else begin
        data_out = 'd0;
    end
end

integer i;
always @(*) begin
    ram_raddr = 'd0;
    if (loop_cnt == 'd0) begin
        for (i = 0; i < RAM_ADDR_WIDTH; i = i + 1) begin
            ram_raddr[i] = ram_raddr_f[RAM_ADDR_WIDTH - 1 - i];
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        loop_cnt_r <=  #DLY 'd0;
    end else begin
        loop_cnt_r <=  #DLY loop_cnt;
    end
end

//======================= 输入逻辑 ===========================================
always @(posedge ad_clk or negedge rst_n) begin
    if (~rst_n) begin
        s_axis_data_tready <= 'd1;
    end else begin
        if (s_axis_data_tready && fft_data_in_en && fft_data_in_cnt == 'd255) begin
            s_axis_data_tready <= #DLY 'd0;
        end else if (~ram_in_full) begin
            s_axis_data_tready <= #DLY 'd1;
        end
    end
end

always @(posedge ad_clk or negedge rst_n) begin
    if (~rst_n) begin
        fft_data_in_cnt <= 'd0;
    end else begin
        if (s_axis_data_tready && fft_data_in_en && fft_data_in_cnt == 'd255) begin
            fft_data_in_cnt <= #DLY 'd0;
        end else if (s_axis_data_tready && fft_data_in_en) begin
            fft_data_in_cnt <= #DLY fft_data_in_cnt + 'd1;
        end 
    end
end

always @(posedge ad_clk or negedge rst_n) begin
    if (~rst_n) begin
        ram_in_full <= 'd0;
    end else begin
        if (s_axis_data_tready && fft_data_in_en && fft_data_in_cnt == 'd255) begin
            ram_in_full <= #DLY 'd1;
        end else if (ram_empty) begin
            ram_in_full <= #DLY 'd0;
        end 
    end
end

//=============================== 输出逻辑 ==============================
always @(posedge hdmi_clk or negedge rst_n) begin
    if (~rst_n) begin
        fft_data_out_last <= 'd0;
    end else begin
        if (fft_data_out_last) begin
            fft_data_out_last <= #DLY 'd0;
        end else if (fft_data_out_en && fft_data_out_cnt == 'd127) begin
            fft_data_out_last <= #DLY 'd1;
        end
    end
end

always @(posedge hdmi_clk or negedge rst_n) begin
    if (~rst_n) begin
        fft_data_out_cnt <= 'd0;
    end else begin
        if (fft_data_out_last) begin
            fft_data_out_cnt <= #DLY 'd0;
        end else if (fft_data_out_en) begin
            fft_data_out_cnt <= #DLY fft_data_out_cnt + 'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        fft_done_r1 <= 'd0;
    end else begin
        if (fft_done_r0) begin
            fft_done_r1 <= #DLY 'd1;
        end else if (fft_data_out_en) begin
            fft_done_r1 <= #DLY 'd0;
        end
    end
end

always @(posedge hdmi_clk or negedge rst_n) begin
    if (~rst_n) begin
        fft_done_r2 <= 'd0;
        fft_done <= 'd0;
    end else begin
        fft_done_r2 <= #DLY fft_done_r1;
        fft_done <= #DLY fft_done_r2;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        fft_start <= 'd0;
    end else begin
        if (ram_in_full && loop_cnt_r == 'd0 && ~fft_done_r1) begin
            fft_start <= #DLY 'd1;
        end else if (fft_start) begin
            fft_start <= #DLY 'd0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ram_empty <= 'd0;
    end else begin
        if (ram_raddr == 'd255) begin
            ram_empty <= #DLY 'd1;
        end else if (s_axis_data_tready && fft_data_in_en) begin
            ram_empty <= #DLY 'd0;
        end
    end
end


assign ram_wen_fr = (loop_cnt < 'h007f)? ram_wen_f:'d0;
assign ram_ren_fr = (loop_cnt != 'd0)? ram_ren_f:'d0;
assign ram_ren = (loop_cnt == 'd0)? ram_ren_f:'d0;

// always @(posedge clk or negedge rst_n) begin
//     if (~rst_n) begin
//         ram_wen <= #DLY 'd0;
//     end else begin
//         if (ram_waddr_f == 8'hff && loop_cnt == 'h007f) begin
//             ram_wen <= #DLY 'd1;
//         end else if (ram_waddr_f == 8'hff && loop_cnt == 'h00ff) begin
//             ram_wen <= #DLY 'd0;
//         end
//     end
// end

assign ram_wen = (loop_cnt >= 'h007f && ~ram_waddr_f[7])? ram_wen_f:'d0; 
assign ram_waddr = (loop_cnt >= 'h007f)? ram_waddr_f: 'd0;
// assign ram_raddr = (loop_cnt == 'd0)? ram_raddr_f: 'd0;

fft #(
    .DATA_WIDTH     (RAM_DATA_WIDTH )               ,
    .ADDR_WIDTH     (RAM_ADDR_WIDTH )               ,
    .MUTI           (MUTI           )              
) fft1 (
    .clk            (clk            )               ,
    .rst_n          (rst_n          )               ,
    .ram_in         (ram_in         )               ,
    .start          (fft_start      )               ,
    .ram_out        (ram_out        )               ,
    .ram_wen        (ram_wen_f      )               ,
    .ram_ren        (ram_ren_f      )               ,
    .ram_waddr      (ram_waddr_f    )               ,
    .ram_raddr      (ram_raddr_f    )               ,
    .loop_cnt       (loop_cnt       )               ,
    .fft_done       (fft_done_r0    )               
);

DPRAM_WRAP #(
    .ADDR_WIDTH     (RAM_ADDR_WIDTH     )               ,      
    .DATA_WIDTH     (2*MUTI*RAM_DATA_WIDTH   )                       
) DPRAM_WRAP_fft (
    .wclk           (clk                )               ,
    .rclk           (clk                )               ,
    .waddr          (ram_waddr_f        )               ,
    .raddr          (ram_raddr_f        )               ,
    .din            (ram_out            )               ,
    .wen            (ram_wen_fr         )               ,
    .ren            (ram_ren_fr         )               ,
    .dout           (ram_in_fr          )                
);

ram_fftout u_ram_fftout (
    .wr_data        (data_out           )               , //input write data
    .wr_addr        (ram_waddr          )               , //input write address
    .wr_en          (ram_wen            )               , //input write enable
    .wr_clk         (clk                )               , //input write clock
    .wr_rst         (~rst_n             )               , //input write reset
    .rd_data        (fft_data_out       )               , //output read data
    .rd_addr        (fft_addr_out       )               , //input read address
    .rd_clk         (hdmi_clk           )               , //input read clock
    .rd_clk_en      (fft_data_out_en    )               , //input read clock enable
    .rd_rst         (~rst_n             )                 //input read reset
);

ram_fftin u_ram_fftine (
    .wr_data        (fft_data_in        ),    // input [11:0]
    .wr_addr        (fft_addr_in        ),    // input [7:0]
    .wr_en          (fft_data_in_en     ),        // input
    .wr_clk         (ad_clk             ),      // input
    .wr_rst         (~rst_n             ),      // input
    .rd_addr        (ram_raddr          ),    // input [7:0]
    .rd_data        (data_in            ),    // output [11:0]
    .rd_clk         (clk                ),      // input
    .rd_clk_en      (ram_ren            ), //input read clock enable
    .rd_rst         (~rst_n             )       // input
);

//================ 主频副频抓取 ===========================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_out_max1 <=  #DLY 'd0;
        data_out_max2 <=  #DLY 'd0;
        ram_waddr_max1 <=  #DLY 'd0;
        ram_waddr_max2 <=  #DLY 'd0;
    end else begin
        if (data_out > data_out_max1 && ram_wen && ram_waddr != 'd0) begin
            data_out_max2 <= #DLY data_out_max1;
            ram_waddr_max2 <= #DLY ram_waddr_max1;
            data_out_max1 <= #DLY data_out;
            ram_waddr_max1 <= #DLY ram_waddr;
        end else if (data_out > data_out_max2 && data_out <= data_out_max1 && ram_wen && ram_waddr != 'd0) begin
            data_out_max2 <= #DLY data_out;
            ram_waddr_max2 <= #DLY ram_waddr;
        end else if (fft_start) begin
            data_out_max1 <=  #DLY 'd0;
            data_out_max2 <=  #DLY 'd0;
            ram_waddr_max1 <=  #DLY 'd0;
            ram_waddr_max2 <=  #DLY 'd0;
        end
    end
end

endmodule