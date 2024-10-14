// `timescale 1ns / 1ps

module my_logic_analysis #(
    parameter                       INPUT_WIDTH     =   6   ,
    parameter                       CONFIG_WIDTH    =   32    //  

)(  
    input                           clk                     ,
    input                           rst_n                   ,
    // input                           start                   ,
    input       [CONFIG_WIDTH-1:0]  config_in_r             ,
    input       [31:0]              time_need               ,
    input       [1:0]               triger_type             , 
    input                           start                   , 
    input                           touch_start             , 
    input       [INPUT_WIDTH-1:0]   din                     ,                            //  逻辑分析输入数据
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
reg             [31:0]              time_need_cnt           ;
reg             [INPUT_WIDTH-1:0]   din_r0                  ;
reg             [INPUT_WIDTH-1:0]   din_r1                  ;
reg             [INPUT_WIDTH-1:0]   din_r2                  ;
reg                                 triger                  ;
reg                                 triger_r                ;


localparam DLY = 0;
localparam HV = 1;
localparam LV = 2;
localparam PE = 3;
localparam NE = 4;

integer i;



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
        end else if (time_need_cnt + 1 == time_need) begin
            triger_r <= 'd0;
        end
    end
end


always @(*) begin
    triger <= 'd0;
    if (clk_bps) begin                //TODO posedge or negedge
        for (i=0 ; i < INPUT_WIDTH ; i=i+1) begin
            case (triger_type[1:0])
                HV: begin                     //高电平触发
                    if (din_r2[i] && din_r1[i]) begin
                        triger <= 'd1;
                    end
                end
                LV: begin
                    if (~din_r2[i] && ~din_r1[i]) begin
                        triger <= 'd1;
                    end
                end
                PE: begin
                    if (~din_r2[i] && din_r1[i]) begin
                        triger <= 'd1;
                    end
                end
                NE: begin
                    if (din_r2[i] && ~din_r1[i]) begin
                        triger <= 'd1;
                    end
                end
            endcase
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        time_need_cnt <= 'd0;
    end else begin
        if (time_need_cnt + 1 == time_need) begin
            time_need_cnt <= 'd0;
        end else if (triger || triger_r) begin
            time_need_cnt <= time_need_cnt + 'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        din_cnt <= #DLY 'd7;
    end else begin
        if (clk_bps && din_cnt == 'd0) begin
            din_cnt <= #DLY 'd7;
        end else if (clk_bps) begin
            din_cnt <= #DLY din_cnt - 'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        dout_r <= #DLY 'd0;
    end else begin
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
            fifo_wen <= #DLY 'd1;
        end else if (dout_done) begin
            fifo_wen <= #DLY 'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin     
        dout_done <= 'd0;
    end else begin
        if (time_need_cnt + 1 == time_need) begin
            dout_done <= 'd1;
        end else if (dout_done) begin
            dout_done <= 'd0;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        bps_start <= 'd0;
    end else begin
        if (time_need_cnt + 1 == time_need) begin  
            bps_start <= #DLY 'd0;
        end else if (start && touch_start) begin
            bps_start <= #DLY 'd1;
        end
    end
end

clk_div clk_div_1 (
	.clk            (clk            )   , 
	.rst_n          (rst_n          )   , 
	.bps_start      (bps_start      )   , 
    .uart_ctrl      (config_in_r    )   , //baudrates config.
	.clk_bps        (clk_bps        ) 
);
//50Mhz : 0
//25Mhz : 1
//12.5Mhz : 3
//5Mhz  : 9

endmodule