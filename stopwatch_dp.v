`timescale 1ns / 1ps

module stopwatch_dp (
    input clk,
    input rst,
    input i_runstop,
    input i_clear,
    output [4:0] hour,
    output [6:0] msec,
    output [5:0] min,
    output [5:0] sec  // 0~99까지 100카운트이므로 7비트면 충분
);
    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;
        time_counter #(
        .BIT_WIDTH (5),
        .TIME_COUNT(24)
    ) U_hour_COUNTER (
        .clk   (clk),
        .rst   (rst),
        .i_tick(w_hour_tick),
        .i_clear(i_clear),
        .o_time(hour),
        .o_tick()     
    );


    time_counter #(
        .BIT_WIDTH (6),
        .TIME_COUNT(60)
    ) U_MIN_COUNTER (
        .clk   (clk),
        .rst   (rst),
        .i_tick(w_min_tick),
        .i_clear(i_clear),
        .o_time(min),
        .o_tick(w_hour_tick)     
    );
    // 0~99까지 counting, 100Hz 기준 1초마다 0으로 리셋됨
    time_counter #(
        .BIT_WIDTH (7),
        .TIME_COUNT(100)
    ) U_MSEC_COUNTER (
        .clk   (clk),
        .rst   (rst),
        .i_tick(w_tick_100hz),
        .i_clear(i_clear),
        .o_time(msec),
        .o_tick(w_sec_tick)     
    );
    time_counter #(
        .BIT_WIDTH (6),
        .TIME_COUNT(60)
    ) U_SEC_COUNTER (
        .clk    (clk),
        .rst    (rst),
        .i_tick (w_sec_tick),
        .i_clear(i_clear),
        .o_time (sec),
        .o_tick (w_min_tick)             
    );

    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .rst(rst),
        .i_runstop(i_runstop),
        .o_tick_100hz(w_tick_100hz)
    );
endmodule











// msec_counter
module time_counter #(
    parameter BIT_WIDTH  = 7,
    parameter TIME_COUNT = 100
) (
    input                  clk,
    input                  rst,
    input                  i_tick,
    input                  i_clear,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick
);
    reg [$clog2(TIME_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            tick_reg  <= 1'b0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next  = tick_reg;  //1'b0;

        if (i_tick) begin
            if (count_reg == TIME_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next  = 1'b0;
            end
        end else begin
            tick_next = 1'b0;
        end
        if (i_clear == 1'b1) begin
            count_next = 0;
        end
    end
endmodule



module tick_gen_100hz #(
    parameter FREQ_HZ = 100_000_000,  // 입력 클럭
    parameter TICK_HZ = 100           // 출력 펄스 주파수
) (
    input  clk,
    input  rst,
    input  i_runstop,
    output o_tick_100hz
);
    localparam integer FCOUNT = FREQ_HZ / TICK_HZ;
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_tick;

    assign o_tick_100hz = r_tick; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            r_tick    <= 1'b0;
        end else begin
            if (i_runstop == 1'b1) begin
                // true

                if (r_counter == FCOUNT - 1) begin
                    r_counter <= 0;
                    r_tick    <= 1'b1;
                end else begin
                    r_counter <= r_counter + 1;
                    r_tick    <= 1'b0;
                end
            end else begin

                r_counter <= r_counter;
            end
           
        end
    end
endmodule

