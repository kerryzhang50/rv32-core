TOP = instr_fields

RTL = \
    rtl/core/instr_fields.sv

TB = sim/tb_instr_fields.cpp

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