module gpio (
	input clk,
	input resetn,

	input  [31:0] gpio_data,
	input   [3:0] gpio_out_we,
	output [31:0] gpio_out_data,

	input   [3:0] gpio_in_we,
    input  [31:0] ex_data,
	output [31:0] gpio_in_data
);
//	reg [31:0] data;
//	assign gpio_out_data = data;
//
//	always @(posedge clk) begin
//		if (!resetn) begin
//			data <= 0;
//		end else begin
//			if (gpio_out_we[0]) data[ 7: 0] <= gpio_data[ 7: 0];
//			if (gpio_out_we[1]) data[15: 8] <= gpio_data[15: 8];
//			if (gpio_out_we[2]) data[23:16] <= gpio_data[23:16];
//			if (gpio_out_we[3]) data[31:24] <= gpio_data[31:24];
//		end
//	end

   assign gpio_out_data[ 7: 0] = (gpio_out_we[0]) ? gpio_data[ 7: 0] : gpio_out_data[ 7: 0];
   assign gpio_out_data[15: 8] = (gpio_out_we[1]) ? gpio_data[15: 8] : gpio_out_data[15: 8];
   assign gpio_out_data[23:16] = (gpio_out_we[2]) ? gpio_data[23:16] : gpio_out_data[23:16];
   assign gpio_out_data[31:24] = (gpio_out_we[3]) ? gpio_data[31:24] : gpio_out_data[31:24];

   assign gpio_in_data = (gpio_in_we == 4'b 1111) ? ex_data : 0;

endmodule
