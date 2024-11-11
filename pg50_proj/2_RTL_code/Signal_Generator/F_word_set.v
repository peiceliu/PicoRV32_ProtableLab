module F_word_set(
	input				clk		,
	input				rst_n	,
	input				key1_in	,

	output	reg	[31:0]	f_word	
	);
	
	wire		key_flag	;
	wire		key_state	;
	reg	[3:0]	cnt			;

	key_filter fword_key (
			.clk       (clk),
			.rst_n     (rst_n),
			.key_in    (key1_in),
			.key_flag  (key_flag),
			.key_state (key_state)
		);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			cnt <= 4'd0;
		end
		else if (key_flag) begin
			if (cnt==4'd15) begin
				cnt <= 4'd0;
			end
			else begin
				cnt <= cnt + 1'b1;
			end
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			f_word <= 343597;
		end
		else begin
			case(cnt)
				4'd0:f_word <= 3435974;	    //10Hz
				4'd1:f_word <= 1718;	//50Hz
				4'd2:f_word <= 3436;	//100Hz
				4'd3:f_word <= 17180;	//500Hz
				4'd4:f_word <= 34360;	//1KHz
				4'd5:f_word <= 171799;	//5KHz
				4'd6:f_word <= 343597;	//10KHz
				4'd7:f_word <= 1717987;	//50KHz
				4'd8:f_word <= 3435974;	//100KH
				4'd9:f_word <= 17179869;	//500KH
				4'd10:f_word<= 34359738;	//1MHz
				4'd11:f_word<= 68719477;	//2MHz  
                4'd12:f_word<= 103079215;	//3MHz
                4'd13:f_word<= 137438953;	//4MHz
                4'd14:f_word<= 171798692;	//5MHz
                4'd15:f_word<= 343597384;	//10MHz
                 default:f_word <= 34360;	//1KHz;      
			endcase            
		end                    
	end                        
endmodule                      
