`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/02 11:14:02
// Design Name: 
// Module Name: rgmii_test
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


module arp_mac_top#(
    parameter LOCAL_MAC_ADDR = 48'h3C_2B_1A_09_4D_5E,
    parameter LOCAL_IP_ADDR  = 32'hC0_A8_00_02
) (
    input           clk,
    input           rstn,
    
    input           checksum_err,
    
    input           ip_tx_req  ,
    input           ip_tx_ready,
    input  [7:0]    ip_tx_data ,
    input           ip_tx_end  ,
    output          ip_tx_ack  ,
    output          mac_data_req,  
    output          mac_send_end,
    
    input           ip_rx_end  ,
    output          ip_rx_req,
    output  [7:0]   mac_rx_dataout,
    output  [47:0]  mac_rx_dest_mac_addr, 
    output  [47:0]  mac_rx_sour_mac_addr,

    input           arp_request_req, 
    output          arp_found,
    output          mac_not_exist,
    output [47:0]   arp_dest_mac_addr,
    
    input   [31:0]  dest_ip_addr,
    
    output          mac_rec_error,
    
    output  [7:0]   mac_tx_data,  
    output          mac_data_valid, 
    
    input           rx_en,               
    input   [7:0]   mac_rx_datain 
);    

    wire          arp_tx_req;  
    wire          arp_tx_ready;
    wire [7:0]    arp_tx_data; 
    wire          arp_tx_end;  
    wire          arp_tx_ack;  
    
    wire          arp_rx_end;
    wire          arp_rx_req;
            
    wire [31:0]   arp_rec_source_ip; 
    wire [47:0]   arp_rec_source_mac;
                                
    wire [47:0]   dest_mac_addr;
         
    assign arp_dest_mac_addr = dest_mac_addr;
    arp_cache arp_cache(
        .clk                    (  clk                   ),//input                clk ,
        .rst_n                  (  rstn                  ),//input                rst_n ,
                                                          
        .arp_found              (  arp_found             ),//input                arp_found,
        .arp_rec_source_ip_addr (  arp_rec_source_ip     ),//input      [31:0]    arp_rec_source_ip_addr,
        .arp_rec_source_mac_addr(  arp_rec_source_mac    ),//input      [47:0]    arp_rec_source_mac_addr,
                                                            
        .dest_ip_addr           (  dest_ip_addr          ),//input      [31:0]    dest_ip_addr,
        .dest_mac_addr          (  dest_mac_addr         ),//output reg [47:0]    dest_mac_addr,
                                                         
        .mac_not_exist          (  mac_not_exist         ) //output reg           mac_not_exist
    ) ;
    
    wire    arp_reply_req; 
    
    arp_tx arp_tx(
        .clk                    (  clk                   ),//input                clk             ,                            
        .rstn                   (  rstn                  ),//input                rstn            ,                            
             //04-0E-3C-9E-D1-37                                                                                                          
        .dest_mac_addr          (  48'h04_0E_3C_9E_D1_37 ),//input  [47:0]        dest_mac_addr   ,//destination mac address    
        .sour_mac_addr          (  LOCAL_MAC_ADDR        ),//input  [47:0]        sour_mac_addr   , //source mac address       
        .sour_ip_addr           (  LOCAL_IP_ADDR         ),//input  [31:0]        sour_ip_addr    , //source ip address        
        .dest_ip_addr           (  dest_ip_addr          ),//input  [31:0]        dest_ip_addr    ,//destination ip address     
                                                                                 
        .mac_data_req           (  mac_data_req          ),//input                mac_data_req,   //mac layer request data
        .arp_request_req        (  arp_request_req       ),//input                arp_request_req,//arp request
        .arp_reply_ack          (  arp_reply_ack         ),//output reg           arp_reply_ack,  //arp reply ack to arp rx module
        .arp_reply_req          (  arp_reply_req         ),//input                arp_reply_req,  //arp reply request from arp rx module
        .arp_tx_req             (  arp_tx_req            ),//output reg           arp_tx_req,
        .arp_rec_sour_ip_addr   (  arp_rec_source_ip     ),//input  [31:0]        arp_rec_sour_ip_addr,
        .arp_rec_sour_mac_addr  (  arp_rec_source_mac    ),//input  [47:0]        arp_rec_sour_mac_addr,
        .mac_send_end           (  mac_send_end          ),//input                mac_send_end,
        .mac_tx_ack             (  arp_tx_ack            ),//input                mac_tx_ack,
                                                         
        .arp_tx_ready           (  arp_tx_ready          ),//output reg           arp_tx_ready,
        .arp_tx_data            (  arp_tx_data           ),//output reg [7:0]     arp_tx_data,
        .arp_tx_end             (  arp_tx_end            ) //output reg           arp_tx_end
    ) ;                         
                                
    arp_rx arp_rx(              
        .clk                    (  clk                   ),//input                  clk,   
        .rstn                   (  rstn                  ),//input                  rstn,    
                                                         
        .local_ip_addr          (  LOCAL_IP_ADDR         ),//input       [31:0]     local_ip_addr,
        .local_mac_addr         (  LOCAL_MAC_ADDR        ),//input       [47:0]     local_mac_addr,
        .arp_rx_data            (  mac_rx_dataout        ),//input       [ 7:0]     arp_rx_data,          //arp received data                        
        .arp_rx_req             (  arp_rx_req            ),//input                  arp_rx_req,           //arp rx request from mac                  
        .arp_rx_end             (  arp_rx_end            ),//output reg             arp_rx_end,           //arp rx end                               
                                                                                                                     
        .arp_reply_ack          (  arp_reply_ack         ),//input                  arp_reply_ack,        //arp reply ack from arp reply module      
        .arp_reply_req          (  arp_reply_req         ),//output reg             arp_reply_req,        //arp reply request to arp reply module    
                                                                                                                     
        .arp_rec_sour_ip_addr   (  arp_rec_source_ip     ),//output reg [31:0]      arp_rec_sour_ip_addr, //arp received source ip address           
        .arp_rec_sour_mac_addr  (  arp_rec_source_mac    ),//output reg [47:0]      arp_rec_sour_mac_addr,//arp received mac address                 
        .arp_found              (  arp_found             ) //output reg             arp_found             //found destination mac address            
    ) ;                         
                                
    mac_layer mac_layer(        
        .clk                    (  clk                   ),//input           clk,          
        .rstn                   (  rstn                  ),//input           rstn,         
                                                         
        .arp_tx_req             (  arp_tx_req            ),//input           arp_tx_req,   
        .arp_tx_ready           (  arp_tx_ready          ),//input           arp_tx_ready,
        .arp_tx_data            (  arp_tx_data           ),//input  [7:0]    arp_tx_data,  
        .arp_tx_end             (  arp_tx_end            ),//input           arp_tx_end,   
        .arp_tx_ack             (  arp_tx_ack            ),//output          arp_tx_ack,   
                                                         
        .ip_tx_req              (  ip_tx_req             ),//input           ip_tx_req  ,    
        .ip_tx_ready            (  ip_tx_ready           ),//input           ip_tx_ready,  
        .ip_tx_data             (  ip_tx_data            ),//input  [7:0]    ip_tx_data ,   
        .ip_tx_end              (  ip_tx_end             ),//input           ip_tx_end  ,    
        .ip_tx_ack              (  ip_tx_ack             ),//output          ip_tx_ack  ,    
                                                         
        .mac_data_req           (  mac_data_req          ),//output          mac_data_req,              
        .mac_send_end           (  mac_send_end          ),//output          mac_send_end,  
                                                         
        .mac_tx_data            (  mac_tx_data           ),//output  [7:0]   mac_tx_data,  
        .mac_data_valid         (  mac_data_valid        ),//output          mac_data_valid, 
                                                         
        .rx_en                  (  rx_en                 ),//input           rx_en,               
        .mac_rx_datain          (  mac_rx_datain         ),//input   [7:0]   mac_rx_datain,       
                                                         
        .checksum_err           (  checksum_err          ),//input           checksum_err,        
                                                         
        .ip_rx_end              (  ip_rx_end             ),//input           ip_rx_end,           
        .arp_rx_end             (  arp_rx_end            ),//input           arp_rx_end,          
        .ip_rx_req              (  ip_rx_req             ),//output          ip_rx_req,           
        .arp_rx_req             (  arp_rx_req            ),//output          arp_rx_req,          
                                             
        .mac_rx_dataout         (  mac_rx_dataout        ),//output  [7:0]   mac_rx_dataout,      
        .mac_rec_error          (  mac_rec_error         ),//output          mac_rec_error ,      
                                                                 
        .mac_rx_dest_mac_addr   (  mac_rx_dest_mac_addr  ),//output  [47:0]  mac_rx_dest_mac_addr,
        .mac_rx_sour_mac_addr   (  mac_rx_sour_mac_addr  ) //output  [47:0]  mac_rx_sour_mac_addr 
    );
    
endmodule
