`timescale 1ns / 1ps

module stopwatch (
    input        clk,
    input        rst,
    input        Btn_U,    //clear L -> U
    input        Btn_W,    //runstop
    input        mode,     //sw[0]에 할당
    input        rx,
    output       tx,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [6:0] w_msec;
    wire [5:0] w_sec;
    wire [5:0] w_min;
    wire [4:0] w_hour;


    wire       w_btn_u;
    wire       w_btn_w;
    wire       w_rx_trigger;
    wire [7:0] w_fifo_data;  // UART에서 받은 데이터 (8비트)
    wire       w_cmd_runstop;  // command_cu 출력 (1비트)
    wire       w_runstop_or;  // 버튼 + UART OR 결과 (1비트)

    assign w_runstop_or = w_btn_w | w_cmd_runstop;

    uart2_top U_UART_TOP (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .Rx_trigger(w_rx_trigger),
        .Rx_fifo_data(w_fifo_data)
    );

    uart2_cu U_UART2_CU (
        .clk(clk),
        .rst(rst),
        .Rx_trigger(w_rx_trigger),
        .Rx_fifo_data(w_fifo_data),
        .o_run_stop(w_cmd_runstop)
    );



    button_debounce U_BD_RUNSTOP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_W),
        .o_btn(w_btn_w)
    );

    button_debounce U_BD_CLEAR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_U),
        .o_btn(w_btn_u)
    );
    stopwatch_dp U_SW_DP (
        .clk(clk),
        .rst(rst),
        .i_runstop(w_runstop),
        .i_clear(w_clear),
        .msec(w_msec),
        .sec(w_sec),
        .hour(w_hour),
        .min(w_min)
    );

    stopwatch_cu U_SW_CU (
        .clk(clk),
        .rst(rst),
        .i_runstop(w_runstop_or),
        .i_clear(w_btn_u),
        .o_runstop(w_runstop),
        .o_clear(w_clear)
    );
    // fnd_controller U_FND_CNTL (
    //     .clk(clk),
    //     .reset(rst),
    //     .mode(mode),
    //     .i_time({w_hour, w_min, w_sec, w_msec}),
    //     .fnd_com(fnd_com),
    //     .fnd_data(fnd_data)

    // );

endmodule
