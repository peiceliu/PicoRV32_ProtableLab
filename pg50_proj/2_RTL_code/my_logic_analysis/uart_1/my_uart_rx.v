module my_uart_rx#(
    parameter DLY = 0
  )(
	input clk, // 50MHz
	input rst_n,  
	input rs232_rx,   
	input clk_bps,    
	output reg bps_start, 
	output[7:0] rx_data, 
	output reg rx_done
);    // 
//----------------------------------------------------------------
reg rs232_rx0,rs232_rx1,rs232_rx2; 
wire neg_rs232_rx;   

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
           {rs232_rx2,rs232_rx1,rs232_rx0} <= 3'b111;
    end else begin
           {rs232_rx2,rs232_rx1,rs232_rx0} <= #DLY {rs232_rx1,rs232_rx0,rs232_rx};
    end
end

assign neg_rs232_rx = rs232_rx2 & ~rs232_rx1; 

//----------------------------------------------------------------
//reg bps_start_r;
reg [3:0]num;   
reg rx_int;
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        bps_start <= 1'b0;
        rx_int <= 1'b0;
        rx_done <= 1'b0;
    end else if(neg_rs232_rx) begin
        bps_start <= #DLY 1'b1; 
        rx_int <= #DLY 1'b1;   
        rx_done <= #DLY 1'b0;
    end else if(num == 4'd10) begin
        bps_start <= #DLY 1'b0; 
        rx_int <= #DLY 1'b0;      
        rx_done <= #DLY 1'b1;
    end else begin
        rx_done <= #DLY 1'b0;
    end
end

//----------------------------------------------------------------
reg[7:0] rx_data_r;  
//----------------------------------------------------------------

reg[7:0]   rx_temp_data; 
reg rx_data_shift;   

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
           rx_data_shift <= 1'b0;
           rx_temp_data <= 8'd0;
           num <= 4'd0;
           rx_data_r <= 8'd0;
    end else if(rx_int) begin    
        if(clk_bps) begin 
            rx_data_shift <= #DLY 1'b1;
            num <= #DLY num + 1'b1;
            if(num <= 4'd8) begin
            	rx_temp_data[7] <= #DLY rs232_rx;    
            end
        end else if(rx_data_shift) begin    
            rx_data_shift <= #DLY 1'b0;
            if(num <= 4'd8) begin
            	rx_temp_data <= #DLY rx_temp_data >> 1'b1;  
            end else if(num == 4'd10) begin
                num <= #DLY 4'd0;  
                rx_data_r <= #DLY rx_temp_data;  
            end
        end
    end
end

assign rx_data = rx_data_r;

endmodule

