TOP = imm_gen

RTL = \
    rtl/core/rv32_pkg.sv \
    rtl/core/imm_gen.sv

TB = sim/tb_imm_gen.cpp

CFLAGS = -Wall -O2

all:
	verilator \
		--top imm_gen --cc $(RTL) \
		--exe $(TB) \
		--build \
		--trace

run:
	./obj_dir/V$(TOP)

clean:
	rm -rf obj_dir
	rm -f *.vcd