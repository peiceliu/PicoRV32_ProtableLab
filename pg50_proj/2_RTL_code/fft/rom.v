module factor_rom (
    input                       clk         ,
    input                       rst_n       ,
    input       [7:0]           factor_addr ,
    input                       factor_en   ,
    output reg  [14:0]          factor_real ,
    output reg  [14:0]          factor_imag //
);

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        factor_real <= 'd0;
        factor_imag <= 'd0;
    end else begin
        if (factor_en) begin
            case(factor_addr)
            8'd0 : begin factor_real <= 15'h2000;factor_imag <= 15'h0000; end
            8'd1 : begin factor_real <= 15'h1FFD;factor_imag <= 15'h00C9; end
            8'd2 : begin factor_real <= 15'h1FF6;factor_imag <= 15'h0191; end
            8'd3 : begin factor_real <= 15'h1FE9;factor_imag <= 15'h025A; end
            8'd4 : begin factor_real <= 15'h1FD8;factor_imag <= 15'h0322; end
            8'd5 : begin factor_real <= 15'h1FC2;factor_imag <= 15'h03EA; end
            8'd6 : begin factor_real <= 15'h1FA7;factor_imag <= 15'h04B2; end
            8'd7 : begin factor_real <= 15'h1F87;factor_imag <= 15'h0578; end
            8'd8 : begin factor_real <= 15'h1F62;factor_imag <= 15'h063E; end
            8'd9 : begin factor_real <= 15'h1F38;factor_imag <= 15'h0702; end
            8'd10: begin factor_real <= 15'h1F0A;factor_imag <= 15'h07C6; end
            8'd11: begin factor_real <= 15'h1ED7;factor_imag <= 15'h0888; end
            8'd12: begin factor_real <= 15'h1E9F;factor_imag <= 15'h094A; end
            8'd13: begin factor_real <= 15'h1E62;factor_imag <= 15'h0A09; end
            8'd14: begin factor_real <= 15'h1E21;factor_imag <= 15'h0AC7; end
            8'd15: begin factor_real <= 15'h1DDB;factor_imag <= 15'h0B84; end
            8'd16: begin factor_real <= 15'h1D90;factor_imag <= 15'h0C3E; end
            8'd17: begin factor_real <= 15'h1D41;factor_imag <= 15'h0CF7; end
            8'd18: begin factor_real <= 15'h1CED;factor_imag <= 15'h0DAE; end
            8'd19: begin factor_real <= 15'h1C95;factor_imag <= 15'h0E63; end
            8'd20: begin factor_real <= 15'h1C38;factor_imag <= 15'h0F15; end
            8'd21: begin factor_real <= 15'h1BD7;factor_imag <= 15'h0FC5; end
            8'd22: begin factor_real <= 15'h1B72;factor_imag <= 15'h1073; end
            8'd23: begin factor_real <= 15'h1B09;factor_imag <= 15'h111E; end
            8'd24: begin factor_real <= 15'h1A9B;factor_imag <= 15'h11C7; end
            8'd25: begin factor_real <= 15'h1A29;factor_imag <= 15'h126D; end
            8'd26: begin factor_real <= 15'h19B3;factor_imag <= 15'h130F; end
            8'd27: begin factor_real <= 15'h193A;factor_imag <= 15'h13AF; end
            8'd28: begin factor_real <= 15'h18BC;factor_imag <= 15'h144C; end
            8'd29: begin factor_real <= 15'h183B;factor_imag <= 15'h14E6; end
            8'd30: begin factor_real <= 15'h17B5;factor_imag <= 15'h157D; end
            8'd31: begin factor_real <= 15'h172D;factor_imag <= 15'h1610; end
            8'd32: begin factor_real <= 15'h16A0;factor_imag <= 15'h16A0; end
            8'd33: begin factor_real <= 15'h1610;factor_imag <= 15'h172D; end
            8'd34: begin factor_real <= 15'h157D;factor_imag <= 15'h17B5; end
            8'd35: begin factor_real <= 15'h14E6;factor_imag <= 15'h183B; end
            8'd36: begin factor_real <= 15'h144C;factor_imag <= 15'h18BC; end
            8'd37: begin factor_real <= 15'h13AF;factor_imag <= 15'h193A; end
            8'd38: begin factor_real <= 15'h130F;factor_imag <= 15'h19B3; end
            8'd39: begin factor_real <= 15'h126D;factor_imag <= 15'h1A29; end
            8'd40: begin factor_real <= 15'h11C7;factor_imag <= 15'h1A9B; end
            8'd41: begin factor_real <= 15'h111E;factor_imag <= 15'h1B09; end
            8'd42: begin factor_real <= 15'h1073;factor_imag <= 15'h1B72; end
            8'd43: begin factor_real <= 15'h0FC5;factor_imag <= 15'h1BD7; end
            8'd44: begin factor_real <= 15'h0F15;factor_imag <= 15'h1C38; end
            8'd45: begin factor_real <= 15'h0E63;factor_imag <= 15'h1C95; end
            8'd46: begin factor_real <= 15'h0DAE;factor_imag <= 15'h1CED; end
            8'd47: begin factor_real <= 15'h0CF7;factor_imag <= 15'h1D41; end
            8'd48: begin factor_real <= 15'h0C3E;factor_imag <= 15'h1D90; end
            8'd49: begin factor_real <= 15'h0B84;factor_imag <= 15'h1DDB; end
            8'd50: begin factor_real <= 15'h0AC7;factor_imag <= 15'h1E21; end
            8'd51: begin factor_real <= 15'h0A09;factor_imag <= 15'h1E62; end
            8'd52: begin factor_real <= 15'h094A;factor_imag <= 15'h1E9F; end
            8'd53: begin factor_real <= 15'h0888;factor_imag <= 15'h1ED7; end
            8'd54: begin factor_real <= 15'h07C6;factor_imag <= 15'h1F0A; end
            8'd55: begin factor_real <= 15'h0702;factor_imag <= 15'h1F38; end
            8'd56: begin factor_real <= 15'h063E;factor_imag <= 15'h1F62; end
            8'd57: begin factor_real <= 15'h0578;factor_imag <= 15'h1F87; end
            8'd58: begin factor_real <= 15'h04B2;factor_imag <= 15'h1FA7; end
            8'd59: begin factor_real <= 15'h03EA;factor_imag <= 15'h1FC2; end
            8'd60: begin factor_real <= 15'h0322;factor_imag <= 15'h1FD8; end
            8'd61: begin factor_real <= 15'h025A;factor_imag <= 15'h1FE9; end
            8'd62: begin factor_real <= 15'h0191;factor_imag <= 15'h1FF6; end
            8'd63: begin factor_real <= 15'h00C9;factor_imag <= 15'h1FFD; end
            endcase
        end
    end
end


endmodule