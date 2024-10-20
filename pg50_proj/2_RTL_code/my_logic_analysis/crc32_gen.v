`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/01 15:38:32
// Design Name: 
// Module Name: crc32_gen
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

module crc32_gen(
	input         clk,
    input         rstn,
	input         crc32_init,       //crc校验值初始化信号
	input         crc32_en,         //crc校验使能信号
	input         crc_read, 
    input  [7:0]  data,	 
	output [7:0]  crc_out 
);

    reg [31:0]   crc_temp;
    
    assign crc_out = crc_read ? ~{crc_temp[24], crc_temp[25], crc_temp[26], crc_temp[27],
    	                          crc_temp[28], crc_temp[29], crc_temp[30], crc_temp[31]} : 8'h00;			  
        
    
    always@(posedge clk) 
    begin        
       if(!rstn)
    	    crc_temp <= 32'hffffffff;		  
       else if(crc32_init)
    	    crc_temp <= 32'hffffffff;
       else if(crc32_en)
    	  begin
    		 crc_temp[0]  <= crc_temp[24] ^ crc_temp[30] ^ data[1] ^ data[7];
    		 crc_temp[1]  <= crc_temp[25] ^ crc_temp[31] ^ data[0] ^ data[6] ^ crc_temp[24] ^ crc_temp[30] ^ data[1] ^ data[7];
    		 crc_temp[2]  <= crc_temp[26] ^ data[5]      ^ crc_temp[25] ^ crc_temp[31]^data[0] ^ data[6]^crc_temp[24]^crc_temp[30]^data[1]^data[7];
    		 crc_temp[3]  <= crc_temp[27] ^ data[4]      ^ crc_temp[26] ^ data[5]^crc_temp[25] ^ crc_temp[31]^data[0]^data[6];
    		 crc_temp[4]  <= crc_temp[28] ^ data[3]      ^ crc_temp[27] ^ data[4]^crc_temp[26] ^ data[5]^crc_temp[24]^crc_temp[30]^data[1]^data[7];
    		 crc_temp[5]  <= crc_temp[29] ^ data[2]      ^ crc_temp[28] ^ data[3]^crc_temp[27] ^ data[4]^crc_temp[25]^crc_temp[31]^data[0]^data[6]^crc_temp[24]^crc_temp[30]^data[1]^data[7];
    		 crc_temp[6]  <= crc_temp[30] ^ data[1]      ^ crc_temp[29] ^ data[2]^crc_temp[28] ^ data[3]^crc_temp[26]^data[5]^crc_temp[25]^crc_temp[31]^data[0]^data[6];
    		 crc_temp[7]  <= crc_temp[31] ^ data[0]      ^ crc_temp[29] ^ data[2]^crc_temp[27] ^ data[4]^crc_temp[26]^data[5]^crc_temp[24]^data[7];
    		 crc_temp[8]  <= crc_temp[ 0] ^ crc_temp[28] ^ data[3] ^crc_temp[27] ^ data[4] ^ crc_temp[25]^data[6]^crc_temp[24]^data[7];
    		 crc_temp[9]  <= crc_temp[ 1] ^ crc_temp[29] ^ data[2] ^crc_temp[28] ^ data[3] ^ crc_temp[26]^data[5]^crc_temp[25]^data[6];
    		 crc_temp[10] <= crc_temp[ 2] ^ crc_temp[29] ^ data[2] ^crc_temp[27] ^ data[4] ^ crc_temp[26]^data[5]^crc_temp[24]^data[7];
    		 crc_temp[11] <= crc_temp[ 3] ^ crc_temp[28] ^ data[3] ^crc_temp[27] ^ data[4] ^ crc_temp[25]^data[6]^crc_temp[24]^data[7];
    		 crc_temp[12] <= crc_temp[ 4] ^ crc_temp[29] ^ data[2] ^crc_temp[28] ^ data[3] ^ crc_temp[26]^data[5]^crc_temp[25]^data[6]^crc_temp[24]^crc_temp[30]^data[1]^data[7];
    		 crc_temp[13] <= crc_temp[ 5] ^ crc_temp[30] ^ data[1] ^crc_temp[29] ^ data[2] ^ crc_temp[27]^data[4]^crc_temp[26]^data[5]^crc_temp[25]^crc_temp[31]^data[0]^data[6];
    		 crc_temp[14] <= crc_temp[ 6] ^ crc_temp[31] ^ data[0] ^crc_temp[30] ^ data[1] ^ crc_temp[28]^data[3]^crc_temp[27]^data[4]^crc_temp[26]^data[5];
    		 crc_temp[15] <= crc_temp[ 7] ^ crc_temp[31] ^ data[0] ^crc_temp[29] ^ data[2] ^ crc_temp[28]^data[3]^crc_temp[27]^data[4];
    		 crc_temp[16] <= crc_temp[ 8] ^ crc_temp[29] ^ data[2] ^crc_temp[28] ^ data[3] ^ crc_temp[24]^data[7];
    		 crc_temp[17] <= crc_temp[ 9] ^ crc_temp[30] ^ data[1] ^crc_temp[29] ^ data[2] ^ crc_temp[25]^data[6];
    		 crc_temp[18] <= crc_temp[10] ^ crc_temp[31] ^ data[0] ^crc_temp[30] ^ data[1] ^ crc_temp[26]^data[5];
    		 crc_temp[19] <= crc_temp[11] ^ crc_temp[31] ^ data[0] ^crc_temp[27] ^ data[4];
    		 crc_temp[20] <= crc_temp[12] ^ crc_temp[28] ^ data[3];                    
    		 crc_temp[21] <= crc_temp[13] ^ crc_temp[29] ^ data[2];                    
    		 crc_temp[22] <= crc_temp[14] ^ crc_temp[24] ^ data[7];                    
    		 crc_temp[23] <= crc_temp[15] ^ crc_temp[25] ^ data[6] ^crc_temp[24] ^ crc_temp[30] ^ data[1] ^ data[7];
    		 crc_temp[24] <= crc_temp[16] ^ crc_temp[26] ^ data[5] ^crc_temp[25] ^ crc_temp[31] ^ data[0] ^ data[6];
    		 crc_temp[25] <= crc_temp[17] ^ crc_temp[27] ^ data[4] ^crc_temp[26] ^ data[5];
    		 crc_temp[26] <= crc_temp[18] ^ crc_temp[28] ^ data[3] ^crc_temp[27] ^ data[4] ^ crc_temp[24] ^ crc_temp[30]^data[1]^data[7];
    		 crc_temp[27] <= crc_temp[19] ^ crc_temp[29] ^ data[2] ^crc_temp[28] ^ data[3] ^ crc_temp[25] ^ crc_temp[31]^data[0]^data[6];
    		 crc_temp[28] <= crc_temp[20] ^ crc_temp[30] ^ data[1] ^crc_temp[29] ^ data[2] ^ crc_temp[26] ^ data[5];
    		 crc_temp[29] <= crc_temp[21] ^ crc_temp[31] ^ data[0] ^crc_temp[30] ^ data[1] ^ crc_temp[27] ^ data[4];
    		 crc_temp[30] <= crc_temp[22] ^ crc_temp[31] ^ data[0] ^crc_temp[28] ^ data[3];
    		 crc_temp[31] <= crc_temp[23] ^ crc_temp[29] ^ data[2];
    	  end
    	else if(crc_read)
    	    crc_temp <= {crc_temp[23:0], 8'hff};
    end
		 
endmodule
