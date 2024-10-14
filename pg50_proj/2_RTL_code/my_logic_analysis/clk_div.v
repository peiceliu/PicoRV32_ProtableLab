// `timescale 1ns / 1ps
module clk_div (
	input clk, 
	input rst_n, 
	input bps_start, 
    input [31:0] uart_ctrl, //baudrates config.
	output reg clk_bps   
);

// localparam bps9600   = 13'd5207,    //9600bps
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
wire [31:0] bps_para = uart_ctrl; 
reg[31:0] cnt;        
//reg clk_bps_r;       
localparam DLY = 0;

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
    	clk_bps <= #DLY 1'b0;
	end else begin
		if (~bps_start) begin 
			clk_bps <= #DLY 1'b0;
		end else if ((cnt == bps_para) && bps_start) begin
		    clk_bps <= #DLY 'd1;
		end else begin
			clk_bps <= #DLY 1'b0;
		end
	end
end


endmodule


