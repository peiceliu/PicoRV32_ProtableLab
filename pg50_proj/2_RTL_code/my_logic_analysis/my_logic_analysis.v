`timescale 1ns / 1ps

module my_logic_analysis #(
    parameter                       INPUT_WIDTH = 6             //  任意分频方式（每次递增INCREASE）的计数器最大位宽，越大则精度越高
)(  
    input                           clk                     ,
    input                           rst_n                   ,
    // input                           start                   ,
    input                           config_valid            ,
    input       [7:0]               config_in               ,
    input       [INPUT_WIDTH-1:0]   din                     ,                            //  逻辑分析输入数据
    output      [7:0]               dout                    ,
    output reg                      fifo_wen                ,
    input                           fifo_data_full          ,
    input                           fifo_data_alfull                                        //
);

reg                                 bps_start               ;
wire                                clk_bps                 ;
reg             [12:0]              bps_ctrl                ;   
reg                                 clk_bps_r               ;           
wire                                clk_posedge             ; 
wire                                clk_negedge             ;
reg             [7:0]               config_in_r             ;
reg             [7:0]               dout_r                  ;           
// reg             [3:0]               din_cnt                 ;
reg             [INPUT_WIDTH-1:0]   din_r                   ;


localparam DLY = 1;
//================================时钟沿产生==================================
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        clk_bps_r <= #DLY 'd0;
    end else begin
        clk_bps_r <= #DLY clk_bps;
    end
end

assign clk_posedge = clk_bps & ~clk_bps_r;
assign clk_negedge = ~clk_bps & clk_bps_r;

//=================================
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        config_in_r <= #DLY 'd0;
    end else begin
        if (config_valid) begin
            config_in_r <= #DLY config_in;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        bps_ctrl <= #DLY 'd0;
    end else begin
        case(config_in_r[6:4])
            3'd0: begin
                bps_ctrl <= #DLY 'd0;      
            end
            3'd1: begin
                bps_ctrl <= #DLY 13'd2603;      
            end
            3'd2: begin
                bps_ctrl <= #DLY 13'd1301;       
            end
            3'd3: begin
                bps_ctrl <= #DLY 13'd868;       //57600bps
            end
            3'd4: begin
                bps_ctrl <= #DLY 13'd521;       // 13'd5207,    //9600bps
            end
            3'd5: begin
                bps_ctrl <= #DLY 13'd260;      // 13'd2603,    //19200bps
            end
            3'd6: begin
                bps_ctrl <= #DLY 13'd130;       // 13'd1301,    //38400bps
            end
            3'd7: begin
                bps_ctrl <= #DLY 13'd87;       // 13'd868;     //57600bps
            end
            default: begin
                bps_ctrl <= #DLY 13'd521;
            end
        endcase
    end
end
//=====================================
// always @(posedge clk or negedge rst_n) begin
//     if(rst_n == 1'b0) begin
//         din_cnt <= #DLY 'd0;
//     end else begin
//         if (config_in_r[3] && clk_posedge && din_cnt == 'd3) begin
//             din_cnt <= #DLY 'd0;
//         end else if (config_in_r[3] && clk_posedge) begin
//             din_cnt <= #DLY din_cnt + 'd1;
//         end
//         if (~config_in_r[3] && clk_negedge && din_cnt == 'd3) begin
//             din_cnt <= #DLY 'd0;
//         end else if (~config_in_r[3] && clk_negedge) begin
//             din_cnt <= #DLY din_cnt + 'd1;
//         end
//     end
// end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        dout_r <= #DLY 'd0;
    end else begin
        if (config_in_r[3] && clk_posedge) begin
            dout_r <= #DLY {2'b0,din};
        end
        if (~config_in_r[3] && clk_negedge) begin
            dout_r <= #DLY {2'b0,din};
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
        end else if (config_in_r[3] && clk_posedge && ~fifo_data_full) begin
            fifo_wen <= #DLY 'd1;
        end else if (~config_in_r[3] && clk_negedge && ~fifo_data_full) begin
            fifo_wen <= #DLY 'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        bps_start <= 'd0;
    end else begin
        if (fifo_data_alfull || config_in_r == 'd0) begin  
            bps_start <= #DLY 'd0;
        end else if (config_in_r[0]) begin
            bps_start <= #DLY 'd1;
        end else if (din_r != din) begin
            bps_start <= #DLY 'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        din_r <= 'd0;
    end else begin
        din_r <= din;
    end
end


clk_div clk_div_1 (
	.clk            (clk            )   , 
	.rst_n          (rst_n          )   , 
	.bps_start      (bps_start      )   , 
    .uart_ctrl      (bps_ctrl       )   , //baudrates config.
	.clk_bps        (clk_bps        ) 
);
// 13'd5207,    //9600bps
// 13'd2603,    //19200bps
// 13'd1301,    //38400bps
// 13'd867,     //57600bps
// 13'd433;     //115200bps



endmodule