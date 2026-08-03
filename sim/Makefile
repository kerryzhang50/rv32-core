VERILATOR = verilator

RTL = \
	../rtl/rv32_pkg.sv \
    ../rtl/core/rv32_core.sv \
    ../rtl/core/regfile.sv \
    ../rtl/core/alu.sv \
    ../rtl/core/control_decoder.sv \
    ../rtl/core/imm_gen.sv \
    ../rtl/core/instr_fields.sv \
    ../rtl/mem/imem.sv \
    sim_top.sv

build:
	$(VERILATOR) \
	    --top sim_top --cc \
	    --exe \
	    --build \
	    --trace \
	    $(RTL) \
	    tb_cpu.cpp

run:
	./obj_dir/Vsim_top

clean:
	rm -rf obj_dir
	rm -f *.vcd