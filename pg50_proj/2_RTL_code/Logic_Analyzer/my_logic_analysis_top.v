
module my_logic_analysis_top #(
    parameter   DFI_CLK_PERIOD      =   10000                                               ,    
    parameter   MEM_ROW_WIDTH       =   15                                                  ,    
    parameter   MEM_COLUMN_WIDTH    =   10                                                  , 
    parameter   MEM_BANK_WIDTH      =   3                                                   ,    
    parameter   MEM_DQ_WIDTH        =   32                                                  ,   
    parameter   DDR_WIDTH_SHIFT     =   3                                                   , //TODO log2(MEM_DQ_WIDTH)?
    parameter   MEM_DM_WIDTH        =   MEM_DQ_WIDTH/8                                      ,   
    parameter   MEM_DQS_WIDTH       =   MEM_DQ_WIDTH/8                                      ,   
    parameter   REGION_NUM          =   3                                                   ,   
    parameter   CTRL_ADDR_WIDTH     =   MEM_ROW_WIDTH + MEM_COLUMN_WIDTH + MEM_BANK_WIDTH   ,
    parameter   INPUT_WIDTH         =   6                                                   ,
    parameter   MEM_SPACE_AW        =   18                                                  
)(
    input                               clk                 ,
    input                               clkout1             ,
    input                               clk_net             ,
    input                               rst_n               ,
    input       [3:0]                   sample_clk_cfg      ,
    input       [31:0]                  sample_num          ,
    input       [1:0]                   triger_type         ,
    input       [2:0]                   trigger_channel     ,
    input                               sample_run          ,
    input       [INPUT_WIDTH-1:0]       din                 ,
    output                              ddr_init_done       ,
    output reg                          start_posedge       ,

    input                               fifo_ren_net        ,
    output      [7:0]                   fifo_rdata_net      ,
    output                              fifo_empty_net      ,
    output                              almost_empty     /* synthesis PAP_MARK_DEBUG="true" */   ,
    input                               ethernet_read_done  ,
    output                              ddrout_almost_full  ,
    output                              led6                ,
    output                              dout_done           ,

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
    output 	    [MEM_DM_WIDTH-1:0]      mem_dm              
);
    localparam   DLY                 =   1                ;
    // localparam [CTRL_ADDR_WIDTH:0] AXI_ADDR_MAX = (1'b1<<MEM_SPACE_AW);

    wire                            clk_ip       /* synthesis PAP_MARK_DEBUG="<0/c0/0>" */          ;  
    // wire                            clkout1      /* synthesis PAP_MARK_DEBUG="<0/c0/0>" */       ;            
    wire [MEM_DQ_WIDTH*8-1:0]       dout                ;       
    wire                            fifo_wen            ;
    wire                            fifo_data_full      ;
    wire                            empty               ;
    wire                            fifo_data_alfull    ;
    reg  [CTRL_ADDR_WIDTH-1:0]      axi_awaddr          ;
    reg  [3:0]                      axi_awlen           ;
    wire                            axi_awready    /* synthesis PAP_MARK_DEBUG="true" */     ;
    reg                             axi_awvalid    /* synthesis PAP_MARK_DEBUG="true" */     ;
    wire [MEM_DQ_WIDTH*8-1:0]       axi_wdata           ;
    wire [MEM_DQ_WIDTH*8/8-1:0]     axi_wstrb           ;
    wire                            axi_wready          ;
    wire                            ren                 ;
    reg                             ren_r               ;
    reg                             ren_reset           ;

    reg  [CTRL_ADDR_WIDTH-1:0]       axi_araddr         ;
    reg  [3:0]                       axi_arlen          ;
    wire                             axi_arready      /* synthesis PAP_MARK_DEBUG="true" */    ;
    reg                              axi_arvalid      /* synthesis PAP_MARK_DEBUG="true" */    ;
    wire                             axi_rlast          ;

    reg  [2:0]                      cur_w_state            ;
    reg  [2:0]                      nex_w_state            ;
    reg  [2:0]                      cur_r_state            ;
    reg  [2:0]                      nex_r_state            ;  
    wire                            axi_wlast           ;
    reg     [31:0]                  fifo_cnt            ;
    reg     [7:0]                   axi_w_cnt           ;
    reg     [7:0]                   axi_awlen_cnt       ;
    reg                             first_ddr_read      ; 
    reg     [7:0]                   axi_r_cnt           ;
    reg     [7:0]                   axi_arlen_cnt       ;
    reg                             start_r0            ;
    reg                             start_r1            ;
    reg                             start_r2            ;
    // reg                             start_posedge       ;
    wire                            wr_full             ;

    wire    [MEM_DQ_WIDTH*8-1:0]    axi_rdata           ;
    wire                            axi_rvalid          ;
    // wire                            ddrout_almost_full  ;
    reg     [31:0]                  fifo_cnt_r0         ;
    reg     [31:0]                  fifo_cnt_r1         ;
    wire    [7:0]                   ck_dly_set_bin = 'h15   ;
    wire                            fifo_rst            ;
    reg                             ethernet_read_done_r0       ;
    reg                             ethernet_read_done_r1       ;
    wire                            ethernet_read_done_posedge  ;



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

