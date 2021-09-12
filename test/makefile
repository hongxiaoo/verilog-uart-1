
ROOT = $(shell git rev-parse --show-toplevel)

export UART 		= $(ROOT)
export ARBITRATION 	= $(ROOT)/ip/verilog-misc-ip/arbitration
export MISC 		= $(ROOT)/ip/verilog-misc-ip/misc
export STORAGE 		= $(ROOT)/ip/verilog-misc-ip/storage

target = uart_loopback uart_fifo_loopback uart_loopback_parity

all: $(target)

$(target):
	@mkdir -p output/$@
	@iverilog -g2005-sv -f filelist/$@.f -o output/$@/$@.out
	@cd output/$@ && ./$@.out

clean:
	@rm -rf output