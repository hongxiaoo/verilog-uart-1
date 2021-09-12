///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 by Heqing Huang (feipenghhq@gamil.com)
//
///////////////////////////////////////////////////////////////////////////////
//
// Project Name: Uart
// Module Name: uart_rx.v
//
// Author: Heqing Huang
// Date Created: 09/11/2021
//
// ================== Description ==================
//
// Uart receiver logic.
//
//  - Data size can be changed using WIDTH parameter
//  - Clock divider should be the number of clock to transfer 1 bit in Uart
//    User should provide the clock divider number:
//      clk_div = (clk freqency in Hz / BUADRATE) / SAMPLE RATE
//      example: 100MHz clock, 115200 Buadrate, 16 sample_tick per bit
//               clk div = 100 * 1000000 / 115200 / 16  = 54.2 = 54
//  - Configurable parity bit:
//      cfg_parity - 0: no parity bit
//      cfg_parity - 1: odd parity
//      cfg_parity - 2: even parity
//  - Configurable number of stop bit.
//      cfg_stop_bits - 0: 1 bit
//      cfg_stop_bits - 1: 1.5 bit
//      cfg_stop_bits - 2: 2 bit
//
///////////////////////////////////////////////////////////////////////////////

module uart_rx #(
        parameter WIDTH = 8,
        parameter SAMPLE_RATE = 16
    ) (
        input                   clk,
        input                   rst,
        input [1:0]             cfg_parity,
        input [1:0]             cfg_stop_bits,
        input                   uart_rx,
        input [15:0]            clk_div,
        output [WIDTH-1:0]      rx_dout,
        output reg              rx_valid,
        output reg              parity_err
    );

    //==============================
    // Signal Declaration
    //==============================

    reg [2:0]               samples;
    reg                     sample_tick;
    reg [15:0]              buad_count;

    // state machine
    parameter IDLE   = 0;
    parameter START  = 1;
    parameter DATA   = 2;
    parameter PARITY = 3;
    parameter STOP   = 4;


    reg [2:0] rx_state;
    reg [4:0] data_cnt;
    reg [5:0] sample_cnt;
    reg       parity;
    reg [5:0] stop_cnt_static;

    wire sampled_one_bit;    // Sampled enough pulse (SAMPLE_RATE)
    wire uart_rx_sync;
    wire uart_rx_sample;

    reg [WIDTH-1:0] data;

    //=================================
    // Buad sample_tick generation
    //=================================
    // Generate sample_tick pulse to sample_tick uart data based on buad rate.
    // The most commonly used sample_tick rate is 16 times the buad rate,
    // which means that each serial bit is sampled 16 times.

    always @(posedge clk)
    begin
        if (rst)
        begin
            sample_tick <= 1'b0;
            buad_count  <= 'b0;
        end
        else
        begin
            if (buad_count == clk_div)
            begin
                sample_tick <= 1'b1;
                buad_count <= 'b0;
            end
            else
            begin
                sample_tick <= 1'b0;
                buad_count <= buad_count + 1;
            end
        end
    end

    //=================================
    // Uart TX logic
    //=================================
    // Phase: START, DATA, PARITY, STOP.
    // We should sample in the middle of each serial bit.
    // In order to sample_tick in te middle, we first sample_tick half of the sample_tick which
    // give us the middle of the start bit. Then we sample_tick all the sample_tick pulse
    // which will be the middle of the next serial bit.

    // synchronize the input bit
    dsync uart_rx_dsync (.Q(uart_rx_sync), .D(uart_rx), .clk(clk), .rst(rst));

    // input majority vote
    always @(posedge clk)
    begin
        if (rst)
        begin
            samples <= 'b0;
        end
        else
        begin
            samples <= {samples[1:0], uart_rx_sync};
        end
    end

    majority3 sample_majority3(.a(samples[0]), .b(samples[1]), .c(samples[2]), .o (uart_rx_sample));

    assign sampled_one_bit = (sample_cnt == SAMPLE_RATE);
    assign rx_dout = data;

    // state machine
    always @(posedge clk)
    begin
        if(rst)
        begin
            rx_state <= IDLE;
        end
        else
        begin
            case(rx_state)
                IDLE:
                begin
                    if (!uart_rx_sample)
                        rx_state <= START;
                end
                START:
                begin
                    if (uart_rx_sample)
                        rx_state <= IDLE;
                    else if (sample_cnt == SAMPLE_RATE / 2)
                        rx_state <= DATA;
                end
                DATA:
                begin
                    if (data_cnt == WIDTH)
                        rx_state <= (cfg_parity > 0) ? PARITY : STOP;
                end
                PARITY:
                begin
                    if (sampled_one_bit)
                        rx_state <= STOP;
                end
                STOP:
                begin
                    if (sample_cnt == stop_cnt_static)
                        rx_state <= IDLE;
                end
            endcase
        end
    end

    // Output Function Logic
    always @(posedge clk)
    begin
        if(rst)
        begin
            data_cnt    <= 'b0;
            data        <= 'b0;
            rx_valid    <= 'b0;
            sample_cnt  <= 'b0;
            parity      <= 'b0;
            parity_err  <= 'b0;
            stop_cnt_static <= 'b0;
        end
        else
        begin
            stop_cnt_static <= (cfg_stop_bits == 2'b00) ? 16 : (cfg_stop_bits == 2'b01) ? 24 : 32;

            case(rx_state)
                IDLE:
                begin
                    sample_cnt  <= 'b0;
                    data_cnt    <= 'b0;
                    parity      <= 'b0;
                end
                START:
                begin
                    sample_cnt  <= (sample_cnt == SAMPLE_RATE / 2) ? 'b0 : (sample_tick ? sample_cnt + 1 : sample_cnt);
                end
                DATA:
                begin
                    sample_cnt  <= sampled_one_bit ? 'b0 : (sample_tick ? sample_cnt + 1 : sample_cnt);
                    data_cnt    <= sampled_one_bit ? data_cnt + 1 : data_cnt;
                    data        <= sampled_one_bit ? {uart_rx_sample, data[WIDTH-1:1]} : data;
                    parity      <= sampled_one_bit ? parity ^ uart_rx_sample : parity;
                    rx_valid    <= (data_cnt == WIDTH) & (~cfg_parity > 0);        // if no parity check, set the rxvalid here.
                end
                PARITY:
                begin
                    sample_cnt  <= sampled_one_bit ? 'b0 : (sample_tick ? sample_cnt + 1 : sample_cnt);
                    parity_err  <= sampled_one_bit & (parity ^ uart_rx_sample ^ (cfg_parity == 1));
                    rx_valid    <= sampled_one_bit;
                end
                STOP:
                begin
                    rx_valid    <= 1'b0;
                    sample_cnt  <= sample_tick ? sample_cnt + 1 : sample_cnt;
                end
            endcase
        end
    end

endmodule