assign led6 = (axi_awaddr == axi_araddr);
assign axi_wstrb = {MEM_DQ_WIDTH{1'b1}};

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        cur_r_state <= #DLY S_RR_IDLE;
    end else begin
        cur_r_state <= #DLY nex_r_state;
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        cur_w_state <= #DLY S_WR_IDLE;
    end else begin
        cur_w_state <= #DLY nex_w_state;
    end
end

always @(*) begin
    case (cur_w_state)
        S_WR_IDLE  : begin
            if (~empty || (dout_done && axi_awaddr < (fifo_cnt_r1 << DDR_WIDTH_SHIFT))) begin
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
            if (axi_awlen_cnt == axi_w_cnt && axi_wready == 'd0) begin
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
            // if (ddr_init_done && ~first_ddr_read) begin
            //     nex_r_state =  S_RA_START;
            // end else 
            if (~ddrout_almost_full && dout_done && (axi_awaddr > axi_araddr)) begin
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
            if (axi_awlen_cnt == axi_w_cnt && axi_rvalid == 'd0) begin
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
always @(posedge clkout1 or negedge rst_n) begin
    if (!rst_n) begin
        fifo_cnt <= 'd0;
    end else begin
        if (fifo_wen) begin
            fifo_cnt <= fifo_cnt + 'd1;
        end else if (ethernet_read_done) begin
            fifo_cnt <= 'd0;
        end
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        fifo_cnt_r0 <= #DLY 'd0;
        fifo_cnt_r1 <= #DLY 'd0;
    end else begin
        fifo_cnt_r0 <= #DLY fifo_cnt;
        fifo_cnt_r1 <= #DLY fifo_cnt_r0;
    end
end

always @(*) begin
    if (axi_awaddr + 'h80 <= (fifo_cnt_r1 << DDR_WIDTH_SHIFT)) begin
        axi_awlen = 'd15;
    end else if (axi_awaddr + 'h80 > (fifo_cnt_r1 << DDR_WIDTH_SHIFT)) begin
        axi_awlen = fifo_cnt_r1 - (axi_awaddr >> DDR_WIDTH_SHIFT) - 'd1;
    end else begin
        axi_awlen = 'd0;
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        axi_awaddr     <= #DLY 'b0; 
        axi_awvalid    <= #DLY 1'b0; 
    end else begin
        if(axi_awvalid && axi_awready) begin
            axi_awaddr <= #DLY axi_awaddr + ((axi_awlen + 'd1) << DDR_WIDTH_SHIFT ) ; 
        end else if (ethernet_read_done) begin
            axi_awaddr <= #DLY 'd0;
        end
        if (cur_w_state != S_WA_START || (axi_awaddr + 'd128 >= (fifo_cnt_r1 << DDR_WIDTH_SHIFT) && axi_awvalid & axi_awready)) begin
            axi_awvalid <= #DLY 'd0;
        end else if(cur_w_state == S_WA_START) begin
            axi_awvalid <= #DLY 'd1;
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
        if (nex_w_state == S_WR_DONE) begin
            axi_w_cnt <= #DLY 'd0;
        end else if (axi_wready) begin
            axi_w_cnt <= #DLY axi_w_cnt + 'd1;
        end
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        axi_awlen_cnt <= 'd0;
    end else begin
        if (nex_w_state == S_WR_DONE) begin
            axi_awlen_cnt <= 'd0;
        end else if (axi_awvalid && axi_awready) begin
            axi_awlen_cnt <= axi_awlen_cnt + (axi_awlen + 1);
        end
    end
end

//========================= READ ====================================================
always @(*) begin
    if ((axi_awaddr - axi_araddr) >= 'h80) begin
        axi_arlen  <= #DLY 'd15;
    end else if ((axi_awaddr - axi_araddr) < 'h80 && axi_awaddr != axi_araddr) begin
        axi_arlen  <= #DLY ((axi_awaddr - axi_araddr) >> 3) - 'd1;
    end else begin
        axi_arlen  <= 'd0;
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        axi_araddr <= #DLY 'd0;
        axi_arvalid <= #DLY 'd0;
    end else begin
        if (cur_r_state != S_RA_START || ((axi_awaddr - axi_araddr) <= 'd128 && axi_arvalid & axi_arready)) begin
            axi_arvalid <= #DLY 'd0;
        end else if (cur_r_state == S_RA_START) begin
            axi_arvalid <= #DLY 'd1;
        end
        // if (ethernet_read_done || (cur_r_state == S_RD_WAIT && ~first_ddr_read)) begin
        if (ethernet_read_done) begin
            axi_araddr <= #DLY 'd0;
        end else if (axi_arvalid && axi_arready) begin
            axi_araddr <= #DLY axi_araddr + ((axi_arlen + 1)<<DDR_WIDTH_SHIFT);     
        end
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        axi_r_cnt <= #DLY 'd0;
    end else begin
        if (nex_r_state == S_RR_DONE) begin
            axi_r_cnt <= #DLY 'd0;
        end else if (axi_rvalid) begin
            axi_r_cnt <= #DLY axi_r_cnt + 'd1;
        end
    end
end

always @(posedge clk_ip or negedge rst_n) begin
    if (!rst_n) begin
        axi_arlen_cnt <= 'd0;
    end else begin
        if (nex_r_state == S_RR_DONE) begin
            axi_arlen_cnt <= 'd0;
        end else if (axi_arvalid && axi_arready) begin
            axi_arlen_cnt <= axi_arlen_cnt + (axi_arlen + 1);
        end
    end
end

// always @(posedge clk_ip or negedge rst_n) begin
//     if (!rst_n) begin
//         first_ddr_read <= #DLY 'd0;
//     end else begin
//         if (cur_r_state == S_RR_DONE && first_ddr_read == 'd0) begin
//             first_ddr_read <= #DLY 'd1;
//         end else if (ethernet_read_done_posedge) begin
//             first_ddr_read <= #DLY 'd0;
//         end
//     end
// end


// always @(posedge clkout1 or negedge rst_n) begin
//     if (!rst_n) begin
//         dout_done_r <= 'd0;
//     end else begin
//         if (dout_done) begin    
//             dout_done_r <= 'd1;
//         end else if (ethernet_read_done) begin
//             dout_done_r <= 'd0;
//         end
//     end
// end



my_logic_analysis #(
    .INPUT_WIDTH        (6                  )       ,
    .MEM_DQ_WIDTH       (MEM_DQ_WIDTH       )           
) u_my_logic_analysis (  
    .clk                (clkout1            )       ,
    .rst_n              (rst_n              )       ,
    .ddr_init_done      (ddr_init_done      )       ,
    .sample_clk_cfg     (sample_clk_cfg     )       ,
    .sample_num         (sample_num         )       ,
    .triger_type        (triger_type        )       ,
    .start_posedge      (start_posedge      )       ,
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
    .wr_rst         (fifo_rst       ),                // input
    .wr_en          (fifo_wen       ),                  // input
    .wr_data        (dout           ),              // input [63:0]
    .wr_full        (wr_full        ),              // output
    .almost_full    (fifo_data_alfull),      // output
    .rd_clk         (clk_ip         ),                // input
    .rd_rst         (fifo_rst       ),                // input
    .rd_en          (ren            ),                  // input
    .rd_data        (axi_wdata      ),              // output [63:0]
    .rd_empty       (               ),            // output
    .almost_empty   (empty          )     // output
);

fifo_ddrout u_fifo_ddrout (
    .wr_clk         (clk_ip         ),                // input
    .wr_rst         (fifo_rst       ),                // input
    .wr_en          (axi_rvalid     ),                  // input
    .wr_data        (axi_rdata      ),              // input [63:0]
    .wr_full        (               ),              // output
    .almost_full    (ddrout_almost_full    ),              // output
    .rd_clk         (clk_net        ),                // input
    .rd_rst         (fifo_rst       ),                // input
    .rd_en          (fifo_ren_net   ),              // input    fifo_ren_net   
    .rd_data        (fifo_rdata_net ),              // output [7:0]     fifo_rdata_net 
    .rd_empty       (fifo_empty_net ),              // output     fifo_empty_net 
    .almost_empty   (almost_empty   )               // output     almost_empty   
);



ddr3_ip u_ddr3_ip(
    .ref_clk                (clk          ),
    .resetn                 (~fifo_rst    ),
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
    .ck_dly_set_bin         (ck_dly_set_bin),//8��h14
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


always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        start_r0 <= 'd0;
        start_r1 <= 'd0;
        start_r2 <= 'd0;
    end else begin
        start_r0 <= sample_run;
        start_r1 <= start_r0;
        start_r2 <= start_r1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        start_posedge <= 'd0;
    end else begin
        if (~start_r2 && start_r1 && ddr_init_done) begin
            start_posedge <= 'd1;
        end else if (~ethernet_read_done) begin
            start_posedge <= 'd0;
        end
    end
end

// pll_ip u_pll_ip (
//   	.pll_rst(~in_rst_n),      // input
//   	.clkin1(clk),        // input
//   	.pll_lock(pll_lock),    // output
//   	.clkout0(clkout0),      // output
//   	.clkout1(clkout1)       // output
// );
// assign rst_n = in_rst_n;
assign fifo_rst = ~rst_n || ethernet_read_done_posedge;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ethernet_read_done_r0 <= 'd0;
        ethernet_read_done_r1 <= 'd0;
    end else begin
        ethernet_read_done_r0 <= ethernet_read_done;
        ethernet_read_done_r1 <= ethernet_read_done_r0;
    end
end

assign ethernet_read_done_posedge = ethernet_read_done_r0 & ~ethernet_read_done_r1;

endmodule