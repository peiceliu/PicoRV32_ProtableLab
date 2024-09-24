// ========================================================================================================== //
//                               Copyright 2022 Deepcreatic Technologies Co.Ltd                               //
//                                            All rights reserved                                             //
// ---------------------------------------------------------------------------------------------------------- //
// Module Full Name: DPRAM_WRAP
// File Name: dpram_wrap.v
// Author: wycong  @author: wycong0416@gmail.com
// Create Date: 2022.11.04
// version: 0.1
// Function Description: dual port sram wrapper
// Modified By: 
// Modified Date: 
// Description: 
// ========================================================================================================== //

module DPRAM_WRAP #(
    parameter        ADDR_WIDTH = 12                ,
    parameter        DATA_WIDTH = 8                 
)
(
wclk               ,
rclk               ,
waddr              ,
raddr              ,
din                ,
wen                ,
ren                ,
dout                
);
parameter        DLY        = 1                  ;
parameter        MEM_DEPTH  = 2 ** ADDR_WIDTH    ;

input                                    wclk    ;
input                                    rclk    ;
input            [ADDR_WIDTH - 1:0]      waddr   ;  //[4:0]
input            [ADDR_WIDTH - 1:0]      raddr   ;
input            [DATA_WIDTH - 1:0]      din     ;  //[31:0]
input                                    wen     ;
input                                    ren     ;
output           [DATA_WIDTH - 1:0]      dout    ;

reg   [DATA_WIDTH - 1:0]   mem   [0:MEM_DEPTH-1] ;            
reg              [DATA_WIDTH - 1:0]      dout    ;


always @(posedge wclk) begin
    if(wen == 1'b1) begin
        mem[waddr] <= #DLY din ;       
    end
end

always @(posedge rclk) begin
    if(ren == 1'b1) begin
        dout <= #DLY mem[raddr];
    end
end

endmodule


