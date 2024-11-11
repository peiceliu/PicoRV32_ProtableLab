module div_fsm#(
    parameter   DATAWIDTH = 10'd8
)
(
  input                         clk,
  input                         rst_n,
  input                         en,
  input     [DATAWIDTH-1:0]     dividend,
  input     [DATAWIDTH-1:0]     divisor,
  
  output                        ready,
  output    [DATAWIDTH-1:0]     quotient,
  output    [DATAWIDTH-1:0]     remainder,
  output                        vld_out
);
//localparam define
localparam IDLE  = 2'b00;
localparam SUB   = 2'b01;
localparam SHIFT = 2'b10;
localparam DONE  = 2'b11;
//reg define
reg [DATAWIDTH * 2'd2 - 1'b1:0] dividend_e;
reg [DATAWIDTH * 2'd2 - 1'b1:0] divisor_e;
reg [DATAWIDTH - 1'b1:0]        quotient_e;
reg [DATAWIDTH - 1'b1:0]        remainder_e;
reg [1:0]                       current_state;
reg [1:0]                       next_state;
reg [DATAWIDTH-1'b1:0]          count;

//*****************************************************
//**                    main code
//*****************************************************

// 赋值 
assign quotient  = quotient_e;
assign remainder = remainder_e;

// 产生使能信号
assign ready=(current_state==IDLE)? 1'b1:1'b0;
assign vld_out=(current_state==DONE)? 1'b1:1'b0;

// 状态跳转
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        current_state <= IDLE;
    else 
        current_state <= next_state;
end

always@(*)begin
    next_state <= 2'bx;
    case(current_state)
        IDLE: begin
            if(en)
                next_state <=  SUB;
            else
                next_state <=  IDLE;
        end
        SUB:  next_state <= SHIFT;
        SHIFT: begin
            if(count<DATAWIDTH) 
                next_state <= SUB;
            else 
                next_state <= DONE;
        end
        DONE: next_state <= IDLE;
        default:next_state <= IDLE;
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        dividend_e  <= 1'b0;
        divisor_e   <= 1'b0;
        quotient_e  <= 1'b0;
        remainder_e <= 1'b0;
        count       <= 1'b0;
        end
    else begin
        case(current_state)
            IDLE:begin
                dividend_e <= {{DATAWIDTH{1'b0}},dividend};
                divisor_e  <= {divisor,{DATAWIDTH{1'b0}}};
                end
            SUB:begin
                if(dividend_e>=divisor_e)begin
                    quotient_e <= {quotient_e[DATAWIDTH-2'd2:0],1'b1};
                    dividend_e <= dividend_e-divisor_e;
                    end
                else begin
                    quotient_e <= {quotient_e[DATAWIDTH-2'd2:0],1'b0};
                    dividend_e <= dividend_e;
                end
                end
            SHIFT:begin
                if(count<DATAWIDTH)begin
                    dividend_e <= (dividend_e << 1'b1);
                    count      <= count + 1'b1;      
                    end
                else begin
                    remainder_e <= dividend_e[DATAWIDTH*2-1:DATAWIDTH];
                end
                end
            DONE:begin
                count <= 1'b0;
                end    
        endcase
    end
end

endmodule