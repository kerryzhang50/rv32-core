TOP = regfile

RTL = \
    rtl/core/regfile.sv

TB = sim/tb_regfile.cpp

CFLAGS = -Wall -O2

all:
	verilator \
		--cc $(RTL) \
		--exe $(TB) \
		--build \
		--trace

run:
	./obj_dir/V$(TOP)

clean:
	rm -rf obj_dir
	rm -f *.vcd