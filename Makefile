TOP = decode_top

RTL = \
    rtl/core/rv32_pkg.sv \
    rtl/core/instr_fields.sv \
    rtl/core/control_decoder.sv \
    rtl/core/decode_top.sv

TB = sim/tb_decode.cpp

CFLAGS = -Wall -O2

all:
	verilator \
		--top decode_top --cc $(RTL) \
		--exe $(TB) \
		--build \
		--trace

run:
	./obj_dir/V$(TOP)

clean:
	rm -rf obj_dir
	rm -f *.vcd