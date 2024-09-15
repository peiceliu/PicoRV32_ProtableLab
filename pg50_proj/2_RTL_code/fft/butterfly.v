module butterfly #(
    parameter                               DATA_WIDTH = 16
)(
    input                                   clk        ,//系统时钟
    input                                   rst_n       ,//系统异步复位，低电平有效
    input                                   en         ,//使能信号，表示输入数据有效
    input signed      [2*DATA_WIDTH-1:0]    xp_real    ,//Xm(p)
    input signed      [2*DATA_WIDTH-1:0]    xp_imag    ,
    input signed      [2*DATA_WIDTH-1:0]    xq_real    ,//Xm(q)
    input signed      [2*DATA_WIDTH-1:0]    xq_imag    ,
    input signed      [14:0]                factor_real,//扩大8192 倍（左移 13 位）后的旋转因子
    input signed      [14:0]                factor_imag,
    output                                  valid      ,//输出数据有效执行信号
    output signed     [2*DATA_WIDTH-1:0]    yp_real    ,//Xm+1(p)
    output signed     [2*DATA_WIDTH-1:0]    yp_imag    ,
    output signed     [2*DATA_WIDTH-1:0]    yq_real    ,//Xm+1(q)
    output signed     [2*DATA_WIDTH-1:0]    yq_imag    
);

    parameter           DLY = 1                 ;

    reg signed [2*DATA_WIDTH+14:0]          xq_wnr_real0  ;
    reg signed [2*DATA_WIDTH+14:0]          xq_wnr_real1  ;
    reg signed [2*DATA_WIDTH+14:0]          xq_wnr_imag0  ;
    reg signed [2*DATA_WIDTH+14:0]          xq_wnr_imag1  ;
    reg signed [2*DATA_WIDTH+14:0]          xp_real_r     ;
    reg signed [2*DATA_WIDTH+14:0]          xp_imag_r     ;
    reg signed [2*DATA_WIDTH+15:0]          yp_real_r     ;
    reg signed [2*DATA_WIDTH+15:0]          yp_imag_r     ;
    reg signed [2*DATA_WIDTH+15:0]          yq_real_r     ;
    reg signed [2*DATA_WIDTH+15:0]          yq_imag_r     ;
    reg                                     valid_r       ;
    reg                                     valid_n       ;


// always @(posedge clk or negedge rst_n) begin
//     if (~rst_n) begin
//         cnt <= #DLY #DLY 'd0;
//     end else begin
//         if (cnt != 'd0) begin
//             cnt <= #DLY #DLY cnt + 1;
//         end else if (en) begin
//             cnt <= #DLY #DLY 'd1;
//         end
//     end
// end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        xp_real_r    <= #DLY 'b0;
        xp_imag_r    <= #DLY 'b0;
        xq_wnr_real0 <= #DLY 'b0;
        xq_wnr_real1 <= #DLY 'b0;
        xq_wnr_imag0 <= #DLY 'b0;
        xq_wnr_imag1 <= #DLY 'b0;
    end else begin
        if (en == 'd1) begin
            xq_wnr_real0 <= #DLY xq_real * factor_real;
            xq_wnr_real1 <= #DLY xq_imag * factor_imag;
            xq_wnr_imag0 <= #DLY xq_real * factor_imag;
            xq_wnr_imag1 <= #DLY xq_imag * factor_real;
            xp_real_r <= #DLY xp_real << 13;
            xp_imag_r <= #DLY xp_imag << 13;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        yp_real_r <= #DLY 'b0;
        yp_imag_r <= #DLY 'b0;
        yq_real_r <= #DLY 'b0;
        yq_imag_r <= #DLY 'b0;
    end else begin
        if (valid_n == 'd1) begin
            yp_real_r <= #DLY xp_real_r + (xq_wnr_real0 - xq_wnr_real1);
            yp_imag_r <= #DLY xp_imag_r + (xq_wnr_imag0 + xq_wnr_imag1);
            yq_real_r <= #DLY xp_real_r - (xq_wnr_real0 - xq_wnr_real1);
            yq_imag_r <= #DLY xp_imag_r - (xq_wnr_imag0 + xq_wnr_imag1);
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_r <= #DLY 'd0;
        valid_n <= #DLY 'd0;
    end else begin 
        if (en) begin
            valid_n <= #DLY 'd1;
        end else begin
            valid_n <= #DLY 'd0;
        end
        if (valid_n) begin
            valid_r <= #DLY 'd1;
        end else begin
            valid_r <= #DLY 'd0;
        end
    end
end


assign yp_real = {yp_real_r[47], yp_real_r[44:13]};
assign yp_imag = {yp_imag_r[47], yp_imag_r[44:13]};
assign yq_real = {yq_real_r[47], yq_real_r[44:13]};
assign yq_imag = {yq_imag_r[47], yq_imag_r[44:13]};
assign valid = valid_r;
endmodule