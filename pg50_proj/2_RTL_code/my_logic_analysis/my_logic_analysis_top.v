





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
    parameter   MEM_SPACE_AW        =   18                                                  ,
    parameter   CONFIG_WIDTH        =   32
)(
    input                               clk                 ,
    input                               rst_n               ,
    input                               config_valid        ,
    input       [31:0]                  config_in           ,
    input       [31:0]                  time_need           ,
    input       [1:0]                   triger_type         ,
    input                               start               ,
    input                               touch_start         ,
    input                               read_start          ,
    input       [INPUT_WIDTH-1:0]       din                 ,
    output                              ddr_init_done       ,
    output      [MEM_DQ_WIDTH*8-1:0]    axi_rdata           ,
    output                              axi_rvalid          ,

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
    localparam   DLY                 =   0                                                   ;
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
    reg     [CONFIG_WIDTH-1:0]      config_in_r         ;
    reg     [3:0]                   axi_w_cnt           ;
    reg                             first_ddr_read      ; 
    reg     [3:0]                   axi_r_cnt           ;
    reg                             dout_done           ;




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
            end else if (read_start && (axi_awaddr > axi_araddr)) begin    //TODO  
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

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        config_in_r <= #DLY 'd0;
    end else begin
        if (config_valid) begin
            config_in_r <= #DLY config_in;
        end
    end
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
        end else if (dout_done) begin
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
        end else if (dout_done) begin
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
        end else if (dout_done) begin
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
        if (dout_done || (cur_r_state == S_RD_WAIT && ~first_ddr_read)) begin
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
        end else if (dout_done) begin
            first_ddr_read <= 'd0;
        end
    end
end


// always @(posedge clk_ip or negedge rst_n) begin
//     if (!rst_n) begin
//         axi_r_done <= 'd0;
//     end else begin
//         if (axi_araddr == axi_awaddr && axi_awaddr != 'd0) begin    //TODO  waddr继续增长
//             axi_r_done <= 'd1;
//         end else if (dout_done) begin
//             axi_r_done <= 'd0;
//         end
//     end
// end


my_logic_analysis #(
    .INPUT_WIDTH (6 )           
) u_my_logic_analysis (  
    .clk                (clk                )       ,
    .rst_n              (rst_n              )       ,
    .config_in_r        (config_in_r        )       ,
    .time_need          (time_need          )       ,
    .triger_type        (triger_type        )       ,
    .start              (start              )       ,
    .touch_start        (touch_start        )       ,
    .din                (din                )       ,                            //  逻辑分析输入数据
    .dout               (dout               )       ,
    .fifo_wen           (fifo_wen           )       ,
    .fifo_data_full     ('d0                )       ,
    .fifo_data_alfull   (fifo_data_alfull   )                                        //
);


ASYN_FIFO #(
    .DLY        (DLY                )       , 
    .ADDR_WIDTH (12                 )       , 
    .DATA_WIDTH (MEM_DQ_WIDTH*8     )   
) U_ASYN_FIFO (
    .wclk       (clk                )       ,
    .rclk       (clk_ip             )       ,
    .w_rst_n    (rst_n              )       ,
    .r_rst_n    (rst_n              )       ,
    .wen        (fifo_wen           )       ,
    .ren        (ren                )       ,
    .level      (64'd32             )       ,
    .din        (dout               )       ,
    .dout       (axi_wdata          )       ,
    .alfull     (fifo_data_alfull   )       ,
    .empty      (empty              )              //fifo内存储数据小于32时为1   
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



endmodule