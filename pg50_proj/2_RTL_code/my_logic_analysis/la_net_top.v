module la_net_top #(
    parameter   MEM_DQ_WIDTH    =   32                      ,
    parameter   INPUT_WIDTH     =   6                       ,
    parameter   MEM_ROW_WIDTH   =   15                      ,
    parameter   MEM_BANK_WIDTH  =   3                       ,
    parameter   MEM_DQS_WIDTH   =   MEM_DQ_WIDTH/8          ,
    parameter   MEM_DM_WIDTH    =   MEM_DQ_WIDTH/8          
)(
    input                               clk             /* synthesis PAP_MARK_DEBUG="true" */    ,
    input                               rst_n               ,
    // input       [3:0]                   sample_clk_cfg      ,
    // input       [31:0]                  sample_num          ,
    // input       [1:0]                   triger_type         ,
    // input       [2:0]                   trigger_channel     ,
    input                               sample_run          ,
    input       [INPUT_WIDTH-1:0]       din                 ,  

    output                              ddr_init_done       ,
    output                              ethernet_read_done  ,
    output                              dout_done_r         ,
    output                              led4                ,
    output                              led5                ,

    output                              mem_rst_n           ,
    output                              mem_ck              ,
    output                              mem_ck_n            ,
    output                              mem_cke             ,
    output                              mem_ras_n           ,
    output                              mem_cas_n           ,
    output                              mem_we_n            ,
    output                              mem_odt             ,
    output                              mem_cs_n            ,
    output 	    [MEM_ROW_WIDTH-1:0]     mem_a               ,
    output 	    [MEM_BANK_WIDTH-1:0]    mem_ba              ,
    inout 	    [MEM_DQS_WIDTH-1:0]     mem_dqs             ,
    inout 	    [MEM_DQS_WIDTH-1:0]     mem_dqs_n           ,
    inout 	    [MEM_DQ_WIDTH-1:0]      mem_dq              ,
    output 	    [MEM_DM_WIDTH-1:0]      mem_dm              ,

    input                               rgmii_rxc           ,
    input                               rgmii_rx_ctl        ,
    input       [3:0]                   rgmii_rxd           ,
    output                              rgmii_txc           ,
    output                              rgmii_tx_ctl        ,
    output      [3:0]                   rgmii_txd 
);






//reg                                     start_r0                ;
//reg                                     start_r1                ;
//reg                                     start_r2                ;
//reg                                     start_posedge           ;
reg                                     fifo_ren_net            ;
reg     [7:0]                           fifo_rdata_net          ;         
reg                                     almost_empty            ;
reg                                     ethernet_read_done      ;
wire                                    mac_rx_data_valid       ;
wire    [7:0]                           mac_rx_data             ;    
wire                                    mac_data_valid          ;   
wire    [7:0]                           mac_tx_data             ;  

wire    [3:0]                   sample_clk_cfg  = 'hd    ;
wire    [31:0]                  sample_num      = 32'h00003fff    ;
wire    [1:0]                   triger_type     = 'b11   ;
wire    [2:0]                   trigger_channel = 'd0    ;




// always @(posedge clk or negedge rst_n) begin
//     if(rst_n == 1'b0) begin
//         start_r0 <= 'd0;
//         start_r1 <= 'd0;
//         start_r2 <= 'd0;
//     end else begin
//         start_r0 <= sample_run;
//         start_r1 <= start_r0;
//         start_r2 <= start_r1;
//     end
// end

// always @(posedge clk or negedge rst_n) begin
//     if(rst_n == 1'b0) begin
//         start_posedge <= 'd0;
//     end else begin
//         if (~start_r2 && start_r1) begin
//             start_posedge <= 'd1;
//         end else if (start_posedge) begin
//             start_posedge <= 'd0;
//         end
//     end
// end


