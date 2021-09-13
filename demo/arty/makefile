############################################################
# makefile for running vivado
############################################################

# Variable
ROOT     		= $(shell git rev-parse --show-toplevel)
UART 			= $(ROOT)
ARBITRATION 	= $(ROOT)/ip/verilog-misc-ip/arbitration
MISC 			= $(ROOT)/ip/verilog-misc-ip/misc
STORAGE 		= $(ROOT)/ip/verilog-misc-ip/storage

_DEVICE = xc7a35ticsg324-1L

TOP_RTL		  = uart_top

_RTL_SRC      += $(ROOT)/demo/arty/rtl/$(TOP_RTL).v
_RTL_SRC      += ${ARBITRATION}/rtl/majority3.v
_RTL_SRC      += ${MISC}/rtl/dsync.v
_RTL_SRC      += ${STORAGE}/rtl/fifo.v
_RTL_SRC      += ${STORAGE}/rtl/fifo_fwft.v
_RTL_SRC      += ${UART}/rtl/uart_rx.v
_RTL_SRC      += ${UART}/rtl/uart_rx_fifo.v
_RTL_SRC      += ${UART}/rtl/uart_tx.v
_RTL_SRC      += ${UART}/rtl/uart_tx_fifo.v
_RTL_SRC      += ${UART}/rtl/uart.v

_XDC          += constraint/io.xdc
_XDC          += constraint/timing.xdc

export PRJ_NAME 	= arty
export TOP 			= uart_top
export RTL_SRC     	= $(_RTL_SRC)
export XDC         	= $(_XDC)
export DEVICE 	    = $(_DEVICE)
export PROGRAM 		= $(_PROGRAM)

OUTPUT = $(PRJ_NAME)/output


all: clean build pgm

build: $(OUTPUT)/$(TOP).bit

pgm:
	vivado -mode tcl -source script/program.tcl | tee program.log

$(OUTPUT)/$(TOP).bit:
	vivado -mode tcl -source script/build.tcl | tee build.log

clean:
	rm -rf arty vivado* .Xil *.jou *.log