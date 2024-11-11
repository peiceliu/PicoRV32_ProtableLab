module amplitude_set(
	input				clk		,
	input				rst_n	,
	input				key2_in	,

	output	reg	[4:0]	amplitude	
	);

	reg	[3:0]	cnt			;
	wire		key_flag	;
	wire		key_state	;


	key_filter amplitude_key (
				.clk       (clk),
				.rst_n     (rst_n),
				.key_in    (key2_in),
				.key_flag  (key_flag),
				.key_state (key_state)
			);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			cnt <= 4'd0;
		end
		else if (key_flag) begin
			if (cnt == 4'd8) begin
				cnt <= 4'd0;
			end
			else begin
				cnt <= cnt + 1'b1;
			end
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			amplitude <= 0;			
		end
		else begin
			case(cnt)
				4'd0: amplitude <= 5'd1;
				4'd1: amplitude <= 5'd2;
				4'd2: amplitude <= 5'd3;
				4'd3: amplitude <= 5'd4;
				4'd4: amplitude <= 5'd5;
                4'd5: amplitude <= 5'd6;
				4'd6: amplitude <= 5'd7;
				4'd7: amplitude <= 5'd8;
				4'd8: amplitude <= 5'd9;
				default:amplitude <= 5'd1;
			endcase
		end
	end
endmodule
