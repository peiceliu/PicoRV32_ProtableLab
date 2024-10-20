`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/01 22:01:53
// Design Name: 
// Module Name: mac_rx
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


module mac_rx(
    input                  clk,   
    input                  rstn,    
    
    input                  rx_en,
    input      [7:0]       mac_rx_datain,
    
    input                  checksum_err,     //checksum error from IP layer
    
    input                  ip_rx_end,        //ip receive end
    input                  arp_rx_end,       //arp receive end 
    output reg             ip_rx_req,        //ip rx request
    output reg             arp_rx_req,       //arp rx request
    
    output     [7:0]       mac_rx_dataout,
    output reg             mac_rec_error ,
    
    output reg [47:0]      mac_rx_dest_mac_addr,
    output reg [47:0]      mac_rx_sour_mac_addr
);

    reg [4:0]               mac_rx_cnt       ;
    reg [15:0]              mac_crc_cnt      ;
    
    reg [63:0]              preamble         ;//接收前导码           
    reg [3:0]               preamble_cnt     ;//前导码计数
               
    reg [15:0]              frame_type       ;   //type 16'h0800 IP; 16'h0806 ARP

    wire                    rx_en_posedge    ;
    reg                     rx_en_1d         ;
    reg                     rx_en_2d         ;
           
    reg [7:0]               mac_rx_data_1d   ;
    reg [7:0]               mac_rx_data_2d   ;
    reg [7:0]               mac_rx_data_3d   ;
           
//    wire                    mac_rx_head_end  ;
           
    reg  [15:0]             timeout          ;   
        
    reg                     crc_error        ;
    assign mac_rx_dataout = mac_rx_data_3d ;
    assign rx_en_posedge  = ~rx_en_1d & rx_en ;
    
    //MAC receive FSM
    parameter IDLE                =  8'b0000_0001 ;
    parameter REC_PREAMBLE        =  8'b0000_0010 ;
    parameter REC_MAC_HEAD        =  8'b0000_0100 ;
    parameter REC_IDENTIFY        =  8'b0000_1000 ;
    parameter REC_DATA            =  8'b0001_0000 ;
    parameter REC_FCS             =  8'b0010_0000 ;
    parameter REC_ERROR           =  8'b0100_0000 ;
    parameter REC_END             =  8'b1000_0000 ;
    
    reg [7:0]     rec_state   ;
    reg [7:0]     rec_state_n ;

    always @(posedge clk)
    begin
        if (~rstn)
            rec_state <= IDLE ;
        else 
            rec_state <= rec_state_n ;
    end

    always @(*)
    begin
        case(rec_state)
            IDLE            :  
            begin
                if (rx_en_posedge == 1'b1)
                    rec_state_n = REC_PREAMBLE ;
                else
                    rec_state_n = IDLE ;
            end
            REC_PREAMBLE    :  
            begin
                if (mac_rx_cnt == 7)
                    rec_state_n =  REC_MAC_HEAD  ;
                else
                    rec_state_n =  REC_PREAMBLE    ;
            end
            REC_MAC_HEAD    : 
            begin
                if (preamble != 64'h55_55_55_55_55_55_55_d5)
                    rec_state_n = REC_ERROR ;
                else if ( mac_rx_cnt == 16'd21)
                    rec_state_n = REC_IDENTIFY ;
                else
                    rec_state_n = REC_MAC_HEAD ; 
            end
            REC_IDENTIFY    : 
            begin
                if (frame_type == 16'h0800 || frame_type == 16'h0806)
                    rec_state_n = REC_DATA ;
                else
                    rec_state_n = REC_ERROR ;
            end
            REC_DATA        : 
            begin
                if (checksum_err)
                    rec_state_n = REC_ERROR ;
                else if (ip_rx_end|arp_rx_end)
                    rec_state_n = REC_FCS ;
                else if (timeout == 16'hffff)
                    rec_state_n = REC_ERROR ;
                else
                    rec_state_n = REC_DATA ;
            end                               
            REC_FCS         : 
            begin
                if (crc_error)
                    rec_state_n = REC_ERROR ;
                else if (mac_rx_cnt == 5'd27)
                    rec_state_n = REC_END ;
                else
                    rec_state_n = REC_FCS ;
            end
            REC_ERROR :  rec_state_n = IDLE  ;
            REC_END   :  rec_state_n = IDLE  ;
            default   :  rec_state_n = IDLE  ;
        endcase
    end

    //rx dv and rx data resigster
    always @(posedge clk)
    begin
        if (~rstn)
        begin
            rx_en_1d       <= 1'b0 ;
            rx_en_2d       <= 1'b0 ;
            mac_rx_data_1d <= 8'd0 ;
            mac_rx_data_2d <= 8'd0 ;
            mac_rx_data_3d <= 8'd0 ;
        end
        else
        begin
            rx_en_1d        <= rx_en ;                         
            rx_en_2d        <= rx_en_1d ;                      
            mac_rx_data_1d  <= mac_rx_datain ;                 
            mac_rx_data_2d  <= mac_rx_data_1d ;                
            mac_rx_data_3d  <= mac_rx_data_2d ;                
        end
    end
    
    //timeout
    always @(posedge clk)
    begin
        if (~rstn)
           timeout <= 16'd0 ;
        else if (rec_state == REC_DATA)
           timeout <= timeout + 1'b1 ;
        else
           timeout <= 16'd0 ;
    end
    
    always @(posedge clk)
    begin
        if (~rstn)
            mac_rx_cnt <= 5'd0 ;
        else if (rec_state == REC_PREAMBLE || rec_state == REC_MAC_HEAD || rec_state == REC_FCS)
            mac_rx_cnt <= mac_rx_cnt + 1'b1 ;
        else
            mac_rx_cnt <= 5'd0 ;
    end
    
    always @(posedge clk)
    begin
        if (~rstn)
            mac_crc_cnt <= 16'd0 ;
        else if (rx_en_2d)
            mac_crc_cnt <= mac_crc_cnt + 1'b1 ;
        else
            mac_crc_cnt <= 16'd0 ;
    end
    
    always @(posedge clk)
    begin
        if (~rstn)
            mac_rec_error <= 1'b0 ;
        else if (rx_en_posedge)
            mac_rec_error <= 1'b0 ;
        else if (rec_state == REC_ERROR)
            mac_rec_error <= 1'b1 ;
    end
    
    //============================================================================
    // CRC check            
    reg  [31:0] crc_check    ;                      
    reg         crcen        ;          
    reg         crcre        ; 
    reg  [7:0]  crc_din      ;
    reg  [31:0] crc_rec      ;
    always @(posedge clk)
    begin
        if (~rstn)
        begin
            crcen   <= 1'b0 ;
            crcre   <= 1'b1 ;
            crc_din <= 8'd0 ;
        end
        else if ((rec_state == REC_MAC_HEAD && mac_rx_cnt >8) || rec_state == REC_IDENTIFY || rec_state == REC_DATA)
        begin
            crcen   <= 1'b1 ;
            crcre   <= 1'b0 ;
            crc_din <= mac_rx_data_2d ;
        end
        else if(rec_state == REC_FCS && mac_rx_cnt == 5)
        begin
            crcen   <= 1'b0 ;
            crcre   <= 1'b1 ;
            crc_din <= 8'd0 ;
        end
        else
        begin
            crcen   <= 1'b0 ;
            crcre   <= 1'b0 ;
            crc_din <= 8'd0 ;
        end
    end

    wire [7:0] crc_data;
    wire       crc_out_en;
    assign crc_out_en = rec_state == REC_FCS;
    crc32_gen crc32_gen(
        .clk           (  clk        ),//input         clk       ,
        .rstn          (  rstn       ),//input         rstn      ,
        .crc32_init    (  crcre      ),//input         crc32_init, //crc校验值初始化信号
        .crc32_en      (  crcen      ),//input         crc32_en  ,  //crc校验使能信号
        .crc_read      (  crc_out_en ),//input         crc_read  , 
        .data          (  crc_din    ),//input  [7:0]  data      ,     
        .crc_out       (  crc_data   ) //output [7:0]  crc_out 
    );

    always @(posedge clk)
    begin
        if (~rstn)
            crc_check <= 32'd0 ;
        else if (rec_state == REC_FCS)
        begin
            case(mac_rx_cnt)
                5'd1  :  crc_check[31:24] <= crc_data ;
                5'd2  :  crc_check[23:16] <= crc_data;
                5'd3  :  crc_check[15:8]  <= crc_data;
                5'd4  :  crc_check[7:0]   <= crc_data;
                default :  crc_check <= crc_check ;
            endcase
        end
        else 
            crc_check <= 32'd0 ;
    end
    //received crc data
    always @(posedge clk)
    begin
        if (~rstn) 
            crc_rec  <= 48'd0 ;
        else if (rec_state == REC_FCS)
        begin
            case(mac_rx_cnt)
                5'd1   : crc_rec[31:24]      <= mac_rx_data_3d ;
                5'd2   : crc_rec[23:16]      <= mac_rx_data_3d ;
                5'd3   : crc_rec[15:8]       <= mac_rx_data_3d ;
                5'd4   : crc_rec[7:0]        <= mac_rx_data_3d ;
                default : crc_rec            <= crc_rec     ;
            endcase
        end
        else
            crc_rec <= crc_rec ;
    end 
    //check crc
    always @(posedge clk)
    begin
        if (~rstn)
            crc_error <= 1'b0 ;
        else if (rec_state == REC_FCS && mac_rx_cnt == 5)
        begin
            if (crc_check == crc_rec)
                crc_error <= 1'b0 ;
            else
                crc_error <= 1'b1 ;
        end
        else
            crc_error <= 1'b0 ;
    end

    //============================================================================
    // 前导码
    always @(posedge clk)
    begin
        if (~rstn) 
            preamble_cnt  <= 4'd0 ;
        else if (rx_en)
        begin
            if (preamble_cnt < 8)
                preamble_cnt <= preamble_cnt + 1'b1 ;
        end
        else
            preamble_cnt <= 4'd0 ;
    end

    always @(posedge clk)
    begin
        if (~rstn) 
          preamble  <= 64'd0 ;
        else if (rx_en)
        begin
            case(preamble_cnt)
                4'd0: preamble[63:56] <= mac_rx_datain ;
                4'd1: preamble[55:48] <= mac_rx_datain ;
                4'd2: preamble[47:40] <= mac_rx_datain ;
                4'd3: preamble[39:32] <= mac_rx_datain ;
                4'd4: preamble[31:24] <= mac_rx_datain ;
                4'd5: preamble[23:16] <= mac_rx_datain ; 
                4'd6: preamble[15:8]  <= mac_rx_datain ;
                4'd7: preamble[7:0]   <= mac_rx_datain ; 
            endcase
        end
        else
            preamble <= 64'd0 ;
    end   
    
    // MAC ADRESS receive
    always @(posedge clk)
    begin
      if (~rstn) 
          mac_rx_dest_mac_addr  <= 48'd0 ;
      else if (rec_state == REC_MAC_HEAD)
      begin
          case(mac_rx_cnt)
              5'd8    : mac_rx_dest_mac_addr[47:40] <= mac_rx_data_1d ;
              5'd9    : mac_rx_dest_mac_addr[39:32] <= mac_rx_data_1d ;
              5'd10   : mac_rx_dest_mac_addr[31:24] <= mac_rx_data_1d ;
              5'd11   : mac_rx_dest_mac_addr[23:16] <= mac_rx_data_1d ;
              5'd12   : mac_rx_dest_mac_addr[15:8]  <= mac_rx_data_1d ;
              5'd13   : mac_rx_dest_mac_addr[7:0]   <= mac_rx_data_1d ;
              default : mac_rx_dest_mac_addr <= mac_rx_dest_mac_addr ;
          endcase
      end
      else
          mac_rx_dest_mac_addr <= mac_rx_dest_mac_addr ;
    end
    
    always @(posedge clk)
    begin
        if (~rstn) 
            mac_rx_sour_mac_addr  <= 48'd0 ;
        else if (rec_state == REC_MAC_HEAD)
        begin
            case(mac_rx_cnt)
                5'd14   : mac_rx_sour_mac_addr[47:40] <= mac_rx_data_1d ;
                5'd15   : mac_rx_sour_mac_addr[39:32] <= mac_rx_data_1d ;
                5'd16   : mac_rx_sour_mac_addr[31:24] <= mac_rx_data_1d ;
                5'd17   : mac_rx_sour_mac_addr[23:16] <= mac_rx_data_1d ;
                5'd18   : mac_rx_sour_mac_addr[15:8]  <= mac_rx_data_1d ;
                5'd19   : mac_rx_sour_mac_addr[7:0]   <= mac_rx_data_1d ;
                default : mac_rx_sour_mac_addr        <= mac_rx_sour_mac_addr ;
            endcase
        end
        else
            mac_rx_sour_mac_addr <= mac_rx_sour_mac_addr ;
    end

    //===========================================================================
    //get Mac frame data type 
    always @(posedge clk)
    begin
        if (~rstn) 
            frame_type  <= 16'd0 ;
        else if (rec_state == REC_MAC_HEAD)
        begin
            case(mac_rx_cnt)
                5'd20   : frame_type[15:8] <= mac_rx_data_1d ;
                5'd21   : frame_type[7:0]  <= mac_rx_data_1d ;
                default : frame_type       <= frame_type     ;
            endcase
        end
        else
            frame_type <= frame_type ;
    end 

    always @(posedge clk)
    begin
        if (~rstn)
            ip_rx_req <=     1'b0 ;
        else if (rec_state == REC_IDENTIFY &&  frame_type == 16'h0800)
            ip_rx_req <=  1'b1 ;
        else
            ip_rx_req <=  1'b0 ;
    end
    
    always @(posedge clk)
    begin
        if (~rstn)
            arp_rx_req <= 1'b0 ;
        else if (rec_state == REC_IDENTIFY &&  frame_type == 16'h0806)
            arp_rx_req <= 1'b1 ;
        else
            arp_rx_req <= 1'b0 ;
    end

endmodule
