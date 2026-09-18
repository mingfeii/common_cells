module unpack_raw #(
    parameter int PW   = 10,
    parameter int LANE = 4,
    parameter int DW   = LANE * 8
)(
    input  logic               clk,
    input  logic               rst_n,
    output logic               i_rdy,
    input  logic               i_val,
    input  logic [DW-1:0]      i_data,
    output logic               o_val,
    input  logic               o_rdy,
    output logic [PW*LANE-1:0] o_data
);

    localparam int IN_BYTES    = DW / 8;
    localparam int GROUP_BYTES = (PW == 10) ? 5 : (PW == 16) ? (2 * LANE) : 0;
    localparam int BUF_BYTES   = 2 * GROUP_BYTES + IN_BYTES;
    localparam int BUF_BITS    = BUF_BYTES * 8;
    localparam int CNT_W       = (BUF_BYTES <= 1) ? 1 : $clog2(BUF_BYTES + 1);

    logic [BUF_BITS-1:0] byte_buf;
    logic [CNT_W-1:0]    byte_cnt;
    logic [CNT_W-1:0]    nxt_cnt;
    logic pop, push;
    logic o_val_r, i_rdy_r;

    assign o_val = o_val_r;
    assign i_rdy = i_rdy_r;
    assign pop   = o_val && o_rdy;
    assign push  = i_val && i_rdy;

    always_comb begin
        case ({push, pop})
            2'b00:   nxt_cnt = byte_cnt;
            2'b10:   nxt_cnt = byte_cnt + IN_BYTES;
            2'b01:   nxt_cnt = byte_cnt - GROUP_BYTES;
            2'b11:   nxt_cnt = byte_cnt - GROUP_BYTES + IN_BYTES;
            default: nxt_cnt = byte_cnt;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_val_r <= 1'b0;
            i_rdy_r <= 1'b1;
        end else begin
            o_val_r <= (nxt_cnt >= GROUP_BYTES);
            i_rdy_r <= ((nxt_cnt + IN_BYTES) <= BUF_BYTES);
        end
    end

    generate
        if (PW == 10) begin : g_raw10
            logic [7:0] b0, b1, b2, b3, b4;
            logic [9:0] p0, p1, p2, p3;

            always_comb begin
                b0 = byte_buf[ 7: 0]; b1 = byte_buf[15: 8];
                b2 = byte_buf[23:16]; b3 = byte_buf[31:24];
                b4 = byte_buf[39:32];
                p0 = {b0, b4[1:0]}; p1 = {b1, b4[3:2]};
                p2 = {b2, b4[5:4]}; p3 = {b3, b4[7:6]};
                o_data = '0;
                o_data[0*PW +: PW] = p0; o_data[1*PW +: PW] = p1;
                o_data[2*PW +: PW] = p2; o_data[3*PW +: PW] = p3;
            end
        end else if (PW == 16) begin : g_raw16
            always_comb begin
                o_data = '0;
                for (int i = 0; i < LANE; i++)
                    o_data[i*PW +: PW] = {byte_buf[(2*i)*8 +: 8], byte_buf[(2*i+1)*8 +: 8]};
            end
        end else begin : g_unsupported
            always_comb o_data = '0;
        end
    endgenerate

    // Oldest byte is byte_buf[7:0]. Push appends, pop removes GROUP_BYTES.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_buf <= '0;
            byte_cnt <= '0;
        end else begin
            case ({push, pop})
                2'b00: begin
                    byte_buf <= byte_buf;
                    byte_cnt <= byte_cnt;
                end
                2'b10: begin
                    byte_buf <= byte_buf | ({{(BUF_BITS-DW){1'b0}}, i_data} << (byte_cnt * 8));
                    byte_cnt <= byte_cnt + IN_BYTES;
                end
                2'b01: begin
                    byte_buf <= byte_buf >> (GROUP_BYTES * 8);
                    byte_cnt <= byte_cnt - GROUP_BYTES;
                end
                2'b11: begin
                    byte_buf <= (byte_buf >> (GROUP_BYTES * 8)) |
                                ({{(BUF_BITS-DW){1'b0}}, i_data} << ((byte_cnt - GROUP_BYTES) * 8));
                    byte_cnt <= byte_cnt - GROUP_BYTES + IN_BYTES;
                end
            endcase
        end
    end

`ifndef SYNTHESIS
    initial begin
        if (DW % 8 != 0) $error("unpack_raw: DW must be byte aligned");
        if (PW != 10 && PW != 16) $error("unpack_raw: only RAW10 / RAW16 supported");
        if (PW == 10 && LANE != 4) $error("unpack_raw: RAW10 implementation expects LANE=4");
    end
`endif

endmodule
