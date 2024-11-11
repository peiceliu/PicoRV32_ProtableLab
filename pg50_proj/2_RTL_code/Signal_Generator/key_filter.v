module key_filter(
    input                   clk         ,//系统时钟50MHz
    input                   rst_n       ,//系统复位
    input                   key_in      ,//按键输入
    output   reg            key_flag   ,//输出一个脉冲按键有效信号
    output   reg            key_state    //输出按键状态，1为未按下，0为按下
);
 
 
parameter IDLE      = 4'b0001      ;//空闲状态，读取按键按下的下降沿，读取到下降沿转到下一个状态
parameter FILTER1   = 4'b0010      ;//计数20ms状态，计数结束转到下一个状态
parameter STABLE    = 4'b0100      ;//数据稳定状态，等待按键松开上升沿，读取到上升沿转到下一个状态
parameter FILTER2   = 4'b1000      ;//计数20ms状态，计数结束转到空闲状态
 
parameter TIME_20MS = 20'd1000 ;
 
reg   [  3: 0]         state_c      ;//寄存器改变状态
reg   [  3: 0]         state_n      ;//现在状态
 
wire                   IDLE_to_FILTER1  ;//IDLE状态转到FILTER1状态条件
wire                   FILTER1_to_STABLE;//FILTER1状态转到STABLE状态条件
wire                   STABLE_to_FILTER2;//STABLE状态转到FILTER2状态条件
wire                   FILTER2_to_IDLE  ;//FILTER2状态转到IDLE状态条件
 
reg                    key_in_ff0   ;
reg                    key_in_ff1   ;
reg                    key_in_ff2   ;
 
wire                   key_in_pos   ;//检测上升沿标志
wire                   key_in_neg   ;//检测下降沿标志
 
reg   [ 19: 0]         cnt          ;
wire                   add_cnt      ;
wire                   end_cnt      ;
 
//状态机第一段，状态转换
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        state_c <= IDLE;
    end
    else begin
        state_c <= state_n;
    end
end
 
//状态机第二段，状态转换条件
always  @(*)begin
    case(state_c)
        IDLE   :begin
                    if(IDLE_to_FILTER1)
                        state_n = FILTER1;
                    else
                        state_n = state_c;
                end
        FILTER1:begin
                    if(FILTER1_to_STABLE)
                        state_n = STABLE;
                    else
                        state_n = state_c;
                end
        STABLE :begin
                    if(STABLE_to_FILTER2)
                        state_n = FILTER2;
                    else
                        state_n = state_c;
                end
        FILTER2:begin
                    if(FILTER2_to_IDLE)
                        state_n = IDLE;
                    else
                        state_n = state_c;
                end
        default:state_n = IDLE;
    endcase
end
 
//状态转换条件
assign IDLE_to_FILTER1   = key_in_neg   ;
assign FILTER1_to_STABLE = state_c==FILTER1 && end_cnt;
assign STABLE_to_FILTER2 = key_in_pos   ;
assign FILTER2_to_IDLE   = state_c==FILTER2 && end_cnt;
 
//打两拍，防止亚稳态
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_in_ff0 <= 1;
        key_in_ff1 <= 1;
        key_in_ff2 <= 1;
    end
    else begin
        key_in_ff0 <= key_in;
        key_in_ff1 <= key_in_ff0;
        key_in_ff2 <= key_in_ff1;
    end
end
 
//下降沿和上升沿检测
assign key_in_pos = (state_c==STABLE) ?(key_in_ff1 && !key_in_ff2):1'b0;
assign key_in_neg = (state_c==IDLE) ?(!key_in_ff1 && key_in_ff2):1'b0;
 
//计数20ms
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt <= 0;
    end
    else if(add_cnt)begin
        if(end_cnt)
            cnt <= 0;
        else
            cnt <= cnt + 1'b1;
    end
    else begin
        cnt <= 0;
    end
end
 
assign add_cnt = state_c==FILTER1 || state_c==FILTER2;       
assign end_cnt = add_cnt && cnt== TIME_20MS-1;
 
//key_flag按键按下输出一个脉冲信号
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_flag <= 0;
    end
    else if(state_c==FILTER1 && end_cnt) begin
        key_flag <= 1;
    end
    else begin
        key_flag <= 0;
    end
end
 
//key_state按键按下状态信号
always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        key_state <= 1;
    end
    else if(state_c==STABLE || state_c==FILTER2) begin
        key_state <= 0;
    end
    else begin
        key_state <= 1;
    end
end
endmodule