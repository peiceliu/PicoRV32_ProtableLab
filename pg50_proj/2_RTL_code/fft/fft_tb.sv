`timescale 1ns / 1ps

module fft_tb ();

    parameter T = 20;
    reg                 clk             ;
    reg                 rst_n           ;
    reg    [63:0]      ram_in           ;
    reg                start            ;
    reg    [63:0]      ram_out          ;
    reg                 ram_wen         ;
    reg                ram_ren          ;
    reg    [7:0]       ram_waddr        ;
    reg    [7:0]       ram_raddr        ;
    reg    [15:0]      img_in [0:255]   ;
    reg                ram_wen_c        ;
    reg    [7:0]       ram_waddr_c      ;
    reg    [63:0]      ram_out_c        ;
    wire   [7:0]       i_wire           ;
    reg                fft_done         ;

    integer i;
    integer j;
    integer file;
    integer file1;
    integer filey;

    assign i_wire = i;
    initial begin
        clk = 1'b1;
        rst_n = 1'b0;
        start = 0;
        file = $fopen("./output.txt","w");
        file1 = $fopen("./check1.txt","w");
        filey = $fopen("./checky.txt","w");
        #T
        rst_n = 1'b1;
        $readmemh( "./testbench/input1.txt", img_in);
        #T
        ram_wen = 1'b1;
        for (i=0; i<=255; i=i+1) begin
            ram_waddr=i_wire;
            ram_out = {32'b0,{16{img_in[i][15]}},img_in[i]};
            #T;
        end
        ram_wen = 1'b0;
        #10;
        start = 1;
        $display("@%0t,test",$time());

        #T; 
        start = 0;
        while(1)begin
            // $display("in while");
            @(posedge clk);
            ram_waddr = ram_waddr_c;
            ram_wen = ram_wen_c;
            ram_out = ram_out_c;

            // if (fft_top1.fft1.ram_waddr_r[7:0] == 'd0) begin
            //     $fwrite(file, "--------------------------------------------------------------------------------------\n");
            //     for (i=0; i<=255; i=i+1) begin
            //         $fwrite(file, "%h\n", DPRAM_WRAP1.mem[i]);
            //     end
            // end

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
                // $display("before break");
                break;
            end
            if (fft_top1.fft1.butterfly1.yp_real_r[46:45] != 2'b00 && fft_top1.fft1.butterfly1.yp_real_r[46:45] != 2'b11) begin
                // $display("before display");
                $display("%d    %d     %b", fft_top1.fft1.fft_cnt, fft_top1.fft1.loop_cnt, fft_top1.fft1.butterfly1.yp_real_r);
            end
        end
        if (fft_done) begin
            for (i=0; i<=255; i=i+1) begin
                $fwrite(file, "%h\n", DPRAM_WRAP1.mem[i]);
            end
        end
    end

    always #10 clk = ~clk;
fft_top #(
    .RAM_DATA_WIDTH     (16 )      , 
    .RAM_ADDR_WIDTH     (8  )      , 
    .INOUT_DATA_WIDTH   (16 )      
) fft_top1 (
    .clk            (clk        )               ,
    .rst_n          (rst_n      )               ,
    .data_in        (ram_in     )               ,
    .ram_wen        (ram_wen_c  )               ,
    .ram_ren        (ram_ren    )               ,
    .ram_waddr      (ram_waddr_c)               ,
    .ram_raddr      (ram_raddr  )               ,
    .data_out       (ram_out_c  )               ,
    .start          (start      )               ,
    .fft_done       (fft_done   )               
);

DPRAM_WRAP #(
    .ADDR_WIDTH     (8          )               ,      
    .DATA_WIDTH     (64         )                       
) DPRAM_WRAP1 (
    .wclk           (clk        )               ,
    .rclk           (clk        )               ,
    .waddr          (ram_waddr  )               ,
    .raddr          (ram_raddr  )               ,
    .din            (ram_out    )               ,//TODO 
    .wen            (ram_wen    )               ,
    .ren            (ram_ren    )               ,
    .dout           (ram_in     )                
);

//------------------------------------------------------------------------
    initial begin
        #10000000 ;
        $finish();
    end

    string dump_file;
    initial begin
        if($value$plusargs("FSDB=%s",dump_file))
        $display("dump_file = %s",dump_file);
        $fsdbDumpfile(dump_file);
        $fsdbDumpvars(0, fft_tb);
        $fsdbDumpMDA();
    end
//------------------------------------------------------------------------




endmodule