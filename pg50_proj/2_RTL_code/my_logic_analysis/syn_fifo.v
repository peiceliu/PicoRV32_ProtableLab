// ========================================================================================================== //
//                               Copyright 2022 Deepcreatic Technologies Co.Ltd                               //
//                                            All rights reserved                                             //
// ---------------------------------------------------------------------------------------------------------- //
// Module Full Name: SYN_FIFO
// File Name: syn_fifo.v
// Author: wycong  @author: wycong0416@gmail.com
// Create Date: 2022.11.04
// version: 0.1
// Function Description: synchronous fifo
// Modified By: 
// Modified Date: 
// Description: 
// ========================================================================================================== //

`timescale 1ns / 1ps

module SYN_FIFO(
clk                   ,
rst_n                 ,
wen                   ,
ren                   ,
level                 ,
din                   ,
dout                  ,
alfull                ,
empty                 ,
full                   
);
parameter      DLY           =   1            ;
parameter      ADDR_WIDTH    =   12            ;
parameter      DATA_WIDTH    =   8           ;

input                       clk               ;
input                       rst_n             ;
input                       wen               ;
input                       ren               ;
input   [ADDR_WIDTH:0]      level             ; //the space be occupied.   
input   [DATA_WIDTH-1:0]    din               ;
output  [DATA_WIDTH-1:0]    dout              ;
output                      alfull            ;
output                      empty             ;
output                      full              ;

reg     [ADDR_WIDTH:0]      waddr             ;
reg     [ADDR_WIDTH:0]      raddr             ;

wire                        alfull            ;
wire                        empty             ;
wire                        full              ;
wire    [DATA_WIDTH-1:0]    dout              ;


always @(negedge rst_n or posedge clk) begin
    if(rst_n == 1'b0) begin
        waddr <= 'h0;
    end
    else begin
        if(wen == 1'b1 && full == 1'b0) begin
            waddr <= #DLY waddr + 1'b1;
        end
    end
end

always @(negedge rst_n or posedge clk) begin
    if(rst_n == 1'b0) begin
        raddr <= 'h0;
    end
    else begin
        if(ren == 1'b1) begin
            raddr <= #DLY raddr + 1'b1;
        end
    end
end

assign alfull = (waddr - raddr) >= level  ;
assign empty  = raddr == waddr            ;
assign full = (waddr[ADDR_WIDTH] != raddr[ADDR_WIDTH]) & (waddr[ADDR_WIDTH-1:0] == raddr[ADDR_WIDTH-1:0]); 

DPRAM_WRAP U_DPRAM_WRAP(
.wclk      (clk                        ),
.rclk      (clk                        ),
.waddr     (waddr[ADDR_WIDTH-1:0]      ),
.raddr     (raddr[ADDR_WIDTH-1:0]      ),
.din       (din                        ),
.wen       (wen & ~full                ),
.ren       (ren                        ),
.dout      (dout                       ) 
);


endmodule
