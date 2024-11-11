`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/01 22:01:53
// Design Name: 
// Module Name: ip_rx
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


module ip_rx(
    input                  clk,   
    input                  rstn,  
    
    input    [31:0]        local_ip_addr,
    input    [47:0]        local_mac_addr,
    
    input  [7:0]           ip_rx_data,
    input                  ip_rx_req,  
    input  [47:0]          mac_rx_dest_mac_addr, 
    
    output reg             udp_rx_req,                   //udp rx request
    output reg             icmp_rx_req,                  //icmp rx request  
    output reg             ip_addr_check_error,          //ip address is not equal to local address
    
    output reg [15:0]      upper_layer_data_length,      //udp or icmp data length = ip data length - ip header length
    output reg [15:0]      ip_total_data_length,         //send data length
    
    output reg [7:0]       net_protocol,                 //network layer protocol: 8'h11 udp  8'h01 icmp
    output reg [31:0]      ip_rec_source_addr,           //received source ip address
    output reg [31:0]      ip_rec_dest_addr,      //received destination ip address
    
    output reg             ip_rx_end,
    output reg             ip_checksum_error
) ;
    `include "check_sum.vh"
    reg  [15:0]            ip_rx_cnt ;
    reg  [15:0]            ip_rec_data_length ;
              
    reg  [7:0]             ip_rx_data_1d ;
    reg  [7:0]             ip_rx_data_2d ;
    
    reg  [3:0]             header_length_buf ;
    wire [5:0]             header_length ;
    
    parameter IDLE             =  5'b00001  ;
    parameter REC_HEADER0      =  5'b00010  ;
    parameter REC_HEADER1      =  5'b00100  ;
    parameter REC_DATA         =  5'b01000  ;
    parameter REC_END          =  5'b10000  ;
    
    reg [4:0]     state      ;
    reg [4:0]     state_n ;
    
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
             if (ip_rx_req == 1'b1)
                 state_n = REC_HEADER0 ;
             else
                 state_n = IDLE ;
         end
         REC_HEADER0    :      
         begin
             if (ip_rx_cnt == 16'd3)
                 state_n = REC_HEADER1 ;
             else
                 state_n = REC_HEADER0 ;
         end
         REC_HEADER1    :      
         begin
             if (ip_rx_cnt == header_length - 1)
                 state_n = REC_DATA ;
             else
                 state_n = REC_HEADER1 ;
         end
         REC_DATA       :   
         begin
             if (ip_checksum_error || ip_rx_end)
                 state_n = REC_END ;        
             else if (ip_rx_cnt == 16'hffff)
                 state_n = REC_END ;                         
             else
                state_n = REC_DATA ;
         end    
         REC_END        :   state_n = IDLE  ;
         default        :   state_n = IDLE  ;
         endcase
    end
    
    assign header_length = {header_length_buf,2'd0} ;//*4

    always @(posedge clk)
    begin
        if (~rstn)
            ip_rx_end <= 1'b0 ;
        else if (state == REC_DATA && ip_rx_cnt == ip_total_data_length - 3)
            ip_rx_end <= 1'b1 ;
        else
            ip_rx_end <= 1'b0 ;
    end
    //mac addr and ip addr is not equal to local addr, assert error
    always @(posedge clk)
    begin
        if (~rstn)
            ip_addr_check_error <= 1'b0 ;
        else if (state == REC_DATA)
        begin
            if (mac_rx_dest_mac_addr == local_mac_addr && ip_rec_dest_addr == local_ip_addr)                        
                ip_addr_check_error <= 1'b0 ;
            else
                ip_addr_check_error <= 1'b1 ;
        end
        else
            ip_addr_check_error <= 1'b0 ;
    end
    //generate udp rx request signal
    always @(posedge clk)
    begin
        if (~rstn)
            udp_rx_req <= 1'b0 ;
        else if (state == REC_HEADER1 && net_protocol == 8'h11 && ip_rx_cnt == header_length - 2)
            udp_rx_req <= 1'b1 ;
        else
            udp_rx_req <= 1'b0 ;
    end
    //generate icmp rx request signal
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_rx_req <= 1'b0 ;
        else if (state == REC_HEADER1 && net_protocol == 8'h01 && ip_rx_cnt == header_length - 2)
            icmp_rx_req <= 1'b1 ;
        else
            icmp_rx_req <= 1'b0 ;
    end
    
    
    //icmp or udp data length                                        
    always @(posedge clk)
    begin
        if (~rstn)
            upper_layer_data_length <= 16'd0 ;
        else
            upper_layer_data_length <= ip_rec_data_length - header_length  ;
    end 
                                            
    always @(posedge clk)
    begin
        if (~rstn)
        begin
            ip_rx_data_1d <= 8'd0 ;
            ip_rx_data_2d <= 8'd0 ;
        end
        else
        begin
            ip_rx_data_1d <= ip_rx_data ;
            ip_rx_data_2d <= ip_rx_data_1d ;
        end
    end  
    
    always @(posedge clk)
    begin
        if (~rstn)
            ip_rx_cnt <= 16'd0 ;
        else if (state == REC_HEADER0 || state == REC_HEADER1 || state == REC_DATA)
            ip_rx_cnt <= ip_rx_cnt + 1'b1 ;
        else
            ip_rx_cnt <= 16'd0 ;
    end
    //total length
    always @(posedge clk)
    begin
        if (~rstn)
            ip_total_data_length <= 16'd0 ;
        else if (state == REC_HEADER1)
        begin
            if (ip_rec_data_length < 16'd46)
                ip_total_data_length <= 16'd46 ;
            else
                ip_total_data_length <= ip_rec_data_length ;
        end
    end

    //ip header length
    always @(posedge clk)
    begin
        if (~rstn)
            header_length_buf <= 4'd0 ;
        else if (state == REC_HEADER0 && ip_rx_cnt == 16'd0)
            header_length_buf <= ip_rx_data[3:0] ;
    end
    //ip data total length
    always @(posedge clk)
    begin
        if (~rstn)
            ip_rec_data_length <= 16'd0 ;
        else if (state == REC_HEADER0 && ip_rx_cnt == 16'd2)
            ip_rec_data_length[15:8] <= ip_rx_data  ;
        else if (state == REC_HEADER0 && ip_rx_cnt == 16'd3)
            ip_rec_data_length[7:0] <= ip_rx_data  ;
    end

    //network layer protocol
    always @(posedge clk)
    begin
        if (~rstn)
            net_protocol <= 8'd0 ;
        else if (state == REC_HEADER1 && ip_rx_cnt == 16'd9)
            net_protocol <= ip_rx_data ;
    end
    
    //ip source address
    always @(posedge clk)
    begin
        if (~rstn)
            ip_rec_source_addr <= 32'd0 ;
        else if (state == REC_HEADER1 && ip_rx_cnt == 16'd12)
            ip_rec_source_addr[31:24] <= ip_rx_data ;
        else if (state == REC_HEADER1 && ip_rx_cnt == 16'd13)
            ip_rec_source_addr[23:16] <= ip_rx_data ;
        else if (state == REC_HEADER1 && ip_rx_cnt == 16'd14)
            ip_rec_source_addr[15:8] <= ip_rx_data ;
        else if (state == REC_HEADER1 && ip_rx_cnt == 16'd15)
            ip_rec_source_addr[7:0] <= ip_rx_data ;
    end
    //ip source address
    always @(posedge clk)
    begin
        if (~rstn)
            ip_rec_dest_addr <= 32'd0 ;
        else if (state == REC_HEADER1 && ip_rx_cnt == 16'd16)
            ip_rec_dest_addr[31:24] <= ip_rx_data ;
        else if (state == REC_HEADER1 && ip_rx_cnt == 16'd17)
            ip_rec_dest_addr[23:16] <= ip_rx_data ;
        else if (state == REC_HEADER1 && ip_rx_cnt == 16'd18)
            ip_rec_dest_addr[15:8] <= ip_rx_data ;
        else if (state == REC_HEADER1 && ip_rx_cnt == 16'd19)
            ip_rec_dest_addr[7:0] <= ip_rx_data ;
    end
    
    //****************************************************************//
    //verify checksum
    //****************************************************************//
    reg  [31:0] checksum_tmp ;
    reg  [31:0] checksum_buf ;
    reg  [31:0] check_out ;
    reg  [31:0] checkout_buf ;
    wire [15:0] checksum ;
    reg  [2:0]  checksum_cnt ;
    
    always @(posedge clk)
    begin
        if (~rstn)
            checksum_tmp <= 32'd0; 
        else if (state == REC_HEADER0 || state == REC_HEADER1)
        begin
            if (ip_rx_cnt[0] == 1'b1)
                checksum_tmp <= checksum_adder({ip_rx_data_1d, ip_rx_data},checksum_buf);
        end
        else if (state == IDLE)
            checksum_tmp <= 32'd0; 
    end
    
    always @(posedge clk)
    begin
      if (~rstn)
          check_out <= 32'd0; 
      else if (state == REC_DATA)   
          check_out <= checksum_out(checksum_tmp) ;
    end
    
    always @(posedge clk)
    begin
      if(rstn == 1'b0)
          checksum_cnt <= 3'd0 ; 
      else if (state ==     REC_DATA)
      begin
          if (checksum_cnt == 3'd7)
              checksum_cnt <= checksum_cnt ;    
          else    
              checksum_cnt <= checksum_cnt + 1'b1 ;
      end
      else
          checksum_cnt <= 3'd0 ;    
    end
    
    always @(posedge clk)
    begin
        if (~rstn)
            checksum_buf <= 32'd0 ;
        else
            checksum_buf <= checksum_tmp ;
    end
    
    always @(posedge clk)
    begin
        if (~rstn)
            checkout_buf <= 32'd0 ;
        else
            checkout_buf <= check_out ;
    end
    
    assign checksum = ~checkout_buf[15:0] ;
    
    always @(posedge clk)
    begin
        if (~rstn)
            ip_checksum_error <= 1'b0 ;
        else if (state == REC_DATA && checksum_cnt == 3'd2)
        begin
            if (checksum == 16'd0)     
                ip_checksum_error <= 1'b0 ;
            else
                ip_checksum_error <= 1'b1 ;
        end
        else
            ip_checksum_error <= 1'b0 ;
    end 

endmodule
