
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
    input      signed   [INOUT_DATA_WIDTH-1:0]                  data_in                 ,
    output                                                      ram_wen                 ,
    output                                                      ram_ren                 ,
    output              [RAM_ADDR_WIDTH-1:0]                    ram_waddr               ,
    output reg          [RAM_ADDR_WIDTH-1:0]                    ram_raddr               ,
    output reg signed   [INOUT_DATA_WIDTH-1:0]                  data_out                ,   
    input                                                       start                   ,
    output                                                      fft_done                ,
    output reg          [RAM_ADDR_WIDTH-1:0]                    ram_waddr_max1          ,
    output reg          [RAM_ADDR_WIDTH-1:0]                    ram_waddr_max2          
);

reg  signed             [2*MUTI*RAM_DATA_WIDTH-1:0]             ram_in                  ;
wire signed             [2*MUTI*RAM_DATA_WIDTH-1:0]             ram_out                 ;
wire                                                            ram_wen_f               ;
wire                                                            ram_ren_f               ;
wire                    [RAM_ADDR_WIDTH-1:0]                    ram_waddr_f             ;
wire                    [RAM_ADDR_WIDTH-1:0]                    ram_raddr_f             ;
wire                    [15:0]                                  loop_cnt                ;
wire                    [2*MUTI*RAM_DATA_WIDTH-1:0]             ram_in_fr               ;
wire                    [2*MUTI*RAM_DATA_WIDTH-1:0]             ram_out_fr              ;
wire                                                            ram_wen_fr              ;
wire                                                            ram_ren_fr              ;
wire                    [RAM_ADDR_WIDTH-1:0]                    ram_waddr_fr            ;
wire                    [RAM_ADDR_WIDTH-1:0]                    ram_raddr_fr            ;
wire                                                            fft_valid               ;
reg                     [15:0]                                  loop_cnt_r              ;
wire signed             [MUTI*RAM_DATA_WIDTH-1:0]               ram_out_real            ;
wire signed             [MUTI*RAM_DATA_WIDTH-1:0]               ram_out_imag            ;
reg                     [INOUT_DATA_WIDTH-1:0]                  data_out_max1           ;
reg                     [INOUT_DATA_WIDTH-1:0]                  data_out_max2           ;

parameter                                                       DLY = 1                 ;

//=============== 实数虚数分别取绝对值 ====================
assign ram_out_real = (ram_out[MUTI*RAM_DATA_WIDTH-1])? (~ram_out[MUTI*RAM_DATA_WIDTH-1:0]+1) : ram_out[MUTI*RAM_DATA_WIDTH-1:0];
assign ram_out_imag = (ram_out[2*MUTI*RAM_DATA_WIDTH-1])? (~ram_out[2*MUTI*RAM_DATA_WIDTH-1:MUTI*RAM_DATA_WIDTH]+1) : ram_out[2*MUTI*RAM_DATA_WIDTH-1:MUTI*RAM_DATA_WIDTH];


//=============== 复数取绝对值 输出 ==========================
always @(*) begin
    data_out = 'd0;
    ram_in = 'd0;
    if (loop_cnt_r == 'd0) begin
        ram_in[MUTI*RAM_DATA_WIDTH-1:0] = data_in;
        ram_in[2*MUTI*RAM_DATA_WIDTH-1:MUTI*RAM_DATA_WIDTH] = 'd0;
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
    .start          (start          )               ,
    .ram_out        (ram_out        )               ,
    .ram_wen        (ram_wen_f      )               ,
    .ram_ren        (ram_ren_f      )               ,
    .ram_waddr      (ram_waddr_f    )               ,
    .ram_raddr      (ram_raddr_f    )               ,
    .loop_cnt       (loop_cnt       )               ,
    .fft_done       (fft_done       )               
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


//================ 主频副频抓取 ===========================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        data_out_max1 <=  #DLY 'd0;
        data_out_max2 <=  #DLY 'd0;
        ram_waddr_max1 <=  #DLY 'd0;
        ram_waddr_max2 <=  #DLY 'd0;
    end else begin
        if (data_out > data_out_max1 && ram_wen) begin
            data_out_max2 <= #DLY data_out_max1;
            ram_waddr_max2 <= #DLY ram_waddr_max1;
            data_out_max1 <= #DLY data_out;
            ram_waddr_max1 <= #DLY ram_waddr;
        end else if (data_out > data_out_max2 && data_out < data_out_max1 && ram_wen) begin
            data_out_max2 <= #DLY data_out;
            ram_waddr_max2 <= #DLY ram_waddr;
        end else if (start) begin
            data_out_max1 <=  #DLY 'd0;
            data_out_max2 <=  #DLY 'd0;
            ram_waddr_max1 <=  #DLY 'd0;
            ram_waddr_max2 <=  #DLY 'd0;
        end
    end
end

endmodule