eth_udp_test#(
    .LOCAL_MAC              (48'h11_11_11_11_11_11) ,
    .LOCAL_IP               (32'hC0_A8_01_0B      ) ,          //192.168.1.110  11
    .LOCL_PORT              (16'h8080             ) ,

    .DEST_IP                (32'hC0_A8_01_66      ) ,          //192.168.1.105   102
    .DEST_PORT              (16'h8080             )
) u_eth_udp_test
(
    .rgmii_clk              (rgmii_clk          )   ,
    .rstn                   (rst_n              )   ,
    .gmii_rx_dv             (mac_rx_data_valid  )   ,
    .gmii_rxd               (mac_rx_data        )   ,
    .gmii_tx_en             (mac_data_valid     )   ,
    .gmii_txd               (mac_tx_data        )   ,

    .led4                   (led4               )   ,
    .led5                   (led5               )   ,

    .fifo_ren               (fifo_ren_net       )   ,
    .fifo_data              (fifo_rdata_net     )   ,    
    .almost_empty           (almost_empty       )   ,
    .sample_num             (sample_num         )   ,
    .ethernet_read_done     (ethernet_read_done )   ,
    .sample_run          (sample_run      )   ,

    .udp_rec_data_valid     (                   )   ,         
    .udp_rec_rdata          (                   )   ,             
    .udp_rec_data_length    (                   )            
);

my_logic_analysis_top #(
    .DFI_CLK_PERIOD     (10000              )          ,    
    .MEM_ROW_WIDTH      (15                 )          ,    
    .MEM_COLUMN_WIDTH   (10                 )          , 
    .MEM_BANK_WIDTH     (3                  )          ,    
    .MEM_DQ_WIDTH       (32                 )          ,   
    .DDR_WIDTH_SHIFT    (3                  )          , //TODO log2(MEM_DQ_WIDTH)?
    .MEM_DM_WIDTH       (MEM_DQ_WIDTH/8     )          ,   
    .MEM_DQS_WIDTH      (MEM_DQ_WIDTH/8     )          ,   
    .REGION_NUM         (3                  )          ,   
    .CTRL_ADDR_WIDTH    (28                 )          ,
    .INPUT_WIDTH        (INPUT_WIDTH        )          ,
    .MEM_SPACE_AW       (18                 )          
) u_my_logic_analysis_top (
    .clk                (clk                )   ,
    .clk_net            (clk_net            )   ,
    .in_rst_n           (rst_n              )   ,
    .sample_clk_cfg     (sample_clk_cfg     )   ,
    .sample_num         (sample_num         )   ,
    .triger_type        (triger_type        )   ,
    .trigger_channel    (trigger_channel    )   ,
    .sample_run      (sample_run      )   ,
    .din                (din                )   ,
    .ddr_init_done      (ddr_init_done      )   ,

    .fifo_ren_net       (fifo_ren_net       )   ,
    .fifo_rdata_net     (fifo_rdata_net     )   ,
    .fifo_empty_net     (                   )   ,
    .almost_empty       (almost_empty       )   ,
    .ethernet_read_done (ethernet_read_done )   ,
    .dout_done_r        (dout_done_r        )   ,

    .mem_rst_n          (mem_rst_n          )   ,                       
    .mem_ck             (mem_ck             )   ,
    .mem_ck_n           (mem_ck_n           )   ,
    .mem_cke            (mem_cke            )   ,
    .mem_ras_n          (mem_ras_n          )   ,
    .mem_cas_n          (mem_cas_n          )   ,
    .mem_we_n           (mem_we_n           )   , 
    .mem_odt            (mem_odt            )   ,
    .mem_cs_n           (mem_cs_n           )   ,
    .mem_a              (mem_a              )   ,   
    .mem_ba             (mem_ba             )   ,   
    .mem_dqs            (mem_dqs            )   ,
    .mem_dqs_n          (mem_dqs_n          )   ,
    .mem_dq             (mem_dq             )   ,
    .mem_dm             (mem_dm             )   
);

rgmii_interface u_rgmii_interface(
    .rst                       (  ~rst_n             ),//input        rst,
    .rgmii_clk                 (  rgmii_clk          ),//output       rgmii_clk,
    .rgmii_clk_90p             (  rgmii_clk_90p      ),//input        rgmii_clk_90p,
    .mac_tx_data_valid         (  mac_data_valid     ),//input        mac_tx_data_valid,
    .mac_tx_data               (  mac_tx_data        ),//input [7:0]  mac_tx_data,
    .mac_rx_error              (                     ),//output       mac_rx_error,
    .mac_rx_data_valid         (  mac_rx_data_valid  ),//output       mac_rx_data_valid,
    .mac_rx_data               (  mac_rx_data        ),//output [7:0] mac_rx_data,
    .rgmii_rxc                 (  rgmii_rxc          ),//input        rgmii_rxc,
    .rgmii_rx_ctl              (  rgmii_rx_ctl       ),//input        rgmii_rx_ctl,
    .rgmii_rxd                 (  rgmii_rxd          ),//input [3:0]  rgmii_rxd,
    .rgmii_txc                 (  rgmii_txc          ),//output       rgmii_txc,
    .rgmii_tx_ctl              (  rgmii_tx_ctl       ),//output       rgmii_tx_ctl,
    .rgmii_txd                 (  rgmii_txd          ) //output [3:0] rgmii_txd 
);

endmodule