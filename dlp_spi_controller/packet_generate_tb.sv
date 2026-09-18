module packet_generate (
    input  logic        clk,            // 系统时钟
    input  logic        rst_n,          // 异步低有效复位
    input  logic        trigger,        // 触发信号，上升沿触发
    input  logic [31:0] length,         // 数据包长度（字节）
    output logic        start,          // 启动信号（脉冲）
    output logic [31:0] data_in,        // 输出数据
    output logic        data_in_valid,  // 数据有效信号
    input  logic        data_in_ready,  // 下游就绪信号
    input  logic        busy,           // 外部忙碌信号（来自 spi_packet_tx 的 sending）
    output logic        error           // 错误信号（握手超时或非法长度）
);

    // 参数
    localparam TIMEOUT_LIMIT = 16'hFFFF; // 握手超时阈值
    localparam WORD_SIZE = 4;            // 字大小（字节）

    // 状态机定义
    typedef enum logic [1:0] {
        GEN_IDLE,   // 空闲，等待触发
        GEN_START,  // 发送启动信号
        GEN_DATA,   // 发送数据
        GEN_ERROR   // 错误状态
    } state_t;

    state_t state, next_state;

    // 内部信号
    logic [31:0] data_cnt;       // 数据计数器（字）
    logic [31:0] word_cnt;       // 数据包字数（length / 4）
    logic [31:0] data_word;      // 当前数据
    logic        start_r;        // 启动信号寄存器
    logic        data_valid_r;   // 数据有效信号寄存器
    logic        trigger_r;      // 触发信号寄存器
    logic        trigger_pos;    // 触发上升沿
    logic [15:0] timeout_cnt;    // 超时计数器
    logic        timeout;        // 超时标志
    logic        length_error;   // 非法长度标志

    // 触发边沿检测
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            trigger_r <= '0;
        else
            trigger_r <= trigger;
    end
    assign trigger_pos = trigger & ~trigger_r;

    // 计算字数并检查长度
    assign word_cnt = length >> 2; // 字节数转换为字数
    assign length_error = (length == '0) || (length[1:0] != 2'b00); // 长度为 0 或非 4 字节对齐

    // 状态寄存器
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= GEN_IDLE;
        else
            state <= next_state;
    end

    // 状态转移逻辑
    always_comb begin
        next_state = state;
        case (state)
            GEN_IDLE: begin
                if (trigger_pos && !busy && !length_error)
                    next_state = GEN_START;
                else if (trigger_pos && length_error)
                    next_state = GEN_ERROR;
            end
            GEN_START:
                next_state = GEN_DATA;
            GEN_DATA: begin
                if (timeout || length_error)
                    next_state = GEN_ERROR;
                else if (data_cnt >= (word_cnt - 1) && data_in_ready)
                    next_state = GEN_IDLE;
            end
            GEN_ERROR:
                if (!busy)
                    next_state = GEN_IDLE;
        endcase
    end
    
always_comb begin 
    data_word = '0; // 默认值
    case (state)
        GEN_DATA: begin
            if (data_in_ready && data_in_valid) begin
                data_word = {4{data_cnt[7:0]}}; // 生成数据包内容
            end else begin
                data_word = '0; // 如果不就绪，输出0
            end
        end
        default: begin
            data_word = '0; // 其他状态输出0
        end
    endcase 
end 




    // 寄存器逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_r       <= '0;
            data_valid_r  <= '0;
            data_cnt      <= '0;
            timeout_cnt   <= '0;
            timeout       <= '0;
            error         <= '0;
        end else begin
            start_r      <= '0;
            data_valid_r <= '0;
            timeout_cnt  <= '0;
            error        <= '0;


            case (state)
                GEN_IDLE: begin
                    data_cnt   <= '0;
                    timeout    <= '0;
                end
                GEN_START: begin
                    start_r    <= '1;
                end
                GEN_DATA: begin

                    data_valid_r <= '1;

                    if (data_in_ready && data_in_valid ) begin
                        data_cnt     <= data_cnt + 1;
                        
                        if (data_cnt == word_cnt - 1) begin
                            data_valid_r <= '0; // 最后一个数据包后不再有效
                        end

                    end
                    if (!data_in_ready && data_valid_r) begin
                        timeout_cnt <= timeout_cnt + 1;
                        if (timeout_cnt == TIMEOUT_LIMIT - 1)
                            timeout <= '1;
                    end
                end
                GEN_ERROR: begin
                    error <= '1;
                end
            endcase
        end
    end

    // 输出信号
    assign start         = start_r;
    assign data_in       = data_word;
    assign data_in_valid = data_valid_r;

endmodule