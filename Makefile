CFLAGS=-std=c++14 -Wall -Wno-empty-body -g
VFILES:= gmii_to_rgmii.v wb_interface.v crc32.v
TESTS:= $(patsubst %.v, obj_dir/V%, $(VFILES))
SBYS:= $(wildcard *.sby)
FORMAL:=$(patsubst %.sby, %/PASS, $(SBYS))
LDFLAGS=
VFLAGS:=-Wall -trace --public -I../rtl
all: $(TESTS) 

obj_dir/V%.h: %.v 
	verilator $(VFLAGS) -CFLAGS "$(CFLAGS)" --cc test_$*.cpp --exe $<

obj_dir/V%: test_%.cpp obj_dir/V%.h $(wildcard *.h)
	$(MAKE) -C obj_dir -f V$*.mk V$*
	./$@

top.json: top.v gmii_to_rgmii.v pll.v reset.v mac.v wb_interface.v afifo.v crc32.v gmii_interface.v master.v
	yosys -p "synth_ecp5 -json $@ -top top" $^
%_out.config: %.json versa.lpf
	nextpnr-ecp5 --json $< --basecfg /usr/local/share/trellis/misc/basecfgs/empty_lfe5um-45f.config --textcfg $@ --um-45k --package CABGA381 --lpf versa.lpf --freq 125

%.bit: %_out.config
	ecppack --svf-rowsize 100000 --svf top.svf $< $@

rtl: top.bit
prog: top.svf top.bit
	openocd -f /usr/local/share/trellis/misc/openocd/ecp5-versa.cfg -c "transport select jtag; init; svf $<; exit"

formal: $(FORMAL)

%/PASS: %.sby %.v
	sby -f $<

.PHONY: formal

clean:
	rm -f *.smt2
	rm -f *.vcd
	rm -rf altera_tx/
	rm -rf controller/
	rm -rf fifo/
	rm -rf phase_accum/
	rm -rf sampler/
	rm -rf spi/

distclean:
	rm *~
