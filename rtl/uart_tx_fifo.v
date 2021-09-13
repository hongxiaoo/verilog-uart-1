///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 by Heqing Huang (feipenghhq@gamil.com)
//
///////////////////////////////////////////////////////////////////////////////
//
// Project Name: Uart
// Module Name: uart_tx_fifo.v
//
// Author: Heqing Huang
// Date Created: 09/12/2021
//
// ================== Description ==================
//
// Uart transmitter logic with FIFO buffer.
//
///////////////////////////////////////////////////////////////////////////////

module uart_tx_fifo #(
        parameter WIDTH = 8,
        parameter FIFO_DEPTH = 8,
        parameter SAMPLE_RATE = 16
    ) (
        input               clk,
        input               rst,
        input [1:0]         cfg_parity,
        input [1:0]         cfg_stop_bits,
        input [15:0]        cfg_clk_div,
        input [WIDTH-1:0]   tx_din,
        input               tx_req,
        output              tx_ready,
        output              uart_tx
    );

    wire             fifo_write;
    wire             fifo_read;
    wire             fifo_full;
    wire             fifo_empty;

    wire [WIDTH-1:0] uart_tx_din;
    wire             uart_tx_ready;

    assign fifo_write = tx_req & ~fifo_full;
    assign fifo_read = uart_tx_ready & ~fifo_empty;
    assign tx_ready = ~fifo_full;

    fifo_fwft
        #(
            .WIDTH  (WIDTH),
            .DEPTH  (FIFO_DEPTH)
        )
        u_tx_fifo(
            .rst   (rst),
            .clk   (clk),
            .write (fifo_write),
            .read  (fifo_read),
            .din   (tx_din),
            .dout  (uart_tx_din),
            .full  (fifo_full),
            .empty (fifo_empty)
        );


    uart_tx
        #(
            .WIDTH       (WIDTH),
            .SAMPLE_RATE (SAMPLE_RATE)
        )
        u_uart_tx(
            .clk           (clk),
            .rst           (rst),
            .cfg_parity    (cfg_parity),
            .cfg_stop_bits (cfg_stop_bits),
            .cfg_clk_div   (cfg_clk_div),
            .tx_din        (uart_tx_din),
            .tx_valid      (fifo_read),
            .tx_ready      (uart_tx_ready),
            .uart_tx       (uart_tx)
        );


endmodule
