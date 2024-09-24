module MY_UART_TOP (
   clk            ,
   rst_n          ,
   rs232_rx       ,
   rs232_tx       ,
   uart_ctrl_tx   ,  //baudrates config value.default,13'd433
   uart_ctrl_rx   ,  //baudrates config value.13'd433
   tx_start       ,
   tx_data        ,
   tx_done        ,
   rx_int         ,
   rx_data        
);

input          clk           ;
input          rst_n         ;
input          rs232_rx      ;
output         rs232_tx      ;
input  [12:0]  uart_ctrl_tx  ;  //baudrates config value.default,13'd433
input  [12:0]  uart_ctrl_rx  ;  //baudrates config value.13'd433
input          tx_start      ;
input  [7:0]   tx_data       ;
output         tx_done       ;
output         rx_int        ;
output [7:0]   rx_data       ;

wire bps_start_tx;
wire bps_start_rx;
wire clk_bps_tx;
wire clk_bps_rx;



// wire [7:0]address;
// wire [7:0]data_in;
// wire wren;
// wire [7:0]data_out;


speed_select 
//#(
//	.UART_CTRL(UART_CTRL)
//) 
u_select_tx (
   .clk(clk),
   .rst_n(rst_n),
   .bps_start(bps_start_tx),
   .uart_ctrl(uart_ctrl_tx),
   .clk_bps(clk_bps_tx)
);

speed_select 
//#(
//	.UART_CTRL(UART_CTRL)
//) 
u_select_rx (
   .clk(clk),
   .rst_n(rst_n),
   .bps_start(bps_start_rx),
   .uart_ctrl(uart_ctrl_rx),
   .clk_bps(clk_bps_rx)
);

my_uart_rx u_rx(
   .clk(clk),
   .rst_n(rst_n),
   .rs232_rx(rs232_rx),
   .clk_bps(clk_bps_rx),
   .bps_start(bps_start_rx),
   .rx_data(rx_data),
   .rx_done(rx_int)
);

my_uart_tx u_tx(
   .clk(clk),
   .rst_n(rst_n),
   .clk_bps(clk_bps_tx),
   .tx_data(tx_data),
   .tx_start(tx_start),

   .rs232_tx(rs232_tx),
   .bps_start(bps_start_tx),
   .tx_done(tx_done)
);

endmodule

