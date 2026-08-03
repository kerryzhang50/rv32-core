VERILATOR = verilator

ASM = add_test

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

assemble:
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -T ../linker.ld ../tests/asm/$(ASM).S -o ../tests/elf/$(ASM).elf

disassemble:
	riscv64-unknown-elf-objdump -d ../tests/elf/$(ASM).elf

convert:
	riscv64-unknown-elf-objcopy -O verilog ../tests/elf/$(ASM).elf ../tests/hex/$(ASM).hex

clean:
	rm -rf obj_dir
	rm -f *.vcd