
`timescale 1ns / 1ps
module fft #(
    parameter                           DATA_WIDTH      = 16    ,
    parameter                           ADDR_WIDTH      = 8     ,
    parameter                           MUTI            =1
)
(
    input                               clk                     ,
    input                               rst_n                   ,
    input           [2*MUTI*DATA_WIDTH-1:0]  ram_in                  ,
    input                               start                   ,
    output  signed  [2*MUTI*DATA_WIDTH-1:0]  ram_out                 ,
    output                              ram_wen                 ,
    output                              ram_ren                 ,
    output          [ADDR_WIDTH-1:0]    ram_waddr               ,
    output          [ADDR_WIDTH-1:0]    ram_raddr               ,
    output reg      [15:0]              loop_cnt                ,
    output reg                          fft_done                    //
);

    reg                                 fft_en                  ;
    // reg signed  [15:0]  xp_real                     ;
    // reg signed  [15:0]  xp_imag                     ;
    // reg signed  [15:0]  xq_real                     ;
    // reg signed  [15:0]  xq_imag                     ;
    wire signed [MUTI*DATA_WIDTH-1:0]      yp_real                 ;
    wire signed [MUTI*DATA_WIDTH-1:0]      yp_imag                 ;
    wire signed [MUTI*DATA_WIDTH-1:0]      yq_real                 ;
    wire signed [MUTI*DATA_WIDTH-1:0]      yq_imag                 ;
    reg         [15:0]                  fft_cnt                 ;
    reg         [2*MUTI*DATA_WIDTH-1:0]      ram_in_r                ;
    reg         [2*MUTI*DATA_WIDTH-1:0]      ram_out_p               ;
    reg                                 ram_wen_r               ;
    reg                                 ram_ren_r               ;
    reg         [15:0]                  ram_waddr_r             ;
    reg         [15:0]                  ram_raddr_r             ;
    reg         [15:0]                  ram_raddr_r1            ;
    reg         [15:0]                  ram_raddr_r2            ;
    reg         [15:0]                  ram_raddr_r3            ;
    wire                                fft_valid               ;
    reg                                 fft_cnt_b               ;
    reg         [ADDR_WIDTH-1:0]        factor_addr             ;


    wire signed [14:0]                  factor_real             ;
    wire signed [14:0]                  factor_imag             ;
                
    wire signed [14:0]                  factor_real_rom         ;
    wire signed [14:0]                  factor_imag_rom         ;
    parameter                           DLY = 1                 ;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        fft_cnt <= #DLY 'd0;
    end else begin
        if (fft_done) begin
            fft_cnt <= #DLY 'd0;
        end else if (fft_cnt == 'd128 && fft_cnt_b) begin
            fft_cnt <= #DLY 'd1;
        end else if (fft_cnt_b) begin
            fft_cnt <= #DLY fft_cnt + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        fft_cnt_b <= #DLY 'd0;
    end else begin
        if (fft_done) begin
            fft_cnt_b <= 'b0;
        end else if (ram_ren_r) begin
            fft_cnt_b <= #DLY ~fft_cnt_b;
        end else if (start) begin
            fft_cnt_b <= #DLY 'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        loop_cnt <= #DLY 'd0;
    end else begin
        if (ram_wen_r == 'd0) begin
            loop_cnt <= #DLY 'd0;
        end else if (fft_cnt == 'd128 && ~fft_cnt_b) begin
            loop_cnt <= #DLY (loop_cnt << 1) + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ram_ren_r <= #DLY 'd0;
    end else begin
        if (fft_cnt == 'd128 && ~fft_cnt_b && loop_cnt[6] == 'd1) begin
            ram_ren_r <= #DLY 'd0;
        end else if (start) begin
            ram_ren_r <= #DLY 'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ram_wen_r <= #DLY 'd0;
    end else begin
        if (fft_cnt == 'd3 && ~ram_ren_r) begin
            ram_wen_r <= #DLY 'd0;
        end else if (fft_cnt == 'd2 && ram_ren_r) begin
            ram_wen_r <= #DLY 'd1;
        end
    end
end

//--------------------------------addr--------------------------------
// genvar m , k;
// generate
//     always @(posedge clk or negedge rst_n) begin
//     if (~rst_n) begin
//         ram_raddr <= #DLY 'd0;
//         ram_waddr <= #DLY 'd0;
//     end else begin
//         for (m=0; m<=6; m=m+1) begin
//             for (k=0; k<=127; k=k+1) begin
//                 if (start || (fft_cnt[0] == 1'b0 && fft_cnt != 'd0)) begin
//                     ram_raddr <= #DLY {k[6:m] << 1,k[m:0]}
//                 end else if (fft_cnt[0] == 1'b1) begin
//                     ram_raddr <= #DLY {k[6:m] << 1,k[m:0]} + m;
//                 end
//                 if (fft_valid) begin
//                     ram_waddr <= #DLY {k[6:m] << 1,k[m:0]}
//                 end
//             end
//         end
//     end
// end

// endgenerate
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ram_raddr_r <= #DLY 'd0;
    end else begin
        if (fft_done) begin
            ram_raddr_r <= #DLY 'd0;
        end else if ((ram_ren_r && ~fft_cnt_b) || start) begin
            ram_raddr_r <= #DLY ((fft_cnt & (~loop_cnt)) << 1) + (fft_cnt & loop_cnt);
            // ram_raddr_r <= #DLY {fft_cnt[loop_cnt +:8] << 1,fft_cnt[loop_cnt -: 8]};
        end else if (ram_ren_r && fft_cnt_b) begin
            ram_raddr_r <= #DLY ((fft_cnt & (~loop_cnt)) << 1) + (fft_cnt & loop_cnt) + (loop_cnt + 1);
            // ram_raddr_r <= #DLY {fft_cnt[loop_cnt +:8] << 1,fft_cnt[loop_cnt -: 8]} + (1 << loop_cnt);
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ram_raddr_r1 <= #DLY 'd0;
        ram_raddr_r2 <= #DLY 'd0;
        ram_raddr_r3 <= #DLY 'd0;
    end else begin
        if (fft_done) begin
            ram_raddr_r1 <= #DLY 'd0;
            ram_raddr_r2 <= #DLY 'd0;
            ram_raddr_r3 <= #DLY 'd0;
        end else begin
            ram_raddr_r1 <= #DLY ram_raddr_r;
            ram_raddr_r2 <= #DLY ram_raddr_r1;
            ram_raddr_r3 <= #DLY ram_raddr_r2;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ram_waddr_r <= #DLY 'd0;
    end else begin
        if (fft_done) begin
            ram_waddr_r <= #DLY 'd0;
        end else begin
            ram_waddr_r <= #DLY ram_raddr_r3;
        end
    end
end

butterfly #(
    .DATA_WIDTH         (DATA_WIDTH                                 ),
    .MUTI               (MUTI                                       )
) butterfly1 (
    .clk                (clk                                        ),//系统时钟
    .rst_n              (rst_n                                      ),//系统异步复位，低电平有效
    .en                 (fft_en                                     ),//使能信号，表示输入数据有效
    .xp_real            (ram_in_r[MUTI*DATA_WIDTH-1:0]                 ),//Xm(p)
    .xp_imag            (ram_in_r[2*MUTI*DATA_WIDTH-1:MUTI*DATA_WIDTH]      ),
    .xq_real            (ram_in[MUTI*DATA_WIDTH-1:0]                   ),//Xm(q)
    .xq_imag            (ram_in[2*MUTI*DATA_WIDTH-1:MUTI*DATA_WIDTH]        ),
    .factor_real        (factor_real                                ),//扩大8192 倍（左移 13 位）后的旋转因子
    .factor_imag        (factor_imag                                ),
    .valid              (fft_valid                                  ),//输出数据有效执行信号
    .yp_real            (yp_real                                    ),//Xm+1(p)
    .yp_imag            (yp_imag                                    ),
    .yq_real            (yq_real                                    ),//Xm+1(q)
    .yq_imag            (yq_imag                                    )
);  

factor_rom factor_rom1 (    
    .clk                (clk                                        ),
    .rst_n              (rst_n                                      ),
    .factor_addr        ({2'b00,factor_addr[5:0]}                   ),
    .factor_en          (ram_ren_r                                  ),
    .factor_real        (factor_real_rom                            ),
    .factor_imag        (factor_imag_rom                            )//
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        fft_en <= #DLY 'd0;
    end else begin
        if (ram_ren_r && ~fft_cnt_b) begin
            fft_en <= #DLY 'd1;
        end else if (fft_cnt_b) begin
            fft_en <= #DLY 'd0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ram_in_r <= #DLY 'd0;
    end else begin
        if (~fft_cnt_b && ram_ren_r) begin
            ram_in_r <= #DLY ram_in;
        end else if (~ram_ren_r) begin
            ram_in_r <= #DLY 'd0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        factor_addr <= #DLY 'd0;
    end else begin
        if (ram_ren_r && fft_cnt_b) begin
            case(loop_cnt)
            'b000_0000: begin factor_addr <= #DLY (fft_cnt[7:0]) << 7; end
            'b000_0001: begin factor_addr <= #DLY (fft_cnt[7:0]) << 6; end
            'b000_0011: begin factor_addr <= #DLY (fft_cnt[7:0]) << 5; end
            'b000_0111: begin factor_addr <= #DLY (fft_cnt[7:0]) << 4; end
            'b000_1111: begin factor_addr <= #DLY (fft_cnt[7:0]) << 3; end
            'b001_1111: begin factor_addr <= #DLY (fft_cnt[7:0]) << 2; end
            'b011_1111: begin factor_addr <= #DLY (fft_cnt[7:0]) << 1; end
            'b111_1111: begin factor_addr <= #DLY (fft_cnt[7:0]) << 0; end
            endcase 
        end else if (~ram_ren_r) begin
            factor_addr <= #DLY 'd0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        fft_done <= #DLY 'b0;
    end else begin
        if (fft_cnt == 'd4 && fft_cnt_b && ~ram_ren_r) begin
            fft_done <= #DLY 'b1;
        end else if (fft_done) begin
            fft_done <= #DLY 'b0;
        end
    end
end

assign factor_real = (factor_addr[6])? (-factor_imag_rom): factor_real_rom;
assign factor_imag = (factor_addr[6])? factor_real_rom: factor_imag_rom;
assign ram_out[MUTI*DATA_WIDTH-1:0] = (fft_valid)? yp_real : yq_real;
assign ram_out[2*MUTI*DATA_WIDTH-1:MUTI*DATA_WIDTH] = (fft_valid)? yp_imag : yq_imag;
assign ram_waddr = ram_waddr_r[ADDR_WIDTH-1:0];
assign ram_raddr = ram_raddr_r[ADDR_WIDTH-1:0];
assign ram_wen = ram_wen_r;
assign ram_ren = ram_ren_r;

endmodule