`timescale 1ns / 1ps
module uart2_top (
    input  clk,
    input  rst,
    input  rx,
    output tx,
    output Rx_trigger,
    output [7:0] Rx_fifo_data
); 

    wire w_start, w_b_tick;
    wire rx_done;
    wire [7:0] w_rx_data, w_rx_fifo_popdata, w_tx_fifo_popdata;
    wire w_rx_empty, w_tx_fifo_full, w_tx_fifo_empty, w_tx_busy;


    assign Rx_fifo_data = w_rx_fifo_popdata;
    assign Rx_trigger = ~ w_rx_empty;
    uart2_tx U_UART2_TX (
        .clk          (clk),
        .rst          (rst),
        .start_trigger(~w_tx_fifo_empty),
        .tx_data      (w_tx_fifo_popdata),
        .b_tick       (w_b_tick),
        .tx           (tx),
        .tx_busy      (w_tx_busy)
    );

    fifo2 U_TX2_FIFO (
        .clk      (clk),
        .rst      (rst),
        .push_data(w_rx_fifo_popdata),
        .push     (~w_rx_empty),
        .pop      (~w_tx_busy),         //from uart tx
        .pop_data (w_tx_fifo_popdata),  // to uart tx
        .full     (w_tx_fifo_full),
        .empty    (w_tx_fifo_empty)     // to uart tx
    );
    fifo2 U_RX2_FIFO (
        .clk      (clk),
        .rst      (rst),
        .push_data(w_rx_data),          // from uart rx
        .push     (rx_done),            // from uart rx
        .pop      (~w_tx_fifo_full),    // to tx fifo
        .pop_data (w_rx_fifo_popdata),  // to tx fifo
        .full     (),
        .empty    (w_rx_empty)          // to tx fifo
    );
    uart2_rx U_UART2_RX (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .b_tick(w_b_tick),
        .rx_data(w_rx_data),
        .rx_done(rx_done)
    );

    baud_tick_gen2 U_BAUD_TICK_GEN2 (
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick)
    );

endmodule

module baud_tick_gen2 (
    input  clk,
    input  rst,
    output b_tick
);
    // baudrate 
    parameter BAUDRATE = 9600 * 16;
    localparam BAUD_COUNT = 100_000_000 / BAUDRATE;
    reg [$clog2(BAUD_COUNT)-1 : 0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    // output
    assign b_tick = tick_reg;

    // SL
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_reg <= 1'b0;
        end else begin
            counter_reg <= counter_next;
            tick_reg <= tick_next;
        end
    end
    // next CL
    always @(*) begin
        counter_next = counter_reg;
        tick_next = tick_reg;
        if (counter_reg == BAUD_COUNT - 1) begin
            counter_next = 0;
            tick_next = 1'b1;
        end else begin
            counter_next = counter_reg + 1;
            tick_next = 1'b0;
        end
    end

endmodule
