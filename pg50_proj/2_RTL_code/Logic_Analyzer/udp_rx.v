`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/16 23:11:05
// Design Name: 
// Module Name: udp_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module udp_rx #(
    parameter              LOCAL_PORT= 16'hF000
)(
    input                  clk,   
    input                  rstn,  
    
    input      [7:0]       udp_rx_data,
    input                  udp_rx_req,
    
    input                  ip_checksum_error,
    input                  ip_addr_check_error,
    
    output reg [7:0]       udp_rec_rdata ,      //udp ram read data
    output reg [15:0]      udp_rec_data_length,     //udp data length
    output reg             udp_rec_data_valid       //udp data valid
);

    reg  [15:0]             udp_rx_cnt ;
    reg  [15:0]             udp_data_length ;
    reg  [15:0]             udp_dest_port;

    localparam IDLE             =  8'b0000_0001  ;
    localparam REC_HEAD         =  8'b0000_0010  ;
    localparam REC_DATA         =  8'b0000_0100  ;
    localparam REC_ODD_DATA     =  8'b0000_1000  ;
    localparam VERIFY_CHECKSUM  =  8'b0001_0000  ;
    localparam REC_ERROR        =  8'b0010_0000  ;
    localparam REC_END_WAIT     =  8'b0100_0000  ;
    localparam REC_END          =  8'b1000_0000  ;
    
    reg [7:0]     state      ;
    reg [7:0]     state_n ;
    
    always @(posedge clk)
    begin
      if (~rstn)
        state <= IDLE ;
      else 
        state <= state_n ;
    end
    
    always @(*)
    begin
        case(state)
         IDLE            :
         begin
             if (udp_rx_req == 1'b1)
                 state_n = REC_HEAD ;
             else
                 state_n = IDLE ;
         end
         REC_HEAD       :
         begin
             if (ip_checksum_error | ip_addr_check_error)
                 state_n = REC_ERROR ;
             else if (udp_rx_cnt == 16'd7)
             begin
                 if(udp_dest_port == LOCAL_PORT)
                     state_n = REC_DATA ;
                 else
                     state_n = REC_ERROR ;
             end
             else
                 state_n = REC_HEAD ;
         end
         REC_DATA       :
         begin
             if (udp_rx_cnt == udp_data_length - 1)
                 state_n = REC_END ;
             else
                 state_n = REC_DATA ;
         end
         REC_ERROR      : state_n = IDLE  ; 
         REC_END        : state_n = IDLE  ;
         default        : state_n = IDLE  ;
         endcase
    end

    always @(posedge clk)
    begin
        if (~rstn)
            udp_dest_port <= 16'd0 ;
        else if (state == REC_HEAD && udp_rx_cnt > 16'd1 && udp_rx_cnt < 16'd4)
            udp_dest_port <= {udp_dest_port[7:0],udp_rx_data};
    end

    //udp data length 
    always @(posedge clk)
    begin
        if (~rstn)
            udp_data_length <= 16'd0 ;
        else if (state == REC_HEAD && udp_rx_cnt > 16'd3 && udp_rx_cnt < 16'd6)
            udp_data_length <= {udp_data_length[7:0],udp_rx_data};
    end
    
    always @(posedge clk)
    begin
        if (~rstn)
            udp_rec_data_length <= 16'd0 ;
        else if (state == REC_END)
            udp_rec_data_length <= udp_data_length - 16'd8;
    end
    
    always @(posedge clk)
    begin
        if (~rstn)
            udp_rx_cnt <= 16'd0 ;
        else if (state == REC_HEAD || state == REC_DATA)
            udp_rx_cnt <= udp_rx_cnt + 1'b1 ;
        else
            udp_rx_cnt <= 16'd0 ;
    end
    
    always @(posedge clk)
    begin
        if (~rstn)
            udp_rec_rdata <= 8'd0 ;
        else if(udp_rx_cnt > 16'd7 && udp_rx_cnt < udp_data_length)
            udp_rec_rdata <= udp_rx_data ;
    end

    //**************************************************//
    //generate udp rx end
    reg  udp_rx_end;
    always @(posedge clk)
    begin
        if (~rstn)
            udp_rx_end <= 1'b0 ;       
        else if (state == REC_END)    
            udp_rx_end <= 1'b1 ;   
        else
            udp_rx_end <= 1'b0 ;    
    end 
    
    always @(posedge clk)
    begin
        if (~rstn)
            udp_rec_data_valid <= 1'b0 ;
        else if (state == REC_DATA)
            udp_rec_data_valid <= 1'b1 ;
        else
            udp_rec_data_valid <= 1'b0 ;
    end

endmodule
