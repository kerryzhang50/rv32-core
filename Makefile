TOP = alu

RTL = \
    rtl/core/rv32_pkg.sv \
    rtl/core/alu.sv

TB = sim/tb_alu.cpp

CFLAGS = -Wall -O2

all:
	verilator \
		--cc --top-module $(TOP) $(RTL) \
		--exe $(TB) \
		--build \
		--trace

run:
	./obj_dir/V$(TOP)

clean:
	rm -rf obj_dir
	rm -f *.vcd