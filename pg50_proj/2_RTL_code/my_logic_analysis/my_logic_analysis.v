// `timescale 1ns / 1ps
// `timescale 1ns / 1ps

module my_logic_analysis #(
    parameter                       INPUT_WIDTH     =   6   

)(  
    input                           clk                     ,
    input                           rst_n                   ,
    // input                           start                   ,
    input       [3:0]               sample_clk_cfg          ,
    input       [31:0]              sample_num              ,
    input       [1:0]               triger_type             , 
    input                           sample_run              , 
    input                           ethernet_read_done      ,
    input       [2:0]               trigger_channel         ,
    input       [INPUT_WIDTH-1:0]   din                     ,                            //  逻辑分析输入数据
    output reg                      dout_done               ,
    output      [63:0]              dout                    ,
    output reg                      dout_done               ,
    output      [63:0]              dout                    ,
    output reg                      fifo_wen                ,
    input                           fifo_data_full          ,
    input                           fifo_data_alfull                                        //
);

reg                                 bps_start               ;
wire                                clk_bps                 ;
// reg             [12:0]              bps_ctrl                ;   
// reg                                 clk_bps_r               ;           
// wire                                clk_posedge             ; 
// wire                                clk_negedge             ;
reg             [63:0]              dout_r                  ;           
reg             [7:0]               din_cnt                 ;
reg             [31:0]              sample_num_cnt          ;
reg             [INPUT_WIDTH-1:0]   din_r0                  ;
reg             [INPUT_WIDTH-1:0]   din_r1                  ;
reg             [INPUT_WIDTH-1:0]   din_r2                  ;
reg                                 triger                  ;
reg                                 triger_r                ;
reg                                 start_r0                ;
reg                                 start_r1                ;
reg                                 start_r2                ;
reg                                 start_posedge           ;

localparam DLY = 0;
localparam HV = 0;
localparam LV = 1;
localparam PE = 2;
localparam NE = 3;

integer i;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        start_r0 <= 'd0;
        start_r1 <= 'd0;
        start_r2 <= 'd0;
    end else begin
        start_r0 <= sample_run;
        start_r1 <= start_r0;
        start_r2 <= start_r1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        start_posedge <= 'd0;
    end else begin
        if (~start_r2 && start_r1) begin
            start_posedge <= 'd1;
        end else if (start_posedge) begin
            start_posedge <= 'd0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        din_r0 <= #1 {INPUT_WIDTH{1'b0}};
        din_r1 <= #1 {INPUT_WIDTH{1'b0}};
        din_r2 <= #1 {INPUT_WIDTH{1'b0}};
    end else begin
        din_r0 <= #1 din;
        din_r1 <= #1 din_r0;
        din_r2 <= #1 din_r1;
    end
end
//================================时钟沿产生==================================
// always @(posedge clk or negedge rst_n) begin
//     if(rst_n == 1'b0) begin
//         clk_bps_r <= #DLY 'd0;
//     end else begin
//         clk_bps_r <= #DLY clk_bps;
//     end
// end

// assign clk_posedge = clk_bps & ~clk_bps_r;
// assign clk_negedge = ~clk_bps & clk_bps_r;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        triger_r <= 'd0;
    end else begin
        if (triger) begin
            triger_r <= 'd1;
        end else if (sample_num_cnt + 1 == sample_num) begin
            triger_r <= 'd0;
        end
    end
end


always @(*) begin
    triger <= 'd0;
    if (clk_bps) begin         
        case (triger_type[1:0])
            HV: begin                     //高电平触发
                if (din_r2[trigger_channel] && din_r1[trigger_channel]) begin
                    triger <= 'd1;
                end
            end
            LV: begin                   //低电平触发
                if (~din_r2[trigger_channel] && ~din_r1[trigger_channel]) begin
                    triger <= 'd1;
                end
            end
            PE: begin
                if (~din_r2[trigger_channel] && din_r1[trigger_channel]) begin
                    triger <= 'd1;
                end
            end
            NE: begin
                if (din_r2[trigger_channel] && ~din_r1[trigger_channel]) begin
                    triger <= 'd1;
                end
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        sample_num_cnt <= 'd0;
    end else begin
        if (sample_num_cnt + 1 == sample_num) begin
            sample_num_cnt <= 'd0;
        end else if ((triger || triger_r) && clk_bps) begin
            sample_num_cnt <= sample_num_cnt + 'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        din_cnt <= #DLY 'd7;
    end else begin
        if (clk_bps && din_cnt == 'd7) begin
            din_cnt <= #DLY 'd0;
        end else if (clk_bps) begin
            din_cnt <= #DLY din_cnt + 'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        dout_r <= #DLY 'd0;
    end else begin
        if (clk_bps && (triger || triger_r)) begin
            dout_r[din_cnt*8+:8] <= #DLY {2'b0,din_r2};
        if (clk_bps && (triger || triger_r)) begin
            dout_r[din_cnt*8+:8] <= #DLY {2'b0,din_r2};
        end
    end
end
assign dout = dout_r;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        fifo_wen <= #DLY 'd0;
    end else begin
        if (fifo_wen) begin
            fifo_wen <= #DLY 'd0;
        end else if (clk_bps && ~fifo_data_full && din_cnt == 'd0) begin
        end else if (clk_bps && ~fifo_data_full && din_cnt == 'd0) begin
            fifo_wen <= #DLY 'd1;
        end else if (dout_done) begin
        end else if (dout_done) begin
            fifo_wen <= #DLY 'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin     
        dout_done <= 'd0;
    if(rst_n == 1'b0) begin     
        dout_done <= 'd0;
    end else begin
        if (sample_num_cnt + 1 == sample_num) begin
            dout_done <= 'd1;
        end else if (dout_done) begin
            dout_done <= 'd0;
        end
    end
end



always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        bps_start <= 'd0;
        bps_start <= 'd0;
    end else begin
        if (sample_num_cnt + 1 == sample_num) begin  
            bps_start <= #DLY 'd0;
        end else if (start_posedge && ethernet_read_done) begin   //TODO 数据传输完成信号
            bps_start <= #DLY 'd1;
        end
    end
end

clk_div clk_div_1 (
	.clk            (clk            )   , 
	.rst_n          (rst_n          )   , 
	.bps_start      (bps_start      )   , 
    .sample_clk_cfg (sample_clk_cfg )   , 
	.clk_bps        (clk_bps        ) 
);
//50Mhz : 0
//25Mhz : 1
//12.5Mhz : 3
//5Mhz  : 9
//50Mhz : 0
//25Mhz : 1
//12.5Mhz : 3
//5Mhz  : 9

endmodule