`timescale 1ns / 1ps

module uart2_cu (
    input clk,
    input rst,
    input Rx_trigger,
    input [7:0] Rx_fifo_data,
    output o_run_stop


);
    parameter IDLE = 2'b00, RECEIVE = 2'b01, OUT = 2'b10;
    reg [1:0] c_state, n_state;
    reg run_stop, run_stop_next;
    //output 
    assign o_run_stop = run_stop;
    //assign 
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state  <= IDLE;
            run_stop <= 0;
        end else begin
            c_state  <= n_state;
            run_stop <= run_stop_next;
        end
    end

    //next combinational logic
    always @(*) begin
        n_state = c_state;
        run_stop_next = run_stop;
        case (c_state)
            IDLE: begin
                run_stop_next = 1'b0;
                if (Rx_trigger == 1) begin
                    n_state = RECEIVE;
                end
            end
            RECEIVE: begin
                if (Rx_fifo_data == 8'h72) begin
                    run_stop_next = 1'b1;
                end else if (Rx_fifo_data == 8'h73) begin
                    run_stop_next = 1'b0;
                end
                n_state = IDLE;
            end
        endcase
    end
endmodule
