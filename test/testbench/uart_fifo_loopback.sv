///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 by Heqing Huang (feipenghhq@gamil.com)
//
///////////////////////////////////////////////////////////////////////////////
//
// Project Name:
// Module Name: uart_fifo_loopback.sv
//
// Author: Heqing Huang
// Date Created: 11/07/2020
//
// ================== Description ==================
//
// Testing uart with fifo buffer using self TX->RX loopback
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

module uart_fifo_loopback;

    // Parameters
    localparam  WIDTH = 8;
    localparam  SAMPLE_RATE = 16;
    localparam  USE_PARITY = 1;
    localparam  USE_TX_FIFO = 1;
    localparam  USE_RX_FIFO = 1;
    localparam  TX_FIFO_DEPTH = 8;
    localparam  RX_FIFO_DEPTH = 8;

    // Ports
    reg clk = 0;
    reg rst = 0;
    reg [1:0] cfg_parity = 0;
    reg [1:0] cfg_stop_bits = 0;
    reg [15:0] cfg_clk_div = (100 * 1000000 / 115200 / SAMPLE_RATE);
    reg rx_req = 0;
    wire [WIDTH-1:0] rx_data;
    wire rx_ready;
    wire parity_err;
    reg uart_rx = 0;
    reg tx_req = 0;
    reg [WIDTH-1:0] tx_din;
    wire tx_ready;
    wire uart_tx;

    integer txdata = 0;
    integer rxdata = 0;
    integer error = 0;

    // loopback

    always @(*) uart_rx = uart_tx;

    uart
        #(
            .WIDTH(WIDTH ),
            .SAMPLE_RATE(SAMPLE_RATE ),
            .USE_PARITY(USE_PARITY ),
            .USE_TX_FIFO(USE_TX_FIFO ),
            .USE_RX_FIFO(USE_RX_FIFO ),
            .TX_FIFO_DEPTH(TX_FIFO_DEPTH ),
            .RX_FIFO_DEPTH (
                RX_FIFO_DEPTH )
        )
        uart_dut (
            .clk (clk ),
            .rst (rst ),
            .cfg_parity (cfg_parity ),
            .cfg_stop_bits (cfg_stop_bits ),
            .cfg_clk_div (cfg_clk_div ),
            .rx_req (rx_req ),
            .rx_data (rx_data ),
            .rx_ready (rx_ready ),
            .parity_err (parity_err ),
            .uart_rx (uart_rx ),
            .tx_req (tx_req ),
            .tx_din (tx_din ),
            .tx_ready (tx_ready ),
            .uart_tx  ( uart_tx)
        );

    initial
    begin
        rst = 1'b1;
        @(posedge clk);
        #1;
        rst = 1'b0;
        @(posedge clk);
        repeat (20)
        begin
            send();
        end

    end

    initial
    begin
        repeat(20)
        begin
            receive();
        end
        #100;
        print_result();
        $finish;
    end

    always
        #5  clk = ! clk ;   // 10 ns clock

    task send;
        begin
            #1;
            wait(tx_ready);
            tx_req = 1'b1;
            tx_din = txdata;
            txdata = txdata + 1;
            @(posedge clk);
            #1;
            tx_req = 1'b0;
        end
    endtask

    task receive;
        begin
            #1;
            wait(rx_ready);
            rx_req = 1'b1;
            assert(rx_data === rxdata);
            if (rx_data != rxdata)
            begin
                error = error + 1;
                $display("Error: get wrong rx data. Expected: %d, Actual: %d.", rxdata, rx_data);
            end
            rxdata = rxdata + 1;
            @(posedge clk);
            #1;
            rx_req = 1'b0;
        end
    endtask

    task print_result;
        begin
            if (error)
            begin
                $display("\n");
                $display("#####################################################");
                $display("#              Test Completes - Failed              #");
                $display("#####################################################");
            end
            else
            begin
                $display("\n");
                $display("#####################################################");
                $display("#             Test Completes - success              #");
                $display("#####################################################");
            end
        end
    endtask

    initial
    begin
        $dumpfile("dump.vcd");
        $dumpvars(0, uart_fifo_loopback);
    end

endmodule
