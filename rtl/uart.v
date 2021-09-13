///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 by Heqing Huang (feipenghhq@gamil.com)
//
///////////////////////////////////////////////////////////////////////////////
//
// Project Name: Uart
// Module Name: uart_fifo.v
//
// Author: Heqing Huang
// Date Created: 09/12/2021
//
// ================== Description ==================
//
// Uart transmitter/receiver logic with optional FIFO buffer.
//
///////////////////////////////////////////////////////////////////////////////

module uart #(
        parameter WIDTH = 8,
        parameter SAMPLE_RATE = 16,
        parameter USE_PARITY = 1,
        parameter USE_TX_FIFO = 1,
        parameter USE_RX_FIFO = 1,
        parameter TX_FIFO_DEPTH = 8,
        parameter RX_FIFO_DEPTH = 8

    ) (
        input                   clk,
        input                   rst,
        input [1:0]             cfg_parity,
        input [1:0]             cfg_stop_bits,
        input [15:0]            cfg_clk_div,
        // RX
        input                   rx_req,
        output [WIDTH-1:0]      rx_data,
        output                  rx_ready,
        output                  parity_err,
        input                   uart_rx,
        // TX
        input                   tx_req,
        input [WIDTH-1:0]       tx_din,
        output                  tx_ready,
        output                  uart_tx
    );


    // TX
    generate
        if (USE_TX_FIFO)
        begin: u_uart_tx
            uart_tx_fifo
                #(
                    .WIDTH       (WIDTH),
                    .FIFO_DEPTH  (TX_FIFO_DEPTH)
                )
                u_uart_tx_fifo(
                    .clk           (clk),
                    .rst           (rst),
                    .cfg_parity    (cfg_parity),
                    .cfg_stop_bits (cfg_stop_bits),
                    .cfg_clk_div   (cfg_clk_div),
                    .tx_din        (tx_din),
                    .tx_req        (tx_req),
                    .tx_ready      (tx_ready),
                    .uart_tx       (uart_tx)
                );

        end
        else
        begin: u_uart_tx
            uart_tx
                #(
                    .WIDTH       (WIDTH)
                )
                u_uart_tx(
                    .clk           (clk),
                    .rst           (rst),
                    .cfg_parity    (cfg_parity),
                    .cfg_stop_bits (cfg_stop_bits),
                    .cfg_clk_div   (cfg_clk_div),
                    .tx_din        (tx_din),
                    .tx_valid      (tx_req),
                    .tx_ready      (tx_ready),
                    .uart_tx       (uart_tx)
                );

        end
    endgenerate

    // RX
    generate
        if (USE_RX_FIFO)
        begin: u_uart_rx
            uart_rx_fifo
                #(
                    .WIDTH       (WIDTH),
                    .FIFO_DEPTH  (RX_FIFO_DEPTH),
                    .USE_PARITY  (USE_PARITY)
                )
                u_uart_rx_fifo(
                    .clk           (clk),
                    .rst           (rst),
                    .cfg_parity    (cfg_parity),
                    .cfg_stop_bits (cfg_stop_bits),
                    .cfg_clk_div   (cfg_clk_div),
                    .uart_rx       (uart_rx),
                    .rx_req        (rx_req),
                    .rx_data       (rx_data),
                    .rx_ready      (rx_ready),
                    .parity_err    (parity_err)
                );

        end
        else
        begin: u_uart_rx
            // Need a data buffer for rx without FIFO
            reg [WIDTH-1:0]     rx_data_buffer;
            reg                 rx_data_valid;
            wire [WIDTH-1:0]    rx_dout;
            wire                rx_valid;

            always @(posedge clk)
            begin
                if (rx_valid)
                    rx_data_buffer <= rx_dout;
            end

            always @(posedge clk)
            begin
                if (rst)
                    rx_data_valid <= 1'b0;
                else
                begin
                    if (rx_valid)
                        rx_data_valid <= 1'b1;
                    else if (rx_req && rx_ready)
                        rx_data_valid <= 1'b0;
                end
            end

            assign rx_data = rx_dout;
            assign rx_ready = rx_data_valid;

            uart_rx
                #(
                    .WIDTH       (WIDTH)
                )
                u_uart_rx(
                    .clk           (clk),
                    .rst           (rst),
                    .cfg_parity    (cfg_parity),
                    .cfg_stop_bits (cfg_stop_bits),
                    .cfg_clk_div   (cfg_clk_div),
                    .uart_rx       (uart_rx),
                    .rx_dout       (rx_dout),
                    .rx_valid      (rx_valid),
                    .parity_err    (parity_err)
                );
        end

    endgenerate

endmodule
