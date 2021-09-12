
ROOT = $(shell git rev-parse --show-toplevel)

export UART 		= $(ROOT)
export ARBITRATION 	= $(ROOT)/ip/verilog-misc-ip/arbitration
export MISC 		= $(ROOT)/ip/verilog-misc-ip/misc
export STORAGE 		= $(ROOT)/ip/verilog-misc-ip/storage

target = uart uart_fifo

$(target):
	@mkdir -p output/$@
	@iverilog -g2005-sv -f $@.f -o output/$@/$@.out
	@cd output/$@ && ./$@.out

clean:
	@rm -rf output