
module my_logic_analysis_top #(
    parameter   DFI_CLK_PERIOD      =   10000                                               ,    
    parameter   MEM_ROW_WIDTH       =   15                                                  ,    
    parameter   MEM_COLUMN_WIDTH    =   10                                                  , 
    parameter   MEM_BANK_WIDTH      =   3                                                   ,    
    parameter   MEM_DQ_WIDTH        =   8                                                   ,   
    parameter   MEM_DM_WIDTH        =   1                                                   ,   
    parameter   MEM_DQS_WIDTH       =   1                                                   ,   
    parameter   REGION_NUM          =   3                                                   ,   
    parameter   CTRL_ADDR_WIDTH     =   MEM_ROW_WIDTH + MEM_COLUMN_WIDTH + MEM_BANK_WIDTH   ,
    parameter   INPUT_WIDTH         =   6                                                   ,
    parameter   MEM_SPACE_AW        =   18                                                  
)(
    input                               clk                 ,
    input                               clk_net             ,
    input                               in_rst_n            ,
    input       [3:0]                   sample_clk_cfg      ,
    input       [31:0]                  sample_num          ,
    input       [1:0]                   triger_type         ,
    input       [2:0]                   trigger_channel     ,
    input                               sample_run          ,
    input       [INPUT_WIDTH-1:0]       din                 ,
    output                              ddr_init_done       ,
    output      [MEM_DQ_WIDTH*8-1:0]    axi_rdata           ,
    output                              axi_rvalid          , //TODO delete

    input                               fifo_ren_net        ,
    output [7:0]                        fifo_rdata_net      ,
    output                              fifo_empty_net      ,
    output                              almost_empty        ,
    input                               ethernet_read_done  ,

    output                              mem_rst_n           ,                       
    output                              mem_ck              ,
    output                              mem_ck_n            ,
    output                              mem_cke             ,
    output                              mem_ras_n           ,
    output                              mem_cas_n           ,
    output                              mem_we_n            , 
    output                              mem_odt             ,
    output                              mem_cs_n            ,
    output 	    [14:0]                  mem_a               ,   
    output 	    [2:0]                   mem_ba              ,   
    inout 	    [1:0]                   mem_dqs             ,
    inout 	    [1:0]                   mem_dqs_n           ,
    inout 	    [15:0]                  mem_dq              ,
    output 	    [1:0]                   mem_dm              
);
    localparam   DLY                 =   0                ;
    localparam [CTRL_ADDR_WIDTH:0] AXI_ADDR_MAX = (1'b1<<MEM_SPACE_AW);

    wire                            clk_ip                 ;  
    wire [MEM_DQ_WIDTH*8-1:0]       dout                ;       
    wire                            fifo_wen            ;
    wire                            fifo_data_full      ;
    wire                            empty               ;
    wire                            fifo_data_alfull    ;
    reg  [CTRL_ADDR_WIDTH-1:0]      axi_awaddr          ;
    reg                             axi_awuser_ap       ;
    reg  [3:0]                      axi_awuser_id       ;
    reg  [3:0]                      axi_awlen           ;
    reg                             axi_awready         ;
    reg                             axi_awvalid         ;
    reg  [MEM_DQ_WIDTH*8-1:0]       axi_wdata           ;
    reg  [MEM_DQ_WIDTH*8/8-1:0]     axi_wstrb           ;
    reg                             axi_wready          ;
    wire                            ren                 ;
    reg                             ren_r               ;
    reg                             ren_reset           ;

    reg  [CTRL_ADDR_WIDTH-1:0]       axi_araddr         ;
    reg  [3:0]                       axi_arlen          ;
    reg                              axi_arready        ;
    reg                              axi_arvalid        ;
    reg                              axi_rlast          ;

    reg  [2:0]                      cur_w_state            ;
    reg  [2:0]                      nex_w_state            ;
    reg  [2:0]                      cur_r_state            ;
    reg  [2:0]                      nex_r_state            ;  
    wire                            axi_wlast           ;
    reg     [11:0]                  fifo_cnt            ;
    reg     [3:0]                   axi_w_cnt           ;
    reg                             first_ddr_read      ; 
    reg     [3:0]                   axi_r_cnt           ;
    reg                             dout_done           ;
    wire                            rst_n               ;
    reg                             wr_full             ;
    reg                             dout_done_r         ;




localparam S_WR_IDLE  = 3'd0;
localparam S_WA_START = 3'd1;
localparam S_WD_WAIT  = 3'd2;
localparam S_WR_WAIT  = 3'd3;
localparam S_WR_DONE  = 3'd4;

localparam S_RR_IDLE  = 3'd0;
localparam S_RA_START = 3'd1;
localparam S_RD_WAIT  = 3'd2;
localparam S_RR_WAIT  = 3'd3;
localparam S_RR_DONE  = 3'd4;

assign axi_wstrb = 8'b11111111;

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        cur_r_state <= S_RR_IDLE;
    end else begin
        cur_r_state <= nex_r_state;
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        cur_w_state <= S_WR_IDLE;
    end else begin
        cur_w_state <= nex_w_state;
    end
end

always @(*) begin
    case (cur_w_state)
        S_WR_IDLE  : begin
            if (~empty) begin
                nex_w_state =  S_WA_START;
            end else begin
                nex_w_state =  S_WR_IDLE;
            end
        end
        S_WA_START : begin
            if (axi_awvalid & axi_awready) begin
                nex_w_state =  S_WD_WAIT;
            end else begin
                nex_w_state =  S_WA_START;
            end
        end
        S_WD_WAIT  : begin
            if (axi_wready) begin
                nex_w_state =  S_WR_WAIT;
            end else begin
                nex_w_state =  S_WD_WAIT;
            end
        end
        S_WR_WAIT  : begin
            if (axi_w_cnt == 'd0 && axi_wready == 'd0) begin
                nex_w_state =  S_WR_DONE;
            end else begin
                nex_w_state =  S_WR_WAIT;
            end
        end
        S_WR_DONE  : begin
            nex_w_state =  S_WR_IDLE;
        end
        default : begin
            nex_w_state =  S_WR_IDLE;
        end
    endcase 
end

always @(*) begin
    case (cur_r_state)
        S_RR_IDLE  : begin
            if (ddr_init_done && ~first_ddr_read) begin
                nex_r_state =  S_RA_START;
            end else if (dout_done && (axi_awaddr > axi_araddr)) begin    //TODO  
                nex_r_state =  S_RA_START;
            end else begin
                nex_r_state =  S_RR_IDLE;
            end
        end
        S_RA_START : begin
            if (axi_arvalid & axi_arready) begin
                nex_r_state =  S_RD_WAIT;
            end else begin
                nex_r_state =  S_RA_START;
            end
        end
        S_RD_WAIT  : begin
            if (axi_rvalid) begin
                nex_r_state =  S_RR_WAIT;
            end else begin
                nex_r_state =  S_RD_WAIT;
            end
        end
        S_RR_WAIT : begin
            if (axi_r_cnt == 'd0 && axi_rvalid == 'd0) begin
                nex_r_state =  S_RR_DONE;
            end else begin
                nex_r_state =  S_RR_WAIT;
            end
        end
        S_RR_DONE  : begin
            nex_r_state =  S_RR_IDLE;
        end
        default : begin
            nex_r_state =  S_RR_IDLE;
        end
    endcase 
end

//========================= WRITE ======================================
always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        fifo_cnt <= 'd0;
    end else begin
        if (fifo_wen && ~ren) begin
            fifo_cnt <= fifo_cnt + 'd1;
        end else if (~fifo_wen && ren) begin
            fifo_cnt <= fifo_cnt - 'd1;
        end
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        axi_awlen <= 'd0;
    end else begin
        if (cur_w_state == S_WA_START && fifo_cnt >= 'd16) begin
            axi_awlen <= 'd15;
        end else if (cur_w_state == S_WA_START && fifo_cnt < 'd16) begin
            axi_awlen <= fifo_cnt;
        end else if (cur_w_state == S_WR_DONE) begin
            axi_awlen <= 'd0;
        end
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        axi_awaddr     <= #DLY 'b0; 
        axi_awvalid    <= #DLY 1'b0; 
    end else begin
        if(axi_awvalid && axi_awready) begin
            axi_awaddr <= #DLY axi_awaddr + ((axi_awlen + 'd1) << 3 ) ; 
        end else if (ethernet_read_done) begin
            axi_awaddr <= #DLY 'd0;
        end
        if(cur_w_state == S_WA_START) begin
            axi_awvalid <= #DLY 'd1;
        end else if (cur_w_state != S_WA_START) begin
            axi_awvalid <= #DLY 'd0;
        end
    end
end

assign ren = axi_wready? 'd1 : ren_r ;
always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        ren_r <= #DLY 'd0;
        ren_reset <= #DLY 'd0;
    end else begin
        if (ren_r) begin
            ren_r <= #DLY 'd0;
        end else if (axi_awvalid & axi_awready && ~ren_reset) begin
            ren_r <= #DLY 'd1;
            ren_reset <= #DLY 'd1;
        end else if (ethernet_read_done) begin
            ren_reset <= #DLY 'd0;
        end
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        axi_w_cnt <= 'd0;
    end else begin
        if (axi_wready) begin
            axi_w_cnt <= axi_w_cnt + 'd1;
        end else if ((nex_w_state == S_WR_DONE) || axi_wlast) begin
            axi_w_cnt <= 'd0;
        end 
    end
end

//========================= READ ====================================================
always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        axi_arlen  <= 'd0;
    end else begin
        if ((axi_awaddr - axi_araddr) >= 'd16) begin
            axi_arlen  <= 'd15;
        end else if ((axi_awaddr - axi_araddr) < 'd16) begin
            axi_arlen  <= (axi_awaddr - axi_araddr) - 1;
        end else if (ethernet_read_done) begin
            axi_arlen  <= 'd0;  
        end
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        axi_araddr <= 'd0;
        axi_arvalid <= 'd0;
    end else begin
        if (cur_r_state == S_RA_START) begin
            axi_arvalid <= 'd1;
        end else if (cur_r_state != S_RA_START) begin
            axi_arvalid <= 'd0;
        end
        if (ethernet_read_done || (cur_r_state == S_RD_WAIT && ~first_ddr_read)) begin
            axi_araddr <= 'd0;
        end else if (axi_arvalid && axi_arready) begin
            axi_araddr <= #DLY axi_araddr + ((axi_arlen + 1)<<3);     
        end
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        axi_r_cnt <= 'd0;
    end else begin
        if (axi_rvalid) begin
            axi_r_cnt <= axi_r_cnt + 'd1;
        end else if ((nex_w_state == S_RR_DONE) || axi_rlast) begin
            axi_r_cnt <= 'd0;
        end 
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        first_ddr_read <= 'd0;
    end else begin
        if (cur_r_state == S_RR_WAIT) begin
            first_ddr_read <= 'd1;
        end else if (ethernet_read_done) begin
            first_ddr_read <= 'd0;
        end
    end
end


always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        dout_done_r <= 'd0;
    end else begin
        if (dout_done) begin    
            dout_done_r <= 'd1;
        end else if (ethernet_read_done) begin
            dout_done_r <= 'd0;
        end
    end
end



my_logic_analysis #(
    .INPUT_WIDTH (6 )           
) u_my_logic_analysis (  
    .clk                (clkout1            )       ,
    .rst_n              (rst_n              )       ,
    .sample_clk_cfg     (sample_clk_cfg     )       ,
    .sample_num         (sample_num         )       ,
    .triger_type        (triger_type        )       ,
    .sample_run         (sample_run         )       ,
    .ethernet_read_done (ethernet_read_done )       ,
    .trigger_channel    (trigger_channel    )       ,
    .din                (din                )       ,   
    .dout_done          (dout_done          )       ,                         //  逻辑分析输入数据
    .dout               (dout               )       ,
    .fifo_wen           (fifo_wen           )       ,
    .fifo_data_full     ('d0                )       ,
    .fifo_data_alfull   (fifo_data_alfull   )                                        //
);

fifo_ddrin u_fifo_ddrin (
    .wr_clk         (clkout1        ),                // input
    .wr_rst         (~rst_n         ),                // input
    .wr_en          (fifo_wen       ),                  // input
    .wr_data        (dout           ),              // input [63:0]
    .wr_full        (wr_full        ),              // output
    .almost_full    (fifo_data_alfull),      // output
    .rd_clk         (clk_ip         ),                // input
    .rd_rst         (~rst_n         ),                // input
    .rd_en          (ren            ),                  // input
    .rd_data        (axi_wdata      ),              // output [63:0]
    .rd_empty       (               ),            // output
    .almost_empty   (empty          )     // output
);

fifo_ddrout u_fifo_ddrout (
    .wr_clk         (clk_ip         ),                // input
    .wr_rst         (~rst_n         ),                // input
    .wr_en          (axi_rvalid     ),                  // input
    .wr_data        (axi_rdata      ),              // input [63:0]
    .wr_full        (               ),              // output
    .almost_full    (               ),      // output
    .rd_clk         (clk_net        ),                // input
    .rd_rst         (~rst_n         ),                // input
    .rd_en          (fifo_ren_net   ),              // input    fifo_ren_net   
    .rd_data        (fifo_rdata_net ),              // output [7:0]     fifo_rdata_net 
    .rd_empty       (fifo_empty_net ),              // output     fifo_empty_net 
    .almost_empty   (almost_empty   )               // output     almost_empty   
);



ddr3_ip u_ddr3_ip(
    .ref_clk                (clk          ),
    .resetn                 (rst_n        ),
    .ddr_init_done          ( ddr_init_done  ),
    .ddrphy_clkin           (clk_ip       ),  
    .pll_lock               ( ),
    
    .axi_awaddr             (axi_awaddr   ),               
    .axi_awuser_ap          (1'b0),                            
    .axi_awuser_id          (4'b0),                 
    .axi_awlen              (axi_awlen    ),            
    .axi_awready            (axi_awready  ),             
    .axi_awvalid            (axi_awvalid  ),
    
    .axi_wdata              (axi_wdata    ),            
    .axi_wstrb              (axi_wstrb    ),            
    .axi_wready             (axi_wready   ),            
    .axi_wusero_id          ( ),                
    .axi_wusero_last        (axi_wlast    ),
    
    .axi_araddr             (axi_araddr   ),            
    .axi_aruser_ap          (1'b0),                            
    .axi_aruser_id          (4'b0),                 
    .axi_arlen              (axi_arlen    ),            
    .axi_arready            (axi_arready  ),            
    .axi_arvalid            (axi_arvalid  ),
    
    .axi_rdata              (axi_rdata    ),            
    .axi_rid                ( ),               
    .axi_rlast              (axi_rlast    ),                
    .axi_rvalid             (axi_rvalid   ),
    
    .apb_clk                ('d0),
    .apb_rst_n              ('d1),
    .apb_sel                ('d0),
    .apb_enable             ('d0),
    .apb_addr               (8'b0),
    .apb_write              ('d0),
    .apb_ready              ( ),
    .apb_wdata              (16'b0),
    .apb_rdata              ( ),
    .apb_int                ( ),  
    .debug_data             (     ),
    .debug_slice_state      (   ),
    .debug_calib_ctrl       (   ),   
    .ck_dly_set_bin         (8'h15),//8��h14
    .dll_step               (),
    .dll_lock               (),
    .init_read_clk_ctrl     ('d0),                                                 
    .init_slip_step         ('d0), 
    .force_read_clk_ctrl    ('d0), 
    .ddrphy_gate_update_en  ('d0),//1
    .update_com_val_err_flag( ),
    .rd_fake_stop           ('d0),   
    .mem_rst_n              (mem_rst_n    ),
    .mem_ck                 (mem_ck       ),
    .mem_ck_n               (mem_ck_n     ),
    .mem_cke                (mem_cke      ),
    .mem_ras_n              (mem_ras_n    ),
    .mem_cs_n               (mem_cs_n     ),
    .mem_cas_n              (mem_cas_n    ),
    .mem_we_n               (mem_we_n     ),
    .mem_odt                (mem_odt      ),
    .mem_a                  (mem_a        ),
    .mem_ba                 (mem_ba       ),
    .mem_dqs                (mem_dqs      ),
    .mem_dqs_n              (mem_dqs_n    ),
    .mem_dq                 (mem_dq       ),
    .mem_dm                 (mem_dm       )
);


pll_ip u_pll_ip (
  	.pll_rst(~in_rst_n),      // input
  	.clkin1(clk),        // input
  	.pll_lock(pll_lock),    // output
  	.clkout0(clkout0),      // output
  	.clkout1(clkout1)       // output
);
assign rst_n = pll_lock & in_rst_n;



endmodule