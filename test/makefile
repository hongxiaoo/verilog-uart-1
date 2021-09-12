
ROOT = $(shell git rev-parse --show-toplevel)
export UART = $(ROOT)
export ARBITRATION = $(ROOT)/ip/verilog-misc-ip/arbitration
export MISC = $(ROOT)/ip/verilog-misc-ip/misc

target = uart

$(target):
	@mkdir -p output/$@
	@iverilog -g2005-sv -f $@.f -o output/$@/$@.out
	@cd output/$@ && ./$@.out

clean:
	@rm -rf output