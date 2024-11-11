// `timescale 1ns / 1ps
module clk_div (
	input clk, 
	input rst_n, 
	input bps_start, 
    input [3:0] sample_clk_cfg, //baudrates config.
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
reg [31:0] bps_para; 
always @(*) begin
	bps_para = 'd0;
	case (sample_clk_cfg)
		4'h0: begin
			bps_para = 'd9999;	///20K
		end
		4'h1: begin
			bps_para = 'd3999;	//50K
		end
		4'h2: begin
			bps_para = 'd1999;	//100K
		end
		4'h3: begin
			bps_para = 'd999;	//200K
		end
		4'h4: begin				//500K
			bps_para = 'd399;
		end
		4'h5: begin				//1M
			bps_para = 'd199;
		end
		4'h6: begin				//2M
			bps_para = 'd99;
		end
		4'h7: begin				//5M
			bps_para = 'd39;
		end
		4'h8: begin				//10M
			bps_para = 'd19;
		end
		4'h9: begin				//20M
			bps_para = 'd9;
		end
		4'ha: begin				//50M
			bps_para = 'd3;
		end
		4'hb: begin				//100M
			bps_para = 'd1;
		end
		4'hc: begin				//200M
			bps_para = 'd0;
		end
		4'hd: begin
			bps_para = 'd0;
		end
		default : begin
			bps_para = 'd0;
		end
	endcase
end

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


