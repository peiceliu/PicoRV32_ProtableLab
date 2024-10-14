// ========================================================================================================== //
//                               Copyright 2022 Deepcreatic Technologies Co.Ltd                               //
//                                            All rights reserved                                             //
// ---------------------------------------------------------------------------------------------------------- //
// Module Full Name: ASYN_FIFO
// File Name: asyn_fifo.v
// Author: wycong  @author: wycong0416@gmail.com
// Create Date: 2022.11.04
// version: 0.1
// Function Description: asynchronous fifo
// Modified By: 
// Modified Date: 
// Description: 
// ========================================================================================================== //

module ASYN_FIFO(
wclk                  ,
rclk                  ,
w_rst_n               ,
r_rst_n               ,
wen                   ,
ren                   ,
level                 ,
din                   ,
dout                  ,
alfull                ,
empty                  
);
parameter      DLY           =   0            ;
parameter      ADDR_WIDTH    =   5            ;
parameter      DATA_WIDTH    =   32           ;

input                       wclk              ;
input                       rclk              ;
input                       w_rst_n           ;
input                       r_rst_n           ;
input                       wen               ;
input                       ren               ;
input   [ADDR_WIDTH:0]      level             ; //the space be occupied.   
input   [DATA_WIDTH-1:0]    din               ;
output  [DATA_WIDTH-1:0]    dout              ;
output                      alfull            ;
output                      empty             ;

reg     [ADDR_WIDTH:0]      waddr             ;
reg     [ADDR_WIDTH:0]      raddr             ;
wire    [ADDR_WIDTH:0]      w_waddr_gray      ;
wire    [ADDR_WIDTH:0]      r_raddr_gray      ;
reg     [ADDR_WIDTH:0]      r_waddr_d1        ; 
reg     [ADDR_WIDTH:0]      r_waddr_gray      ; 
reg     [ADDR_WIDTH:0]      w_raddr_d1        ; 
reg     [ADDR_WIDTH:0]      w_raddr_gray      ; 
wire    [ADDR_WIDTH:0]      w_raddr_bin_tmp   ;
wire    [ADDR_WIDTH:0]      r_waddr_bin_tmp   ;
wire    [ADDR_WIDTH:0]      w_raddr_bin       ;
wire    [ADDR_WIDTH:0]      r_waddr_bin       ;
wire                        alfull            ;
wire                        empty             ;
wire    [DATA_WIDTH-1:0]    dout              ;


always @(negedge w_rst_n or posedge wclk) begin
    if(w_rst_n == 1'b0) begin
        waddr <= 'h0;
    end
    else begin
        if(wen == 1'b1) begin
            waddr <= #DLY waddr + 1'b1;
        end
    end
end

always @(negedge r_rst_n or posedge rclk) begin
    if(r_rst_n == 1'b0) begin
        raddr <= 'h0;
    end
    else begin
        if(ren == 1'b1) begin
            raddr <= #DLY raddr + 1'b1;
        end
    end
end

//transform the binary code to gray code.
assign w_waddr_gray = waddr ^ (waddr >> 1);
assign r_raddr_gray = raddr ^ (raddr >> 1);

//delay the gray code for 2 cycles.
always @(negedge r_rst_n or posedge rclk) begin
    if(r_rst_n == 1'b0) begin
        r_waddr_d1   <= 'h0;
        r_waddr_gray <= 'h0;
    end
    else begin
        r_waddr_d1   <= #DLY w_waddr_gray;
        r_waddr_gray <= #DLY r_waddr_d1  ;
    end
end

always @(negedge w_rst_n or posedge wclk) begin
    if(w_rst_n == 1'b0) begin
        w_raddr_d1   <= 'h0;
        w_raddr_gray <= 'h0;
    end
    else begin
        w_raddr_d1   <= #DLY r_raddr_gray;
        w_raddr_gray <= #DLY w_raddr_d1  ;
    end
end

genvar i;
for (i=0;i<ADDR_WIDTH;i=i+1) begin
  assign w_raddr_bin_tmp[i] = w_raddr_bin[i+1] ^ w_raddr_gray[i];
  assign r_waddr_bin_tmp[i] = r_waddr_bin[i+1] ^ r_waddr_gray[i];
end

assign w_raddr_bin = {w_raddr_gray[ADDR_WIDTH],w_raddr_bin_tmp[ADDR_WIDTH-1:0]};        //r地址打两拍
assign r_waddr_bin = {r_waddr_gray[ADDR_WIDTH],r_waddr_bin_tmp[ADDR_WIDTH-1:0]};        //w地址打两拍

assign alfull = (waddr - w_raddr_bin) >= level  ;
assign empty  = (r_waddr_bin - raddr) <= level   ;

DPRAM_WRAP U_DPRAM_WRAP(
.wclk      (wclk                     ),
.rclk      (rclk                     ),
.waddr     (waddr[ADDR_WIDTH-1:0]    ),
.raddr     (raddr[ADDR_WIDTH-1:0]    ),
.din       (din                      ),
.wen       (wen                      ),
.ren       (ren                      ),
.dout      (dout                     ) 
);


endmodule
