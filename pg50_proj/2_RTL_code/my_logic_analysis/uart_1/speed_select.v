
`timescale 1ns / 1ps
module speed_select #(
    parameter DLY = 0
  )(
	input clk, 
	input rst_n, 
	input bps_start, 
    input [12:0] uart_ctrl, //baudrates config.
	output reg clk_bps   
);

// localparam bps9600    = 13'd5207,    //9600bps
//           bps19200   = 13'd2603,    //19200bps
//           bps38400   = 13'd1301,    //38400bps
//           bps57600   = 13'd867,     //57600bps
//           bps115200  = 13'd433;     //115200bps

// localparam bps9600_2   = 13'd2603,
//           bps19200_2  = 13'd1301,
//           bps38400_2  = 13'd650,
//           bps57600_2  = 13'd433,
//           bps115200_2 = 13'd216;

//wire [12:0] bps_para = (UART_CTRL);  
wire [12:0] bps_para = uart_ctrl;  
//wire [12:0] bps_para_2 = (UART_CTRL - 1) >> 1;    
wire [12:0] bps_para_2 = (uart_ctrl - 1) >> 1;    
reg[12:0] cnt;          
//reg clk_bps_r;       

//----------------------------------------------------------
//reg[2:0] uart_ctrl; 
//----------------------------------------------------------
// generate
// 	case (UART_CTRL)
// 		3'd0:begin
//             assign bps_para = bps9600;
//             assign bps_para_2 = bps9600_2;
//         end
//         3'd1:begin
//             assign bps_para = bps19200;
//             assign bps_para_2 = bps19200_2;
//         end
//         3'd2:begin
//              assign bps_para = bps38400;
//              assign bps_para_2 = bps38400_2;
//         end
//         3'd3:begin
//             assign bps_para = bps57600;
//             assign bps_para_2 = bps57600_2;
//         end
//         3'd4:begin
//             assign bps_para = bps115200;
//             assign bps_para_2 = bps115200_2;
//         end
//         default:begin
//         	assign bps_para = bps9600;
//             assign bps_para_2 = bps9600_2;
//         end
// 	endcase
// endgenerate

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
    	cnt <= 'b0;
 	end else if((cnt < bps_para) && bps_start) begin
 		cnt <= #DLY cnt + 1'b1;
    end else begin
    	cnt <= #DLY 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
    	clk_bps <= 1'b0;
    end else if((cnt == bps_para_2) && bps_start) begin
    	clk_bps <= #DLY 1'b1; 
    end else begin
	    clk_bps <= #DLY 1'b0;
	end
end

endmodule


