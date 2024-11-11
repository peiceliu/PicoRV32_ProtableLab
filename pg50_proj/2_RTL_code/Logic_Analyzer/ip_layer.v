`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/16 21:41:05
// Design Name: 
// Module Name: ip_layer
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


module ip_layer#(
    parameter    LOCAL_IP  = 32'hC0_A8_00_02,
    parameter    LOCAL_MAC = 48'h3C_2B_1A_09_4D_5E
) (
    input              clk, 
    input              rstn,
    //MAC TX
    input              mac_tx_ack,  
    input              mac_send_end,
    input              mac_data_req,
    output             ip_tx_req, 
    output             ip_tx_ready, 
    output [7:0]       ip_tx_data,  
    output             ip_tx_end,    
    //MAC RX
    input  [7:0]       ip_rx_data,          
    input              ip_rx_req,           
    input  [47:0]      mac_rx_dest_mac_addr,
    output             ip_rx_end,  

    input              mac_rec_err,  
    //UPPER LAYER TX  
    input  [47:0]      dest_mac_addr,
    input  [31:0]      dest_ip_addr,

    input              udp_tx_req,          
    input              udp_tx_ready ,       
    input      [7:0]   udp_tx_data,         
    input      [15:0]  udp_send_data_length,
    output             udp_tx_ack,     
    
    output             upper_data_req,    

    //UPPER LAYER RX 
    output             udp_rx_req,
    output             ip_addr_check_error,                                                       
    output [7:0]       net_protocol,           
    output [31:0]      ip_rec_source_addr,     
    output [31:0]      ip_rec_dest_addr,   
    output [15:0]      upper_layer_data_length,
            
    output             ip_checksum_error       
);

    wire [7:0]         upper_layer_data;      
    wire               upper_tx_ready;                             
    wire               ip_tx_req;          
    wire [15:0]        ip_send_data_length;                                  
    wire               ip_tx_ack;
    
    wire               icmp_tx_ready;
    wire [7:0]         icmp_tx_data; 
    wire               icmp_tx_end;  
    wire               icmp_tx_req;
    wire               icmp_tx_ack;  
    wire  [7:0]        ip_send_type;
    
    wire [15:0]        icmp_send_data_length;  
    wire               icmp_rev_error;
    assign  icmp_rev_error = (mac_rec_err | ip_addr_check_error | ip_checksum_error);
            
    icmp icmp(
        .clk                      (  clk                      ),//input                  clk,
        .rstn                     (  rstn                     ),//input                  rstn,
                                                            
        .mac_send_end             (  mac_send_end             ),//input                  mac_send_end,
        .ip_tx_ack                (  icmp_tx_ack              ),//input                  ip_tx_ack,
        .icmp_rx_data             (  ip_rx_data               ),//input  [7:0]           icmp_rx_data,             //received data
        .icmp_rx_req              (  icmp_rx_req              ),//input                  icmp_rx_req,              //receive request
        .icmp_rev_error           (  icmp_rev_error           ),//input                  icmp_rev_error,           //receive error from MAC or IP
        .upper_layer_data_length  (  upper_layer_data_length  ),//input  [15:0]          upper_layer_data_length,  //data length received from IP layer
                                                            
        .icmp_data_req            (  upper_data_req           ),//input                  icmp_data_req,            //IP layer request data
        .icmp_tx_ready            (  icmp_tx_ready            ),//output reg             icmp_tx_ready,            //icmp reply data ready
        .icmp_tx_data             (  icmp_tx_data             ),//output reg [7:0]       icmp_tx_data,             //icmp reply data
        .icmp_tx_end              (                           ),//output                 icmp_tx_end,              //icmp reply end
        .icmp_tx_req              (  icmp_tx_req              ) //output reg             icmp_tx_req               //icmp reply request
    );
    
    wire       tx_ack;  
    wire       tx_req;  
    wire       tx_ready ;
    wire[7:0]  tx_data; 

    assign ip_tx_req= tx_req;
    ip_tx_mode ip_tx_mode(
        .clk                      (  clk                      ),//input                    clk ,
        .rstn                     (  rstn                     ),//input                    rstn,
        .mac_send_end             (  mac_send_end             ),//input                    mac_send_end,
                                                            
        .udp_tx_req               (  udp_tx_req               ),//input                    udp_tx_req,
        .udp_tx_ready             (  udp_tx_ready             ),//input                    udp_tx_ready ,
        .udp_tx_data              (  udp_tx_data              ),//input      [7:0]         udp_tx_data,
        .udp_send_data_length     (  udp_send_data_length     ),//input      [15:0]        udp_send_data_length,
        .udp_tx_ack               (  udp_tx_ack               ),//output reg               udp_tx_ack,
                                                            
        .icmp_tx_req              (  icmp_tx_req              ),//input                    icmp_tx_req,
        .icmp_tx_ready            (  icmp_tx_ready            ),//input                    icmp_tx_ready,
        .icmp_tx_data             (  icmp_tx_data             ),//input      [7:0]         icmp_tx_data,
        .icmp_send_data_length    (  icmp_send_data_length    ),//input      [15:0]        icmp_send_data_length,
        .icmp_tx_ack              (  icmp_tx_ack              ),//output reg               icmp_tx_ack,
                                                            
        .ip_tx_ack                (  tx_ack                   ),//input                    ip_tx_ack,
        .ip_tx_req                (  tx_req                   ),//output reg               ip_tx_req,
        .ip_tx_ready              (  tx_ready                 ),//output reg               ip_tx_ready,
        .ip_tx_data               (  tx_data                  ),//output reg [7:0]         ip_tx_data,
        .ip_send_type             (  ip_send_type             ),//output reg [7:0]         ip_send_type,
        .ip_send_data_length      (  ip_send_data_length      ) //output reg [15:0]        ip_send_data_length
    );

    ip_tx ip_tx(
        .clk                      (  clk                      ),//input                clk         ,
        .rstn                     (  rstn                     ),//input                rstn        ,
                                                              
        .dest_mac_addr            (  dest_mac_addr            ),//input  [47:0]        dest_mac_addr,        //destination mac address
        .sour_mac_addr            (  LOCAL_MAC                ),//input  [47:0]        sour_mac_addr,        //source mac address
        .ttl                      (  8'h80                    ),//input  [7:0]         ttl,                  
        .ip_send_type             (  ip_send_type             ),//input  [7:0]         ip_send_type,         
        .sour_ip_addr             (  LOCAL_IP                 ),//input  [31:0]        sour_ip_addr,         
        .dest_ip_addr             (  dest_ip_addr             ),//input  [31:0]        dest_ip_addr,         
        .upper_layer_data         (  tx_data                  ),//input  [7:0]         upper_layer_data,     //data from udp or icmp
        .upper_data_req           (  upper_data_req           ),//output reg           upper_data_req,       //request data from udp or icmp
        .upper_tx_ready           (  tx_ready                 ),//input                upper_tx_ready,
                                                              
        .ip_tx_req                (  tx_req                   ),//input                ip_tx_req,  
        .ip_tx_ack                (  tx_ack                   ),//output reg           ip_tx_ack,         //IP数据报发送请求
        .ip_send_data_length      (  ip_send_data_length      ),//input  [15:0]        ip_send_data_length ,
                                                              
        .mac_tx_ack               (  mac_tx_ack               ),//input                mac_tx_ack,
        .mac_send_end             (  mac_send_end             ),//input                mac_send_end,
        .mac_data_req             (  mac_data_req             ),//input                mac_data_req,
                                                              
        .ip_tx_ready              (  ip_tx_ready              ),//output reg           ip_tx_ready,
        .ip_tx_data               (  ip_tx_data               ),//output reg [7:0]     ip_tx_data,
        .ip_tx_end                (  ip_tx_end                ) //output reg           ip_tx_end
    ) ;
    
    ip_rx ip_rx(
        .clk                      (  clk                      ),//input                  clk,   
        .rstn                     (  rstn                     ),//input                  rstn,  
                                                              
        .local_ip_addr            (  LOCAL_IP                 ),//input    [31:0]        local_ip_addr,
        .local_mac_addr           (  LOCAL_MAC                ),//input    [47:0]        local_mac_addr,
                                                              
        .ip_rx_data               (  ip_rx_data               ),//input  [7:0]           ip_rx_data,
        .ip_rx_req                (  ip_rx_req                ),//input                  ip_rx_req,  
        .mac_rx_dest_mac_addr     (  mac_rx_dest_mac_addr     ),//input  [47:0]          mac_rx_dest_mac_addr, 
        
        .udp_rx_req               (  udp_rx_req               ),//output reg             udp_rx_req,                   //udp rx request
        .icmp_rx_req              (  icmp_rx_req              ),//output reg             icmp_rx_req,                  //icmp rx request  
        .ip_addr_check_error      (  ip_addr_check_error      ),//output reg             ip_addr_check_error,          //ip address is not equal to local address
                               
        .upper_layer_data_length  (  upper_layer_data_length  ),//output reg [15:0]      upper_layer_data_length,      //udp or icmp data length = ip data length - ip header length
        .ip_total_data_length     (  icmp_send_data_length    ),//output reg [15:0]      ip_total_data_length,         //send data length
                               
        .net_protocol             (  net_protocol             ),//output reg [7:0]       net_protocol,                 //network layer protocol: 8'h11 udp  8'h01 icmp
        .ip_rec_source_addr       (  ip_rec_source_addr       ),//output reg [31:0]      ip_rec_source_addr,           //received source ip address
        .ip_rec_dest_addr         (  ip_rec_dest_addr         ),//output reg [31:0]      ip_rec_dest_addr,      //received destination ip address
                               
        .ip_rx_end                (  ip_rx_end                ),//output reg             ip_rx_end,
        .ip_checksum_error        (  ip_checksum_error        ) //output reg             ip_checksum_error
    ) ;

endmodule
