`timescale 1ns / 1ps

module tb_logic_analysis();

    parameter T = 20;
    reg clk;
    reg rst_n;
    reg rxd;
    reg txd;
    reg txd_debug;
    reg [1:0] din;
    reg config_valid;
    reg [7:0] tx_data;
    wire tx_done;
    wire rx_done;
    wire [7:0] rx_data;
    reg  rx_start;
    reg  [1:0] check;
    wire [1:0] err;
    reg fifo_data_full  ;
    reg fifo_data_alfull;
    reg  [7:0] config_in;
    reg tx_start            ;
    reg [1:0] cnt ;
    reg  [7:0] dout;
    reg fifo_wen;
    reg ren;
    reg [7:0] dout_r;
    reg fifo_wen_r;
    reg   clk_valid   ;
    reg dout_r_valid ;
    wire               GRS_N;

    integer i;
    integer j;
    integer file;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        check = 2'b00;
        din = 'd0;
        config_valid = 'd0;
        config_in = 8'b00010000;
        dout_r_valid = 'd0;
        rx_start = 'd1;
        i = 0;
        j = 0;
        fifo_data_full   = 'd0;
        fifo_data_alfull = 'd0;
        #T
        rst_n = 1'b1;
        config_valid = 1'b1;
        din[0] = txd_debug;
        #T 
        config_in = 8'b00010001;
        #T 
        config_valid = 'd0;
        #4000
        uart_send_byte(33);
        uart_send_byte(55);
        uart_send_byte(33);
        uart_send_byte(56);
        uart_send_byte(38);
        uart_send_byte(45);
        #T
        config_in = 8'd0;
        config_valid = 'd1;
        #T
        config_valid = 'd0;
        uart_send_byte(33);
        uart_send_byte(55);
        uart_send_byte(33);
        uart_send_byte(56);
        uart_send_byte(38);
        uart_send_byte(45);

    end

    always #10 clk = ~clk;

    always @(posedge clk) begin
        wait (my_logic_analysis_1.clk_negedge == 1'b1);
        #6000;
        dout_r_valid = 'd1;
        #20
        dout_r_valid = 'd0;
    end

    // always @(posedge clk or negedge rst_n) begin
    //     if(rst_n == 1'b0) begin
    //         cnt <= 'd0;
    //     end else begin
    //         if (my_logic_analysis_1.clk_negedge && cnt == 'd3) begin
    //             cnt <= 'd0;
    //         end else if (my_logic_analysis_1.clk_negedge) begin
    //             cnt <= cnt + 1;
    //         end
    //     end
    // end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            dout_r <= 'b11111111;
        end else begin
            if (fifo_wen) begin
                dout_r <= dout;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            rxd <= 'd1;
        end else begin
            if (dout_r_valid) begin
                rxd = dout_r[0];
            end 
        end
    end

    GTP_GRS GRS_INST(
        .GRS_N(1'b1)
    );


    my_logic_analysis my_logic_analysis_1 (
        .clk                (clk             )  ,
        .rst_n              (rst_n           )  ,
        .config_valid       (config_valid    )  ,
        .config_in          (config_in       )  ,
        .din                ({5'b0,txd_debug})  ,
        .dout               (dout            )  ,
        .fifo_wen           (fifo_wen        )  ,
        .fifo_data_full     (fifo_data_full  )  ,
        .fifo_data_alfull   (fifo_data_alfull)  
    );
    

MY_UART_TOP u_uart_debug(
    .clk            (clk            )   , 
    .rst_n          (rst_n          )   , 
    .rs232_rx       (rxd            )   , 
    .rs232_tx       (txd_debug      )   , 
    .uart_ctrl_tx   (13'd5207       )   , 
    .uart_ctrl_rx   (13'd5207       )   , 
    .tx_start       (tx_start       )   , 
    .tx_data        (tx_data        )   , 
    .tx_done        (tx_done        )   , 
    .rx_int         (rx_done        )   , 
    .rx_data        (rx_data        )   
);
//------------------------------------------------------------------------
    // initial begin
    //     #10000000 ;
    //     $finish();
    // end

    // string dump_file;
    // initial begin
    //     if($value$plusargs("FSDB=%s",dump_file))
    //     $display("dump_file = %s",dump_file);
    //     $fsdbDumpfile(dump_file);
    //     $fsdbDumpvars(0, tb_logic_analysis);
    //     $fsdbDumpMDA();
    // end
//------------------------------------------------------------------------


task uart_send_byte(input [7:0] data);
    @(posedge clk);
    tx_data  = data;
    #10
    tx_start = #1 1'b1;
    @(posedge clk);
    tx_start = #1 1'b0;
    wait (tx_done == 1'b1);
endtask
endmodule