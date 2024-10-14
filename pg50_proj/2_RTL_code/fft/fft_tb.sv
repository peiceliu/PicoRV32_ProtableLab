`timescale 1ns / 1ps

module fft_tb ();

    parameter T = 20;
    reg                 clk             ;
    reg                 rst_n           ;
    reg                 start            ;
    reg    [11:0]       ram_out          ;
    reg                 ram_wen         ;
    reg    [7:0]        ram_waddr        ;
    reg    [15:0]       img_in [0:255]   ;
    reg                 fft_done         ;
    wire   [7:0]        ram_waddr_max1   ;
    wire   [7:0]        ram_waddr_max2   ;
    reg                 s_axis_data_tready  ; 
    reg                 fft_data_out_en     ; 
    reg                 fft_data_out_last   ; 
    reg    [11:0]       fft_data_out        ; 
    reg    [7:0]        fft_addr_out        ; 
        wire               GRS_N;

    integer i;
    integer j;
    integer file;
    integer file1;
    integer filey;

    initial begin
        clk = 1'b1;
        rst_n = 1'b0;
        start = 0;
        file = $fopen("./output.txt","w");
        file1 = $fopen("./check1.txt","w");
        filey = $fopen("./checky.txt","w");
        fft_data_out_en = 'd0;
        fft_addr_out = 'd0;
    
        #T
        rst_n = 1'b1;
        $readmemh( "E:/project/fpga_dasai/fft/input1.txt", img_in);
        #T
        start = 1;
        wait (s_axis_data_tready);
        #T;
        start = 0;
        ram_wen = 1'b1;
        for (i=0; i<=255; i=i+1) begin
            ram_waddr = i;
            ram_out = img_in[i][15:4];
            #T;
        end
        ram_wen = 1'b0;
        #10;
        $display("@%0t,test",$time());
        #T; 
        start = 0;
        while(1)begin
            // $display("in while");
            @(posedge clk);

            if (fft_top1.fft1.fft_en) begin
                $fwrite(file1, "%h\t%h\t%h\t%h\t%h\t%h\n", fft_top1.fft1.butterfly1.xp_real, fft_top1.fft1.butterfly1.xp_imag, fft_top1.fft1.butterfly1.xq_real, fft_top1.fft1.butterfly1.xq_imag, fft_top1.fft1.butterfly1.factor_real, fft_top1.fft1.butterfly1.factor_imag);
            end
            if (fft_top1.fft1.fft_en && fft_top1.fft1.fft_cnt == 'h80) begin
                $fwrite(file1, "-----------------------------------------------------------------------\n");
            end
            if (fft_top1.fft1.fft_valid) begin
                $fwrite(filey, "%h\t%h\t%h\t%h\n", fft_top1.fft1.butterfly1.yp_real, fft_top1.fft1.butterfly1.yp_imag, fft_top1.fft1.butterfly1.yq_real, fft_top1.fft1.butterfly1.yq_imag);
            end
            if (fft_top1.fft1.fft_valid && fft_top1.fft1.fft_cnt == 'h01) begin
                $fwrite(filey, "-----------------------------------------------------------------------\n");
            end

            if (fft_top1.fft1.fft_cnt == 'd2 && ~fft_top1.fft1.ram_ren_r) begin
                $display("before break");
                break;
            end
            if (fft_top1.fft1.butterfly1.yp_real_r[46:45] != 2'b00 && fft_top1.fft1.butterfly1.yp_real_r[46:45] != 2'b11) begin
                // $display("before display");
                $display("%d    %d     %b", fft_top1.fft1.fft_cnt, fft_top1.fft1.loop_cnt, fft_top1.fft1.butterfly1.yp_real_r);
            end
        end
        // if (fft_done) begin
        //     for (i=0; i<=255; i=i+1) begin
        //         $fwrite(file, "%h\n", DPRAM_WRAP1.mem[i]);
        //     end
        // end
        wait (fft_done);
        for (i=0; i<=127; i=i+1) begin
            fft_addr_out = i;
            fft_data_out_en = 'd1;
            #T;
        end
        fft_data_out_en = 'd0;
    end

    always #10 clk = ~clk;

    GTP_GRS GRS_INST(
        .GRS_N(1'b1)
    );

fft_top #(
    .RAM_DATA_WIDTH     (16 )      , 
    .RAM_ADDR_WIDTH     (8  )      , 
    .INOUT_DATA_WIDTH   (12 )      ,
    .MUTI               (1  )
) fft_top1 (
    .clk            (clk        )               ,
    .rst_n          (rst_n      )               ,

    .fft_data_in        (ram_out            )   ,
    .fft_addr_in        (ram_waddr          )   ,
    .fft_data_in_en     (ram_wen            )   ,
    .ad_clk             (clk                )   ,
    .s_axis_data_tready (s_axis_data_tready )   ,

    .fft_data_out_en    (fft_data_out_en    )   ,
    .fft_data_out_last  (fft_data_out_last  )   ,
    .fft_data_out       (fft_data_out       )   ,
    .fft_addr_out       (fft_addr_out       )   ,
    .hdmi_clk           (clk                )   ,

    .start          (start      )               ,
    .fft_done       (fft_done   )               ,
    .ram_waddr_max1 (ram_waddr_max1)            ,
    .ram_waddr_max2 (ram_waddr_max2)            
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
    //     $fsdbDumpvars(0, fft_tb);
    //     $fsdbDumpMDA();
    // end
//------------------------------------------------------------------------




endmodule