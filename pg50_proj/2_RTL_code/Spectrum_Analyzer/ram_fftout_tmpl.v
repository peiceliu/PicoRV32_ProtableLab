// Created by IP Generator (Version 2022.2-SP1-Lite build 132640)
// Instantiation Template
//
// Insert the following codes into your Verilog file.
//   * Change the_instance_name to your own instance name.
//   * Change the signal names in the port associations


ram_fftout u_ram_fftout (
  .wr_data(wr_data),        // input [11:0]
  .wr_addr(wr_addr),        // input [7:0]
  .wr_en(wr_en),            // input
  .wr_clk(wr_clk),          // input
  .wr_rst(wr_rst),          // input
  .rd_addr(rd_addr),        // input [7:0]
  .rd_data(rd_data),        // output [11:0]
  .rd_clk(rd_clk),          // input
  .rd_clk_en(rd_clk_en),    // input
  .rd_rst(rd_rst)           // input
);
