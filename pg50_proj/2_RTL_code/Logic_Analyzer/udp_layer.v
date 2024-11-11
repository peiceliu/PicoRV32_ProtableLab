`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/16 23:31:11
// Design Name: 
// Module Name: udp_layer
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


module udp_layer #(
    parameter LOCAL_PORT_NUM = 16'hf000    //源端口号
) (
    input              udp_send_clk,      //时钟信号                                                                                                                                                                                                                                                                                                                                                                
    input              rstn,              //复位信号，低电平有效                                                                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                                                                                                                    
    //from software app                                                                                                                                                                                                                                                                                                                                                                                             
    input              app_data_in_valid, //本模块从外部所接收的数据输出有效信号，高电平有效                                                                                                                                                                                                                                                                                                                        
    input      [7:0]   app_data_in,       //本模块从外部所接收的数据输出                                                                                                                                                                                                                                                                                                                                            
    input      [15:0]  app_data_length,   //本模块从外部所接收的当前数据包的长度（不含udp、ip、mac 首部），单位：字节                                                                                                                                                                                                                                                                                               
    input      [15:0]  udp_dest_port,     //本模块从外部所接收的数据包的源端口号                                                                                                                                                                                                                                                                                                                                    
    input              app_data_request,  //用户接口数据发送请求，高电平有效                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                    
    output             udp_send_ready,    //握手是基于 ready、request、ack三个信号来实现的                                                                                                                                                                                                                                                                                                                          
    output             udp_send_ack,      //握手是基于 ready、request、ack三个信号来实现的                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                                                    
    input              ip_send_ready,     //握手是基于 ready、request、ack三个信号来实现的                                                                                                                                                                                                                                                                                                                          
    input              ip_send_ack,       //握手是基于 ready、request、ack三个信号来实现的                                                                                                                                                                                                                                                                                                                          
    //to IP_send                                                                                                                                                                                                                                                                                                                                                                                                    
    output             udp_send_request,  //用户接口数据发送请求，高电平有效                                                                                                                                                                                                                                                                                                                                        
    output             udp_data_out_valid,//发送的数据输出有效信号，高电平有效                                                                                                                                                                                                                                                                                                                                      
    output     [7:0]   udp_data_out,      //发送的数据输出                                                                                                                                                                                                                                                                                                                                                          
    output     [15:0]  udp_packet_length, //当前数据包的长度（不含udp、ip、mac 首部），单位：字节  
    
    input      [7:0]   udp_rx_data,
    input              udp_rx_req,
    
    input              ip_checksum_error,
    input              ip_addr_check_error,
    
    output     [7:0]   udp_rec_rdata ,      //udp ram read data
    output     [15:0]  udp_rec_data_length, //udp data length
    output             udp_rec_data_valid   //udp data valid
);
    
    udp_tx #(
        .LOCAL_PORT_NUM        (  LOCAL_PORT_NUM      ) //parameter LOCAL_PORT_NUM = 16'hf000    //源端口号
    ) udp_tx(
        .udp_send_clk          (  udp_send_clk        ),//input wire         udp_send_clk,      //时钟信号                                                                                                                                                                                                                                                                                                                                                                
        .rstn                  (  rstn                ),//input wire         rstn,              //复位信号，低电平有效                                                                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                                                                                                                                                           
        //from software app                                                                                                                                                                                                                                                                                                                                                                                             
        .app_data_in_valid     (  app_data_in_valid   ),//input wire         app_data_in_valid, //本模块从外部所接收的数据输出有效信号，高电平有效                                                                                                                                                                                                                                                                                                                        
        .app_data_in           (  app_data_in         ),//input wire [7:0]   app_data_in,       //本模块从外部所接收的数据输出                                                                                                                                                                                                                                                                                                                                            
        .app_data_length       (  app_data_length     ),//input wire [15:0]  app_data_length,   //本模块从外部所接收的当前数据包的长度（不含udp、ip、mac 首部），单位：字节                                                                                                                                                                                                                                                                                               
        .udp_dest_port         (  udp_dest_port       ),//input wire [15:0]  udp_dest_port,     //本模块从外部所接收的数据包的源端口号                                                                                                                                                                                                                                                                                                                                    
        .app_data_request      (  app_data_request    ),//input wire         app_data_request,  //用户接口数据发送请求，高电平有效                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                                                                          
        .udp_send_ready        (  udp_send_ready      ),//output wire        udp_send_ready,    //握手是基于 ready、request、ack三个信号来实现的                                                                                                                                                                                                                                                                                                                          
        .udp_send_ack          (  udp_send_ack        ),//output wire        udp_send_ack,      //握手是基于 ready、request、ack三个信号来实现的                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                                                                                           
        .ip_send_ready         (  ip_send_ready       ),//input wire         ip_send_ready,     //握手是基于 ready、request、ack三个信号来实现的                                                                                                                                                                                                                                                                                                                          
        .ip_send_ack           (  ip_send_ack         ),//input wire         ip_send_ack,       //握手是基于 ready、request、ack三个信号来实现的                                                                                                                                                                                                                                                                                                                          
        //to IP_send                                                                                                                                                                                                                                                                                                                                                                                                    
        .udp_send_request      (  udp_send_request    ),//output wire        udp_send_request,  //用户接口数据发送请求，高电平有效                                                                                                                                                                                                                                                                                                                                        
        .udp_data_out_valid    (  udp_data_out_valid  ),//output reg         udp_data_out_valid,//发送的数据输出有效信号，高电平有效                                                                                                                                                                                                                                                                                                                                      
        .udp_data_out          (  udp_data_out        ),//output reg [7:0]   udp_data_out,      //发送的数据输出                                                                                                                                                                                                                                                                                                                                                          
        .udp_packet_length     (  udp_packet_length   ) //output reg [15:0]  udp_packet_length  //当前数据包的长度（不含udp、ip、mac 首部），单位：字节                                                                                                                                                                                                                                                                                                                   
    );
    
    udp_rx #(
        .LOCAL_PORT            (  LOCAL_PORT_NUM      ) //parameter LOCAL_PORT = 16'hf000    //源端口号
    )udp_rx (
        .clk                   (  udp_send_clk        ),//input                  clk,   
        .rstn                  (  rstn                ),//input                  rstn,  
                                                      
        .udp_rx_data           (  udp_rx_data         ),//input      [7:0]       udp_rx_data,
        .udp_rx_req            (  udp_rx_req          ),//input                  udp_rx_req,
                                                      
        .ip_checksum_error     (  ip_checksum_error   ),//input                  ip_checksum_error,
        .ip_addr_check_error   (  ip_addr_check_error ),//input                  ip_addr_check_error,
                                                      
        .udp_rec_rdata         (  udp_rec_rdata       ),//output     [7:0]       udp_rec_rdata ,      //udp ram read data
        .udp_rec_data_length   (  udp_rec_data_length ),//output reg [15:0]      udp_rec_data_length,     //udp data length
        .udp_rec_data_valid    (  udp_rec_data_valid  ) //output reg             udp_rec_data_valid       //udp data valid
    );
    
endmodule
