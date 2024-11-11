`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/16 21:46:53
// Design Name: 
// Module Name: icmp
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


module icmp(
    input                  clk,
    input                  rstn,
    
    input                  mac_send_end,
    input                  ip_tx_ack,
    input  [7:0]           icmp_rx_data,             //received data
    input                  icmp_rx_req,              //receive request
    input                  icmp_rev_error,           //receive error from MAC or IP
    input  [15:0]          upper_layer_data_length,  //data length received from IP layer
    
    input                  icmp_data_req,            //IP layer request data
    output reg             icmp_tx_ready,            //icmp reply data ready
    output reg [7:0]       icmp_tx_data,             //icmp reply data
    output                 icmp_tx_end,              //icmp reply end
    output reg             icmp_tx_req               //icmp reply request
);
       
    localparam ECHO_REQUEST = 8'h08 ;
    localparam ECHO_REPLY   = 8'h00 ;
    
    reg  [15:0]             icmp_rx_cnt ;
    
    reg                     icmp_rx_end ;
    reg                     icmp_checksum_error ;     //icmp receive checksum error
    reg                     icmp_type_error ;         //if icmp type is not 8'h08, do not reply
    reg  [15:0]             icmp_data_length ;        //data length register
    reg  [15:0]             icmp_data_length_1d ;
    reg  [10:0]             icmp_rec_ram_read_addr ;  //icmp ram read address
    wire [7:0]              icmp_rec_ram_rdata ;      //icmp ram read data
    reg  [7:0]              icmp_code  ;              //icmp code
    reg  [15:0]             icmp_id  ;                //icmp id
    reg  [15:0]             icmp_seq ;                //icmp seq
    reg                     checksum_finish ;         //icmp reply checksum generated finish
    
    reg [10:0]              ram_write_addr ;          //icmp ram write address, when receive icmp, write ram
    reg                     ram_wr_en ;               //icmp ram write enable
    reg                     icmp_rev_error_1d ;
    
    reg  [15:0]             timeout ;                 //timeout counter
    reg  [7:0]              icmp_rx_data_1d ;         //register for receive data
    
    reg                     mac_send_end_1d ;
    
    //receive and reply FSM
    parameter IDLE             =  12'b00000_0000_001  ;
    parameter REC_DATA         =  12'b00000_0000_010  ;
    parameter REC_ODD_DATA     =  12'b00000_0000_100  ;
    parameter VERIFY_CHECKSUM  =  12'b00000_0001_000  ;
    parameter REC_ERROR        =  12'b00000_0010_000  ;
    parameter REC_END_WAIT     =  12'b00000_0100_000  ;
    parameter GEN_CHECKSUM     =  12'b00000_1000_000  ;
    parameter SEND_WAIT_0      =  12'b00001_0000_000  ;
    parameter SEND_WAIT_1      =  12'b00010_0000_000  ;
    parameter SEND             =  12'b00100_0000_000  ;
    parameter REC_END          =  12'b01000_0000_000  ;
    parameter SEND_END         =  12'b10000_0000_000  ;

    reg [11:0]     state      ;
    reg [11:0]     state_n ;
    
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
              if (icmp_rx_req == 1'b1)
                  state_n = REC_DATA ;
              else
                  state_n = IDLE ;
          end
          REC_DATA       :
          begin
              if (icmp_rev_error_1d || icmp_type_error)
                  state_n = REC_ERROR ;
              else if (icmp_data_length[0] == 1'b0 && icmp_rx_cnt == icmp_data_length - 1)
                  state_n = VERIFY_CHECKSUM ;
              else if (icmp_data_length[0] == 1'b1 && icmp_rx_cnt == icmp_data_length - 2)
                  state_n = REC_ODD_DATA ;
              else if (icmp_rx_cnt == 16'hffff)
                  state_n = IDLE ;
              else
                  state_n = REC_DATA ;
          end
          REC_ODD_DATA   :
          begin
              if (icmp_rev_error_1d || icmp_type_error)
                  state_n = REC_ERROR ;
              else if (icmp_rx_cnt == icmp_data_length - 1)
                  state_n = VERIFY_CHECKSUM ;
              else
                  state_n = REC_ODD_DATA ;
          end
          VERIFY_CHECKSUM:
          begin
              if (icmp_checksum_error)
                  state_n = REC_ERROR ;
              else if (icmp_rx_end && checksum_finish)
                  state_n = REC_END_WAIT ;
              else if (icmp_rx_cnt == 16'hffff)
                  state_n = IDLE ;
              else
                  state_n = VERIFY_CHECKSUM ;
          end
          REC_ERROR      :
              state_n = IDLE  ;
          REC_END_WAIT   :
          begin
              if (icmp_rx_cnt == 16'd63)
                  state_n = REC_END ;
              else
                  state_n = REC_END_WAIT ;
          end
    	  SEND_WAIT_0      :
          begin
              if (ip_tx_ack)
                  state_n = SEND_WAIT_1 ;
              else
                  state_n = SEND_WAIT_0 ;
          end
          SEND_WAIT_1      :
          begin
              if (icmp_data_req)
                  state_n = SEND ;
              else if (timeout == 16'hffff)
                  state_n = IDLE ;
              else
                  state_n = SEND_WAIT_1 ;
          end
          SEND           :
          begin
              if (icmp_rx_cnt == icmp_data_length)
                  state_n = SEND_END ;
              else if (icmp_rx_cnt == 16'hffff)
                  state_n = IDLE ;
              else
                  state_n = SEND ;
          end
          REC_END        :
              state_n = SEND_WAIT_0  ;
          SEND_END       :
    	  begin
    		  if (mac_send_end_1d)
    		      state_n = IDLE  ;
    		  else
    		      state_n = SEND_END  ;
    	  end        
          default        :
              state_n = IDLE  ;
      endcase
    end

    always @(posedge clk)
    begin
        if (~rstn)
            mac_send_end_1d <= 1'b0 ;
        else 
            mac_send_end_1d <= mac_send_end ;
    end   
      
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_tx_req <=  1'b0 ;
    	else if (state == SEND_WAIT_1)
    	    icmp_tx_req <=  1'b0 ;
        else if (state == REC_END)
            icmp_tx_req <=  1'b1 ;
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_tx_ready <=  1'b0 ;
        else if (state == SEND_WAIT_1)
            icmp_tx_ready <=  1'b1 ;
        else
            icmp_tx_ready <=  1'b0 ;
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
            ram_wr_en <=  1'b0 ;
        else if (state == REC_DATA  || state == REC_ODD_DATA)
        begin
            if (icmp_rx_cnt < icmp_data_length && icmp_rx_cnt > 16'd7)
                ram_wr_en <=  1'b1 ;
            else
                ram_wr_en <=  1'b0 ;
        end
        else
            ram_wr_en <=  1'b0 ;
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
            ram_write_addr <=  11'b0 ;
        else if (state == REC_DATA  || state == REC_ODD_DATA)
            ram_write_addr <=  icmp_rx_cnt - 8 ;
        else
            ram_write_addr <=  11'b0 ;
    end
      
    //timeout counter
    always @(posedge clk)
    begin
        if (~rstn)
            timeout <= 16'd0 ;
        else if (state == SEND_WAIT_1)
            timeout <= timeout + 1'b1 ;
        else
            timeout <= 16'd0 ;
    end
    //received data register
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_rx_data_1d <= 8'd0 ;
        else
            icmp_rx_data_1d <= icmp_rx_data ;
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_rev_error_1d <= 1'b0 ;
        else
            icmp_rev_error_1d <= icmp_rev_error ;
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_data_length <= 16'd0 ;
        else if (state == IDLE)
            icmp_data_length <= upper_layer_data_length ;
    end
      
      
    //icmp receive and reply counter
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_rx_cnt <= 16'd0 ;
        else if (state == REC_DATA  || state == REC_END_WAIT ||  state == SEND)
            icmp_rx_cnt <= icmp_rx_cnt + 1'b1 ;
        else
            icmp_rx_cnt <= 16'd0 ;
    end
      
      
    //icmp type is not request
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_type_error <= 1'b0 ;
        else if (state == REC_DATA && icmp_rx_cnt == 16'd0 && icmp_rx_data != ECHO_REQUEST)
            icmp_type_error <= 1'b1 ;
        else
            icmp_type_error <= 1'b0 ;
    end
      
    //icmp code
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_code <= 8'd0 ;
        else if (state == REC_DATA && icmp_rx_cnt == 16'd1)
            icmp_code <= icmp_rx_data ;
    end
      
    //icmp id
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_id <= 16'd0 ;
        else if (state == REC_DATA && icmp_rx_cnt == 16'd4)
            icmp_id[15:8] <= icmp_rx_data ;
        else if (state == REC_DATA && icmp_rx_cnt == 16'd5)
            icmp_id[7:0] <= icmp_rx_data ;
    end
      
    //icmp seq
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_seq <= 16'd0 ;
        else if (state == REC_DATA && icmp_rx_cnt == 16'd6)
            icmp_seq[15:8] <= icmp_rx_data ;
        else if (state == REC_DATA && icmp_rx_cnt == 16'd7)
            icmp_seq[7:0] <= icmp_rx_data ;
    end
      
    //read ram address when reply
    always @(posedge clk)
    begin
        if (~rstn)
            icmp_rec_ram_read_addr <= 11'd0 ;
        else if (state == SEND && icmp_rx_cnt > 5)
            icmp_rec_ram_read_addr <= icmp_rx_cnt - 6 ;
        else
            icmp_rec_ram_read_addr <= 11'd0 ;
    end
    //received ram: depth 256 width 8
    icmp_rx_ram_8_256 icmp_receive_ram(		 
        .wr_data        (  icmp_rx_data_1d         ),// input [7:0]              
        .wr_addr        (  ram_write_addr          ),// input [10:0]             
        .wr_en          (  ram_wr_en               ),// input                    
        .wr_clk         (  clk                     ),// input                    
        .wr_rst         (  ~rstn                   ),// input                    
        .rd_addr        (  icmp_rec_ram_read_addr  ),// input [10:0]             
        .rd_data        (  icmp_rec_ram_rdata      ),// output [7:0]             
        .rd_clk         (  clk                     ),// input                    
        .rd_rst         (  ~rstn                   ) // input                    
//        .dina           (  icmp_rx_data_1d         ),                       
//        .addra          (  ram_write_addr          ),                       
//        .wea            (  ram_wr_en               ),                           
//        .clka           (  clk                     ),                                  
//        .addrb          (  icmp_rec_ram_read_addr  ),                       
//        .doutb          (  icmp_rec_ram_rdata      ),                       
//        .clkb           (  clk                     )                                 
    );
    //***************************************************************************//
    //verify checksum 32 bit adder, in the end, add itself until high 16 bit is 0
    //** ************************************************************************//
    reg  [31:0] checksum_tmp ;
    reg  [31:0] checksum_buf ;
    reg  [31:0] check_out ;
    reg  [31:0] checkout_buf ;
    wire [15:0] checksum ;
    reg  [2:0]  checksum_cnt ;
    `include "check_sum.vh"
    
    always @(posedge clk)
    begin
        if(rstn == 1'b0)
            checksum_tmp <= 32'd0;
        else if (state == REC_DATA)
        begin
            if(icmp_rx_cnt[0] == 1'b1)
                checksum_tmp <= checksum_adder({icmp_rx_data_1d,icmp_rx_data},checksum_buf);
        end
        else if (state == REC_ODD_DATA)
            checksum_tmp <= checksum_adder({icmp_rx_data,8'h00},checksum_tmp);   //if udp data length is odd, fill with one byte 8'h00
        else if (state == IDLE)
            checksum_tmp <= 32'd0;
    end
      
    always @(posedge clk)
    begin
        if(rstn == 1'b0)
            checksum_cnt <= 3'd0 ;
        else if (state ==  VERIFY_CHECKSUM)
            checksum_cnt <= checksum_cnt + 1'b1 ;
        else
            checksum_cnt <= 3'd0 ;
    end
      
    always @(posedge clk)
    begin
        if(rstn == 1'b0)
            check_out <= 32'd0;
        else if (state ==  VERIFY_CHECKSUM)
        begin
            if (checksum_cnt == 3'd0)
                check_out <= checksum_out(checksum_tmp) ;
            else if (checksum_cnt == 3'd1)
                check_out <= checksum_out(check_out) ;
        end
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
            checksum_buf <= 32'd0 ;
        else if (state == REC_DATA)
            checksum_buf <= checksum_tmp ;
        else
            checksum_buf <= 32'd0 ;
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
            checkout_buf <= 32'd0 ;
        else
            checkout_buf <= check_out ;
    end
      
    assign checksum = ~checkout_buf[15:0] ;
    
    //generate checksum error signal and rx end signal
    always @(posedge clk)
    begin
        if (~rstn)
        begin
            icmp_checksum_error <= 1'b0 ;
            icmp_rx_end <= 1'b0 ;
        end
        else if (state == VERIFY_CHECKSUM && checksum_cnt == 3'd3)
        begin
            if (checksum == 16'd0)
            begin
                icmp_checksum_error <= 1'b0 ;
                icmp_rx_end <= 1'b1 ;
            end
            else
            begin
                icmp_checksum_error <= 1'b1 ;
                icmp_rx_end <= 1'b0 ;
            end
        end
        else
        begin
            icmp_checksum_error <= 1'b0 ;
            icmp_rx_end <= 1'b0 ;
        end
    end
      
    //*******************************************************************//
    //reply checksum
    //*******************************************************************//
    reg  [31:0] reply_checksum_tmp ;
    reg  [31:0] reply_checksum_buf ;
    reg  [31:0] reply_check_out ;
    reg  [31:0] reply_checkout_buf ;
    wire [15:0] reply_checksum ;
    
    
    always @(posedge clk)
    begin
        if(rstn == 1'b0)
            reply_checksum_tmp <= 32'd0;
        else if (state == REC_DATA)
        begin
            if (icmp_rx_cnt == 16'd1)
                reply_checksum_tmp <= checksum_adder({8'h00,icmp_rx_data}, 16'h0000);  //source ip address
            else if (icmp_rx_cnt == 16'd3)
                reply_checksum_tmp <= reply_checksum_tmp ;  //source ip address
            else
            begin
                if(icmp_rx_cnt[0] == 1'b1)
                    reply_checksum_tmp <= checksum_adder({icmp_rx_data_1d,icmp_rx_data},reply_checksum_buf);
            end
        end
        else if (state == REC_ODD_DATA)
            reply_checksum_tmp <= checksum_adder({icmp_rx_data,8'h00},reply_checksum_tmp);   //if udp data length is odd, fill with one byte 8'h00
        else if (state == IDLE)
            reply_checksum_tmp <= 32'd0;
    end
      
      
    always @(posedge clk)
    begin
        if(rstn == 1'b0)
            reply_check_out <= 32'd0;
        else if (state ==  VERIFY_CHECKSUM)
        begin
            if (checksum_cnt == 3'd0)
                reply_check_out <= checksum_out(reply_checksum_tmp) ;
            else if (checksum_cnt == 3'd1)
                reply_check_out <= checksum_out(reply_check_out) ;
        end
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
            reply_checksum_buf <= 32'd0 ;
        else if (state == REC_DATA)
            reply_checksum_buf <= reply_checksum_tmp ;
        else
            reply_checksum_buf <= 32'd0 ;
    end
      
    always @(posedge clk)
    begin
        if (~rstn)
            reply_checkout_buf <= 32'd0 ;
        else if (state == VERIFY_CHECKSUM)
            reply_checkout_buf <= reply_check_out ;
    end
      
    assign reply_checksum = ~reply_checkout_buf[15:0] ;
    
    always @(posedge clk)
    begin
        if (~rstn)
            checksum_finish <= 1'b0 ;
        else if (state == VERIFY_CHECKSUM && checksum_cnt == 3'd3)
            checksum_finish <= 1'b1 ;
        else
            checksum_finish <= 1'b0 ;
    end
      
      
    //*****************************************************************************************//
    //send icmp data
    //*****************************************************************************************//
    always @(posedge clk)
    begin
        if (~rstn)
           icmp_tx_data <= 8'h00  ;
        else if (state == SEND)
        begin
            case(icmp_rx_cnt)
                16'd1    :   icmp_tx_data <= ECHO_REPLY ;
                16'd2    :   icmp_tx_data <= icmp_code ;
                16'd3    :   icmp_tx_data <= reply_checksum[15:8];
                16'd4    :   icmp_tx_data <= reply_checksum[7:0] ;
                16'd5    :   icmp_tx_data <= icmp_id[15:8] ;
                16'd6    :   icmp_tx_data <= icmp_id[7:0] ;
                16'd7    :   icmp_tx_data <= icmp_seq[15:8] ;
                16'd8    :   icmp_tx_data <= icmp_seq[7:0] ;
                default  :   icmp_tx_data <= icmp_rec_ram_rdata ;
            endcase
        end
        else
           icmp_tx_data <= 8'h00 ;
    end
    
endmodule
