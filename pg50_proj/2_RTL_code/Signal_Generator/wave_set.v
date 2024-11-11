module wave_set(
	input				clk		,
	input				rst_n	,
	input				key0_in	,//

	output	reg	[2:0]	wave_c		//wave_c oo~ÕıÏÒ²¨  01~Èı½Ç²¨  10~¾â³İ²¨  11~·½²¨
	);

	wire	key_flag	;
	wire	key_state	;

	key_filter wave_key (
			.clk       (clk),
			.rst_n     (rst_n),
			.key_in    (key0_in),
			.key_flag  (key_flag),
			.key_state (key_state)
		);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			wave_c <=3'd0; //Ä¬ÈÏÕıÏÒ²¨
		end
		else if (key_flag) begin
			wave_c <= wave_c + 1'b1;
		end
	end
endmodule