`timescale 1 ps / 1 ps

module tb_logic_analysis();
`include "../../example_design/bench/mem/ddr3_parameters.vh"

localparam TIME_RST_N  = 64'd200000000;

parameter MEM_ADDR_WIDTH = 15;
parameter MEM_BADDR_WIDTH = 3;
parameter MEM_DQ_WIDTH = 16;
parameter MEM_DM_WIDTH         = MEM_DQ_WIDTH/8;
parameter MEM_DQS_WIDTH        = MEM_DQ_WIDTH/8;
parameter MEM_NUM              = MEM_DQ_WIDTH/16;
parameter real CLKIN_FREQ  = 50;
parameter T = 1000000 / CLKIN_FREQ;

    reg clk;
    reg rst_n;
    reg rxd;
    reg txd_debug;
    reg [5:0] din;
    reg config_valid;
    reg [7:0] tx_data;
    wire tx_done;
    wire rx_done;
    wire [7:0] rx_data;
    reg  rx_start;
    reg tx_start            ;
    reg  [7:0] dout;
    wire  GRS_N;
    reg [31:0]      sample_num   ;
    reg [3:0]       sample_clk_cfg  ;
    reg [1:0]       triger_type ;
    reg [2:0]       trigger_channel ;
    reg             sample_run   ;
    reg             ddr_init_done   ;
    reg             fifo_ren_net        ;
    reg             fifo_rdata_net      ;
    reg             fifo_empty_net      ;
    reg             almost_empty        ;
    reg             ethernet_read_done  ;
    wire                          mem_rst_n        ; 
    wire                          mem_ck           ;
    wire                          mem_ck_n         ;
    wire                          mem_cke          ;
    wire                          mem_cs_n         ;
    wire                          mem_ras_n        ;
    wire                          mem_cas_n        ;
    wire                          mem_we_n         ;
    wire                          mem_odt          ;
    wire [ MEM_ADDR_WIDTH-1:0]    mem_a            ;  
    wire [MEM_BADDR_WIDTH-1:0]    mem_ba           ;  
    wire [  MEM_DQS_WIDTH-1:0]    mem_dqs          ;  
    wire [  MEM_DQS_WIDTH-1:0]    mem_dqs_n        ;  
    wire [   MEM_DQ_WIDTH-1:0]    mem_dq           ;  
    wire [   MEM_DM_WIDTH-1:0]    mem_dm           ;
    wire [      ADDR_BITS-1:0]    mem_addr         ; 

    integer i;
    integer j;
    integer file;
    integer file1;



    initial begin
        din = 'd0;
        sample_clk_cfg = 'h0;
        trigger_channel = 'd0;
        file = $fopen("./input.txt","w");
        file1 = $fopen("./output.txt","w");
        sample_num = 32'h40000000;
        ethernet_read_done = 'd1;
        i = 0;
        j = 0;
        triger_type = 'b11;
        #T
        rst_n = 1'b1;
        wait (ddr_init_done == 'd1);
        #T
        sample_run       = 'd1;
        #T
        sample_run  = 'd0;
        ethernet_read_done = 'd0;
        for (i=0; i<=32; i=i+1) begin
            uart_send_byte(33);
            uart_send_byte(55);
            uart_send_byte(33);
            uart_send_byte(56);
            uart_send_byte(38);
            uart_send_byte(45);
        end
    end

    initial begin
        while (1) begin
            @(posedge u_ddr3.clk_ip)
            if (axi_rvalid) begin
                $fwrite(file1, "%h\n", axi_rdata);
            end
            if (u_ddr3.axi_wready) begin
                $fwrite(file, "%h\n", u_ddr3.axi_wdata);
            end
            if (u_ddr3.dout_done) begin
                break;
            end
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rxd <= 'd1;
        end else begin
            if (u_ddr3.u_my_logic_analysis.clk_bps) begin
                rxd <= u_ddr3.dout[0];
            end
        end
    end

        

/********************clk and init******************/

always #(T / 2)  clk = ~clk;

initial begin
rst_n = 1'b0;
clk = 0;
#200
//default input from keyboard
rst_n = 1'b1;
end


reg grs_n ;
GTP_GRS GRS_INST(
		.GRS_N (grs_n)
	);


initial begin
grs_n = 1'b0;
#5000 grs_n = 1'b1;
end


/************************** ddr3 ************************************/
reg  [MEM_NUM:0]              mem_ck_dly;
reg  [MEM_NUM:0]              mem_ck_n_dly;

always @ (*)
begin
    mem_ck_dly[0]   <=  mem_ck;
    mem_ck_n_dly[0] <=  mem_ck_n;
end

assign mem_addr = {{(ADDR_BITS-MEM_ADDR_WIDTH){1'b0}},{mem_a}};

genvar gen_mem;                                                    
generate                                                         
for(gen_mem=0; gen_mem<MEM_NUM; gen_mem=gen_mem+1) begin   : i_mem 
    
    always @ (*)
    begin
        mem_ck_dly[gen_mem+1] <= #50 mem_ck_dly[gen_mem];
        mem_ck_n_dly[gen_mem+1] <= #50 mem_ck_n_dly[gen_mem];
    end

    ddr3      mem_core (
    
    .rst_n             (mem_rst_n                        ),
    .ck                (mem_ck_dly[gen_mem+1]            ),
    .ck_n              (mem_ck_n_dly[gen_mem+1]          ),

    .cs_n              (mem_cs_n                         ),

    .addr              (mem_addr                         ),
    .dq                (mem_dq[16*gen_mem+15:16*gen_mem] ),
    .dqs               (mem_dqs[2*gen_mem+1:2*gen_mem]   ),
    .dqs_n             (mem_dqs_n[2*gen_mem+1:2*gen_mem] ),
    .dm_tdqs           (mem_dm[2*gen_mem+1:2*gen_mem]    ),
    .tdqs_n            (                                 ),
    .cke               (mem_cke                          ),
    .odt               (mem_odt                          ),
    .ras_n             (mem_ras_n                        ),
    .cas_n             (mem_cas_n                        ),
    .we_n              (mem_we_n                         ),
    .ba                (mem_ba                           )
    );
end     
endgenerate

my_logic_analysis_top #(
    .DFI_CLK_PERIOD     (10000      )       ,    
    .MEM_ROW_WIDTH      (15         )       ,    
    .MEM_COLUMN_WIDTH   (10         )       , 
    .MEM_BANK_WIDTH     (3          )       ,    
    .MEM_DQ_WIDTH       (8          )       ,   
    .MEM_DM_WIDTH       (1          )       ,   
    .MEM_DQS_WIDTH      (1          )       ,   
    .REGION_NUM         (3          )       ,   
    .CTRL_ADDR_WIDTH    (28         )       ,
    .INPUT_WIDTH        (6          )       ,
    .MEM_SPACE_AW       (18         )       
) u_my_logic_analysis_top (
    .clk                (clk                )       ,
    .clk_net            (clk                )       ,
    .in_rst_n           (rst_n              )       ,
    .sample_clk_cfg     (sample_clk_cfg     )       ,
    .sample_num         (sample_num         )       ,  
    .triger_type        (triger_type        )       , 
    .trigger_channel    (trigger_channel    )       ,
    .sample_run         (sample_run         )       , 
    .din                ({5'd0,txd_debug}   )       ,
    .ddr_init_done      (ddr_init_done      )       ,
    .axi_rdata          (axi_rdata          )       ,
    .axi_rvalid         (axi_rvalid         )       ,

    .fifo_ren_net       (fifo_ren_net       )       ,
    .fifo_rdata_net     (fifo_rdata_net     )       ,
    .fifo_empty_net     (fifo_empty_net     )       ,
    .almost_empty       (almost_empty       )       ,
    .ethernet_read_done (ethernet_read_done )       ,

    .mem_rst_n          (mem_rst_n          )       ,
    .mem_ck             (mem_ck             )       ,
    .mem_ck_n           (mem_ck_n           )       ,
    .mem_cke            (mem_cke            )       ,
    .mem_ras_n          (mem_ras_n          )       ,
    .mem_cas_n          (mem_cas_n          )       ,
    .mem_cs_n           (mem_cs_n           )       ,
    .mem_we_n           (mem_we_n           )       , 
    .mem_odt            (mem_odt            )       ,
    .mem_a              (mem_a              )       ,   
    .mem_ba             (mem_ba             )       ,   
    .mem_dqs            (mem_dqs            )       ,
    .mem_dqs_n          (mem_dqs_n          )       ,
    .mem_dq             (mem_dq             )       ,
    .mem_dm             (mem_dm             )       
    );  

    

MY_UART_TOP u_uart_debug(
    .clk            (clk            )   , 
    .rst_n          (rst_n          )   , 
    .rs232_rx       (rxd            )   , 
    .rs232_tx       (txd_debug      )   , 
    .uart_ctrl_tx   (13'd16       )   , 
    .uart_ctrl_rx   (13'd16       )   , 
    .tx_start       (tx_start       )   , 
    .tx_data        (tx_data        )   , 
    .tx_done        (tx_done        )   , 
    .rx_int         (rx_done        )   , 
    .rx_data        (rx_data        )   
);

task uart_send_byte(input [7:0] data);
    @(posedge clk);
    tx_data  = data;
    #20
    tx_start = 1'b1;
    @(posedge clk);
    tx_start = 1'b0;
    wait (tx_done == 1'b1);
endtask
endmodule