///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 by Heqing Huang (feipenghhq@gamil.com)
//
///////////////////////////////////////////////////////////////////////////////
//
// Project Name: Uart
// Module Name: uart_tx.v
//
// Author: Heqing Huang
// Date Created: 05/06/2019
//
// ================== Description ==================
//
// Uart transmitter logic.
//
//  - Data size can be changed using WIDTH parameter
//  - Clock divider should be the number of clock to transfer 1 bit in Uart
//    User should provide the clock divider number:
//      cfg_clk_div = (clk freqency in Hz / BUADRATE) / SAMPLE RATE
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

module uart_tx #(
    parameter WIDTH = 8,
    parameter SAMPLE_RATE = 16
) (
    input               clk,
    input               rst,
    input [1:0]         cfg_parity,
    input [1:0]         cfg_stop_bits,
    input [15:0]        cfg_clk_div,
    input [WIDTH-1:0]   tx_din,
    input               tx_valid,
    output reg          tx_ready,
    output reg          uart_tx
);

    //==============================
    // Signal Declaration
    //==============================
    reg [2:0]       samples;
    reg             sample_tick;
    reg [15:0]      buad_count;

    // state machine
    parameter IDLE   = 0;
    parameter START  = 1;
    parameter DATA   = 2;
    parameter PARITY = 3;
    parameter STOP   = 4;


    reg [2:0] tx_state;
    reg [7:0] data;
    reg [3:0] data_cnt;
    reg [5:0] sample_cnt;
    reg       parity;
    reg [5:0] stop_cnt_static;

    wire      sampled_all;         // sampled enough pulse (SAMPLE_RATE)

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
            if (buad_count == cfg_clk_div)
            begin
                sample_tick <= 1'b1;
                buad_count  <= 'b0;
            end
            else
            begin
                sample_tick <= 1'b0;
                buad_count  <= buad_count + 1;
            end
        end
    end

    //=================================
    // Uart TX logic
    //=================================
    // Phase: Start, DATA, PARITY, STOP.
    // The time of each phase is controled by the number of sample_tick.
    // 16 sample_tick means the current phase is over and we can
    // move forward to the next phase.

    assign sampled_all = (sample_cnt == SAMPLE_RATE);

    // state machine
    always @(posedge clk)
    begin
        if(rst)
        begin
            tx_state    <= IDLE;
        end
        else
        begin
            case(tx_state)
                IDLE:
                begin
                    if (tx_valid)
                        tx_state <= START;
                end
                START:
                begin
                    if (sampled_all)
                        tx_state <= DATA;
                end
                DATA:
                begin
                    if (data_cnt == WIDTH)
                        tx_state <= (cfg_parity > 0) ? PARITY : STOP;
                end
                PARITY:
                begin
                    if (sampled_all)
                        tx_state <= STOP;
                end
                STOP:
                begin
                    if (sample_cnt == stop_cnt_static)
                        tx_state <= IDLE;
                end
            endcase
        end
    end

    always @(posedge clk)
    begin
        if(rst)
        begin
            data_cnt    <= 'b0;
            data        <= 'b0;
            sample_cnt  <= 'b0;
            parity      <= 'b0;
            uart_tx     <= 1'b1;
            tx_ready       <= 1'b1;
            stop_cnt_static <= 'b0;
        end
        else
        begin
            stop_cnt_static <= (cfg_stop_bits == 2'b00) ? 16 : (cfg_stop_bits == 2'b01) ? 24 : 32;
            case(tx_state)
                IDLE:
                begin
                    sample_cnt  <= 'b0;
                    data        <= tx_din;
                    data_cnt    <= 'b0;
                    tx_ready       <= ~tx_valid;
                end
                START:
                begin
                    sample_cnt  <= sampled_all ? 'b0 : (sample_tick ? sample_cnt + 1 : sample_cnt);
                    uart_tx     <= 1'b0;
                    parity      <= ^data;   // calculate parity here as the data register is untouched here.
                end
                DATA:
                begin
                    sample_cnt  <= sampled_all ? 'b0 : (sample_tick ? sample_cnt + 1 : sample_cnt);
                    data_cnt    <= sampled_all ? data_cnt + 1 : data_cnt;   // increase data count when sampled enough pulse.
                    data        <= sampled_all ? data>>1 : data;
                    uart_tx     <= data[0]; // send lsb first
                end
                PARITY:
                begin
                    sample_cnt  <= sampled_all ? 'b0 : (sample_tick ? sample_cnt + 1 : sample_cnt);
                    uart_tx     <= (cfg_parity == 1) ^ parity;
                end
                STOP:
                begin
                    sample_cnt  <= sample_tick ? sample_cnt + 1 : sample_cnt;
                    uart_tx     <= 1'b1;
                    tx_ready       <= (sample_cnt == stop_cnt_static) ? 1'b1 : 1'b0;
                end
            endcase
        end
    end

endmodule
