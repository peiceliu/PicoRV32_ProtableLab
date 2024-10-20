`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/01 22:01:53
// Design Name: 
// Module Name: arp_cache
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

module arp_cache(
    input                clk ,
    input                rst_n ,
    
    input                arp_found,
    input      [31:0]    arp_rec_source_ip_addr,
    input      [47:0]    arp_rec_source_mac_addr,
               
    input      [31:0]    dest_ip_addr,
    output reg [47:0]    dest_mac_addr,
    
    output reg           mac_not_exist
) ;
           
    reg [79:0]  arp_cache ;
    
    //init arp cache
    always @(posedge clk or negedge rst_n)
    begin
        if (~rst_n)
            arp_cache  <= 80'h00_00_00_00_ff_ff_ff_ff_ff_ff ;
        else if (arp_found)
            arp_cache  <= {arp_rec_source_ip_addr, arp_rec_source_mac_addr} ;
        else
            arp_cache  <= arp_cache ;
    end
      
    always @(posedge clk or negedge rst_n)
    begin
        if (~rst_n)
            dest_mac_addr  <= 48'hff_ff_ff_ff_ff_ff ;
        else if (dest_ip_addr == arp_cache[79:48])
            dest_mac_addr  <= arp_cache[47:0] ;
        else
            dest_mac_addr  <= 48'hff_ff_ff_ff_ff_ff ;
    end
      
    always @(posedge clk or negedge rst_n)
    begin
        if (~rst_n)
            mac_not_exist  <= 1'b0 ;
        else if (dest_ip_addr != arp_cache[79:48])
            mac_not_exist  <= 1'b1 ;
        else if (dest_ip_addr == arp_cache[79:48] && arp_cache[47:0] == 48'hff_ff_ff_ff_ff_ff)
            mac_not_exist  <= 1'b1 ;
        else
            mac_not_exist  <= 1'b0 ;
    end
  
endmodule
