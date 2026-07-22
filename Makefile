TOP = rv32_core
TB = sim/tb_core.cpp

SRC = \
rtl/rv32_core.sv

all:
	verilator \
	--cc $(SRC) \
	--exe $(TB) \
	--build \
	--trace

run:
	./obj_dir/V$(TOP)

clean:
	rm -rf obj_dir
	rm -f *.vcd