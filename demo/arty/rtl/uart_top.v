///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 by Heqing Huang (feipenghhq@gamil.com)
//
///////////////////////////////////////////////////////////////////////////////
//
// Project Name: Uart
// Module Name: uart_top.v
//
// Author: Heqing Huang
// Date Created: 09/12/2021
//
// ================== Description ==================
//
// Uart Top level for FPGA
//
///////////////////////////////////////////////////////////////////////////////


module uart_top (
    input clk,
    input rst_n,
    input uart_rx,
    output uart_tx
    );

    parameter WIDTH = 8;
    parameter SAMPLE_RATE = 16;
    parameter CLK_FEQ = 100; // clock frequency in MHZ
    parameter BUADRATE = 115200;

    wire                rst = ~rst_n;
    wire [1:0]          cfg_parity = 0;
    wire [1:0]          cfg_stop_bits = 0;
    wire [15:0]         cfg_clk_div = (CLK_FEQ * 1000000 / SAMPLE_RATE / BUADRATE);
    // RX
    wire                rx_req;
    wire [WIDTH-1:0]    rx_data;
    wire                rx_ready;
    wire                parity_err;

    // TX
    wire                tx_req;
    wire [WIDTH-1:0]    tx_din;
    wire                tx_ready;

    assign rx_req = tx_ready & rx_ready;
    assign tx_req = rx_req;
    assign tx_din = rx_data;

    uart
        #(
            .WIDTH         (WIDTH),
            .SAMPLE_RATE   (SAMPLE_RATE),
            .USE_PARITY    (1),
            .USE_TX_FIFO   (1),
            .USE_RX_FIFO   (1),
            .TX_FIFO_DEPTH (8),
            .RX_FIFO_DEPTH (8)
        )
        u_uart(
            .clk           (clk           ),
            .rst           (rst           ),
            .cfg_parity    (cfg_parity    ),
            .cfg_stop_bits (cfg_stop_bits ),
            .cfg_clk_div   (cfg_clk_div   ),
            .rx_req        (rx_req        ),
            .rx_data       (rx_data       ),
            .rx_ready      (rx_ready      ),
            .parity_err    (parity_err    ),
            .uart_rx       (uart_rx       ),
            .tx_req        (tx_req        ),
            .tx_din        (tx_din        ),
            .tx_ready      (tx_ready      ),
            .uart_tx       (uart_tx       )
        );

endmodule
