///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 by Heqing Huang (feipenghhq@gamil.com)
//
///////////////////////////////////////////////////////////////////////////////
//
// Project Name: Uart
// Module Name: uart_rx_fifo.v
//
// Author: Heqing Huang
// Date Created: 09/12/2021
//
// ================== Description ==================
//
// Uart receiver logic with FIFO buffer.
//
///////////////////////////////////////////////////////////////////////////////

module uart_rx_fifo #(
        parameter WIDTH = 8,
        parameter FIFO_DEPTH = 8,
        parameter SAMPLE_RATE = 16,
        parameter USE_PARITY = 1
    ) (
        input                   clk,
        input                   rst,
        input [1:0]             cfg_parity,
        input [1:0]             cfg_stop_bits,
        input [15:0]            cfg_clk_div,
        input                   uart_rx,
        input                   rx_req,    // read the fifo
        output [WIDTH-1:0]      rx_data,
        output                  rx_ready,   // indicate rx fifo is not empty
        output                  parity_err
    );

    parameter FIFO_WIDTH = WIDTH + (USE_PARITY == 1 ? 1: 0);

    wire             fifo_write;
    wire             fifo_read;
    wire             fifo_full;
    wire             fifo_empty;

    wire [WIDTH-1:0] uart_rx_dout;
    wire             rx_valid;
    wire             rx_parity_err;

    wire [FIFO_WIDTH-1:0] fifo_din;
    wire [FIFO_WIDTH-1:0] fifo_dout;

    assign fifo_write = rx_valid & ~fifo_full;
    assign fifo_read = rx_req & ~fifo_empty;
    assign rx_ready = ~fifo_empty;

    generate
        if (USE_PARITY)
        begin
            assign fifo_din = {rx_parity_err, uart_rx_dout};
            assign rx_data = fifo_dout[WIDTH-1:0];
            assign parity_err = fifo_dout[WIDTH];
        end
        else
        begin
            assign fifo_din = uart_rx_dout;
            assign rx_data = fifo_dout[WIDTH-1:0];
            assign parity_err = 0;
        end
    endgenerate

    fifo_fwft
        #(
            .WIDTH  (FIFO_WIDTH),
            .DEPTH  (FIFO_DEPTH)
        )
        u_rx_fifo(
            .rst   (rst),
            .clk   (clk),
            .write (fifo_write),
            .read  (fifo_read),
            .din   (fifo_din),
            .dout  (fifo_dout),
            .full  (fifo_full),
            .empty (fifo_empty)
        );


    uart_rx
        #(
            .WIDTH       (WIDTH),
            .SAMPLE_RATE (SAMPLE_RATE)
        )
        u_uart_rx(
            .clk           (clk),
            .rst           (rst),
            .cfg_parity    (cfg_parity),
            .cfg_stop_bits (cfg_stop_bits),
            .cfg_clk_div   (cfg_clk_div),
            .uart_rx       (uart_rx),
            .rx_dout       (uart_rx_dout),
            .rx_valid      (rx_valid),
            .parity_err    (rx_parity_err)
        );


endmodule
