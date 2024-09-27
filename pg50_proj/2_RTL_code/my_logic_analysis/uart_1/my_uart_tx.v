`timescale 1ns / 1ps
module my_uart_tx #(
    parameter DLY = 0
  )(
	input clk,    
	input rst_n,  
	input clk_bps,  
	input [7:0]tx_data,
	input tx_start,    

	output reg rs232_tx, 
	output reg bps_start,
	output reg tx_done
);
//---------------------------------------------------------
reg[7:0] tx_data_lock; 
//---------------------------------------------------------
reg tx_en; 
reg[3:0] num;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
       {bps_start,tx_en,tx_done,tx_data_lock} <= 'b0;
    end else if(tx_start) begin   
       bps_start <= #DLY 1'b1;
       tx_data_lock <= #DLY tx_data;  
       tx_en <= #DLY 1'b1;       
       tx_done <= #DLY 'b0;
    end else if(num == 4'd11) begin 
       bps_start <= #DLY 'b0;
       tx_en <= #DLY 'b0;
       tx_done <= #DLY 1'b1;
    end else begin
      tx_done <= #DLY 'd0;
    end 
end

//---------------------------------------------------------
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        num <= 4'd0;
        rs232_tx <= 1'b1;
    end else if(tx_en) begin
        if(clk_bps) begin
            num <= #DLY num + 1'b1;
            case (num)
               4'd0:  rs232_tx <= #DLY 1'b0; 
               4'd1:  rs232_tx <= #DLY tx_data_lock[0]; 
               4'd2:  rs232_tx <= #DLY tx_data_lock[1]; 
               4'd3:  rs232_tx <= #DLY tx_data_lock[2]; 
               4'd4:  rs232_tx <= #DLY tx_data_lock[3]; 
               4'd5:  rs232_tx <= #DLY tx_data_lock[4]; 
               4'd6:  rs232_tx <= #DLY tx_data_lock[5]; 
               4'd7:  rs232_tx <= #DLY tx_data_lock[6]; 
               4'd8:  rs232_tx <= #DLY tx_data_lock[7]; 
               4'd9:  rs232_tx <= #DLY 1'b0;   
               default: rs232_tx <= #DLY 1'b1;
            endcase
        end else if(num == 4'd11) begin
        	num <= #DLY 4'd0;   
        end
    end
end

endmodule


