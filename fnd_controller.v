`timescale 1ns / 1ps

module fnd_controller (
    input         clk,
    input         rst,
    input         mode,     // To select msec, sec, min, hour 
    input  [23:0] i_time,   //msec 7 , sec 6 , min 6 , hour 5 
    input  [13:0] counter,
    output [ 3:0] fnd_com,
    output [ 7:0] fnd_data
);


    wire [3:0] w_bcd,w_dot_data, w_msec_digit_1, w_msec_digit_10;
    wire [3:0] w_sec_digit_1, w_sec_digit_10;
    wire [3:0] w_min_digit_1, w_min_digit_10;
    wire [3:0] w_hour_digit_1, w_hour_digit_10;
    wire [3:0] w_msec_sec, w_min_hour;


    wire [3:0] w_digit_1;
    wire [3:0] w_digit_10;
    wire [3:0] w_digit_100;
    wire [3:0] w_digit_1000;
    wire [3:0] w_counter;
    wire [1:0] w_sel;
    wire w_clk_1khz;

    clk_div_1khz u_clk_div_1khz (
        .clk(clk),
        .rst(rst),
        .o_clk_1khz(w_clk_1khz)
    );

    counter_4 u_counter_4 (
        .clk  (w_clk_1khz),
        .rst(rst),
        .sel  (w_sel)
    );

    digit_splitter u_digit_splitter (
        .bcd_data(counter),
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000)
    );

    decorder_2x4 u_decorder_2x4 (
        .sel(w_sel),
        .fnd_com(fnd_com)
    );
    //우선순위, 경로의 길이 차이 존재
    //logic 부분에서는 차이X
    mux_4x1 u_mux_4x1 (
        .digit_1(w_digit_1),
        .digit_10(w_digit_10),
        .digit_100(w_digit_100),
        .digit_1000(w_digit_1000),
        .sel(w_sel),
        .bcd(w_counter)
    );

    bcd_decorder u_bcd_decorder (
        .bcd(w_counter),
        .sel(w_sel),
        .fnd_data(fnd_data)
    );




    counter_8 U_COUNTER_8 (
        .clk  (w_clk_1khz),
        .rst(rst),
        .sel  (w_sel)
    );

    digit_splitter2 #(
        .BIT_WIDTH(7)
    ) U_MSEC_DS (
        .counter_data(i_time[6:0]),
        .digit_1(w_msec_digit_1),
        .digit_10(w_msec_digit_10)
    );
    digit_splitter2 #(
        .BIT_WIDTH(6)
    ) U_SEC_DS (
        .counter_data(i_time[12:7]),
        .digit_1(w_sec_digit_1),
        .digit_10(w_sec_digit_10)
    );

    digit_splitter2 #(
        .BIT_WIDTH(6)
    ) U_MIN_DS (
        .counter_data(i_time[18:13]),
        .digit_1(w_min_digit_1),
        .digit_10(w_min_digit_10)
    );
    digit_splitter2 #(
        .BIT_WIDTH(5)
    ) U_HOUR_DS (
        .counter_data(i_time[23:19]),
        .digit_1(w_hour_digit_1),
        .digit_10(w_hour_digit_10)
    );


    bcd_decoder2 U_BCD_DECODER2 (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

    decoder_2x4 U_BCD_DECODER_2x4 (
        .sel(w_sel[1:0]),
        .fnd_com(fnd_com)
    );

    mux_2X1 U_Mux_2x1 (
        .sel(mode),
        .msec_sec(w_msec_sec),
        .min_hour(w_min_hour),
        .bcd(w_bcd)
    );

    
    comparator_msec U_COMP_DOT (
        .msec(i_time[6:0]),
        .dot_data(w_dot_data)
    );


    //min hour
        mux8x1 U_8x1_Msec_Hour(
        .digit_1(w_min_digit_1),
        .digit_10(w_min_digit_10),
        .digit_100(w_hour_digit_1),
        .digit_1000(w_hour_digit_10),
        .digit_5(4'hf),
        .digit_6(4'hf),
        .digit_7(w_dot_data),  // digit dot display
        .digit_8(4'hf),
        .sel(w_sel),
        .bcd(w_min_hour)
    );


    // msec sec
    mux8x1 U_8x1_Msec_Sec(
        .digit_1(w_msec_digit_1),
        .digit_10(w_msec_digit_10),
        .digit_100(w_sec_digit_1),
        .digit_1000(w_sec_digit_10),
        .digit_5(4'hf),
        .digit_6(4'hf),
        .digit_7(w_dot_data),  // digit dot display
        .digit_8(4'hf),
        .sel(w_sel),
        .bcd(w_msec_sec)
    );

endmodule


module clk_div_1khz (
    input  clk,
    input  rst,
    output o_clk_1khz
);  //counter 100,000
    reg [$clog2(100000)-1:0] r_counter;
    //$clog2는 system에서 제공하는 task(함수같은거 인듯)
    reg r_clk_1khz;
    assign o_clk_1khz = r_clk_1khz;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            r_clk_1khz <= 1'b0;
        end else begin
            if (r_counter == 100000 - 1) begin
                r_counter  <= 0;
                r_clk_1khz <= 1'b1;
            end else begin
                r_counter  <= r_counter + 1;
                r_clk_1khz <= 1'b0;
            end
        end
    end

endmodule

module counter_4 (
    input        clk,
    input        rst,
    output [1:0] sel
);

    reg [1:0] counter;
    assign sel = counter;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            //initial
            counter <= 0;
        end else begin
            //operation
            counter <= counter + 1;
        end
    end

endmodule

module digit_splitter (

    input  [13:0] bcd_data,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10,
    output [ 3:0] digit_100,
    output [ 3:0] digit_1000
);

    assign digit_1 = bcd_data % 10;
    assign digit_10 = (bcd_data / 10) % 10;
    assign digit_100 = (bcd_data / 100) % 10;
    assign digit_1000 = (bcd_data / 1000) % 10;

endmodule

module decorder_2x4 (
    input  [1:0] sel,
    output [3:0] fnd_com
);

    assign fnd_com = (sel==2'b00)?4'b1110:
                    (sel==2'b01)?4'b1101:
                    (sel==2'b10)?4'b1011:
                    (sel==2'b11)?4'b0111:4'b1111;

endmodule

module mux_4x1 (
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    input  [1:0] sel,
    output [3:0] bcd
);

    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    always @(*) begin
        case (sel)
            2'b00:   r_bcd = digit_1;
            2'b01:   r_bcd = digit_10;
            2'b10:   r_bcd = digit_100;
            2'b11:   r_bcd = digit_1000;
            default: r_bcd = digit_1;
        endcase
    end

endmodule

module bcd_decorder (
    input [3:0] bcd,
    input [1:0] sel,
    output reg [7:0] fnd_data
);

    always @(bcd) begin
        case (bcd)
            4'b0000: fnd_data = 8'hC0;
            4'b0001: fnd_data = 8'hF9;
            4'b0010: fnd_data = 8'hA4;
            4'b0011: fnd_data = 8'hB0;
            4'b0100: fnd_data = 8'h99;
            4'b0101: fnd_data = 8'h92;
            4'b0110: fnd_data = 8'h82;
            4'b0111: fnd_data = 8'hF8;
            4'b1000: fnd_data = 8'h80;
            4'b1001: fnd_data = 8'h90;
            4'b1010: fnd_data = 8'h88;
            4'b1011: fnd_data = 8'h83;
            4'b1100: fnd_data = 8'hC6;
            4'b1101: fnd_data = 8'hA1;
            4'b1110: fnd_data = 8'h86;
            4'b1111: fnd_data = 8'h8E;
            default: fnd_data = 8'hFF;
        endcase
        if (sel == 2'b01) begin 
            fnd_data[7] = 1'b0; 
        end else begin
            fnd_data[7] = 1'b1;
        end
    end

endmodule

//sel 대신 자동 선택기를 만들기위해




//////////////////down////////////////////////////

module comparator_msec (
    input [6:0] msec,
    output [3:0] dot_data
);

    assign dot_data = (msec < 50) ? 4'hf : 4'he;
    
endmodule




module mux_2X1 (
    input sel,
    input [3:0] msec_sec,
    input [3:0] min_hour,
    output [3:0] bcd
);
    assign bcd = sel ? min_hour : msec_sec;

endmodule






module counter_8 (
    input        clk,
    input        rst,
    output [2:0] sel
);

    reg [2:0] counter;
    assign sel = counter;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            //initial
            counter <= 0;
        end else begin
            //operation
            counter <= counter + 1;
        end
    end


endmodule






module mux8x1 (
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    input [3:0] digit_5,
    input [3:0] digit_6,
    input [3:0] digit_7,  // digit dot display
    input [3:0] digit_8,
    input [2:0] sel,
    output [3:0] bcd
);

    reg [3:0] r_bcd;
    assign bcd = r_bcd;



    always @(*) begin
        case (sel)
            3'b000:  r_bcd = digit_1;
            3'b001:  r_bcd = digit_10;
            3'b010:  r_bcd = digit_100;
            3'b011:  r_bcd = digit_1000;
            3'b100:  r_bcd = digit_5;
            3'b101:  r_bcd = digit_6;
            3'b110:  r_bcd = digit_7;
            3'b111:  r_bcd = digit_8;
            default: r_bcd = digit_1;
        endcase
    end

endmodule

module digit_splitter2 #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH -1:0] counter_data,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1  = counter_data % 10;
    assign digit_10 = (counter_data / 10) % 10;


endmodule




module bcd_decoder2 (
    input      [3:0] bcd,
    output reg [7:0] fnd_data
);
    always @(bcd) begin  //always output = reg
        case (bcd)
            4'b0000: fnd_data = 8'hC0;
            4'b0001: fnd_data = 8'hF9;
            4'b0010: fnd_data = 8'hA4;
            4'b0011: fnd_data = 8'hB0;
            4'b0100: fnd_data = 8'h99;
            4'b0101: fnd_data = 8'h92;
            4'b0110: fnd_data = 8'h82;
            4'b0111: fnd_data = 8'hF8;
            4'b1000: fnd_data = 8'h80;
            4'b1001: fnd_data = 8'h90;
            4'b1010: fnd_data = 8'h88;
            4'b1011: fnd_data = 8'h83;
            4'b1100: fnd_data = 8'hC6;
            4'b1101: fnd_data = 8'hA1;
            4'b1110: fnd_data = 8'h7f;  // only dot display
            4'b1111: fnd_data = 8'hff;  // all off
            default: fnd_data = 8'hff;
        endcase
    end

endmodule
module decoder_2x4 (
    input  [1:0] sel,
    output [3:0] fnd_com
);
    assign fnd_com = (sel==2'b00)  ? 4'b1110:
                     (sel==2'b01)  ? 4'b1101:
                     (sel==2'b10)  ? 4'b1011:
                     (sel==2'b11)  ? 4'b0111:4'b1111;
endmodule