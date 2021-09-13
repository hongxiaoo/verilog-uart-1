# verilog-uart

This is a basic UART IP written in verilog.

## Source File

| File               | Description                              |
| ------------------ | ---------------------------------------- |
| rtl/uart_tx.v      | uart transmitter module                  |
| rtl/uart_rx.v      | uart receiver module                     |
| rtl/uart_tx_fifo.v | uart transmitter module with fifo buffer |
| rtl/uart_rx_fifo.v | uart receiver module with fifo buffer    |
| rtl/uart.v         | uart top level wrapper with tx/rx        |

- The uart.v contains both the rx and tx module and FIFO buffer is optional. User can change the setting through parameters.
- Or user can choose to use either rx or rx module with or without the fifo buffer.

## Parameter Description

Parameters in rtl/uart.v

| Parameter     | Description                                                                                     |
| ------------- | ----------------------------------------------------------------------------------------------- |
| WIDTH         | Data width for each uart transfer                                                               |
| SAMPLE_RATE   | Sample count for each uart bit. Default is 16                                                   |
| USE_PARITY    | Use parity bit in receiver. If set, the parity_err signal will be set if there is parity error. |
| USE_TX_FIFO   | Use FIFO buffer in TX path                                                                      |
| USE_RX_FIFO   | Use FIFO buffer in RX path                                                                      |
| TX_FIFO_DEPTH | FIFO depth in TX path                                                                           |
| RX_FIFO_DEPTH | FIFO depth in RX path                                                                           |

## Signal Description

Signals in rtl/uart.v

| Signal        | Description                                                                            |
| ------------- | -------------------------------------------------------------------------------------- |
| clk           | clock signal                                                                           |
| rst           | reset signal                                                                           |
| cfg_parity    | parity bit configuration. 0: no parity, 1: odd parity, 2: even parity                  |
| cfg_stop_bits | stop bit configuration. 0: 1 stop bit, 1: 1.5 stop bit, 2: 2 stop bit                  |
| cfg_clk_div   | Number of clock for 1 sample. Equation: (clk frequency in Hz / buad rate) / sample rate |
| rx_req        | rx request                                                                             |
| rx_data       | rx data                                                                                |
| rx_ready      | rx ready                                                                               |
| parity_err    | indicate parity error in receive data                                                  |
| uart_rx       | uart rx signal                                                                         |
| tx_req        | tx request                                                                             |
| tx_din        | tx data in                                                                             |
| tx_ready      | tx ready                                                                               |
| uart_tx       | uart tx signal                                                                         |

## Demo

A FPGA demo is also provided in this repo. The demo is targeting the Digilent Arty A7 FPGA board.

In the demo project, the uart is configured as a loopback mode. It will receive the data from host machine and send it back to the host machine.

Once the FPGA board is programed, you can use a serial terminal program to send to FPGA board and moniter received data.

To run the demo program, you need to have Xilinx Vivado installed.

Here is the command to build and program FPGA

```bash
cd demo/arty
make all
```
