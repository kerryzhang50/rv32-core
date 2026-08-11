VERILATOR = verilator

ASM = branch_test

RTL = \
	../rtl/rv32_pkg.sv \
	../rtl/mem_if.sv \
    ../rtl/core/rv32_core.sv \
	../rtl/core/branch_unit.sv \
    ../rtl/core/regfile.sv \
    ../rtl/core/alu.sv \
    ../rtl/core/control_decoder.sv \
    ../rtl/core/imm_gen.sv \
    ../rtl/core/instr_fields.sv \
    ../rtl/mem/imem.sv \
	../rtl/mem/simple_dmem.sv \
	../rtl/core/load_unit.sv \
	../rtl/core/store_unit.sv \
	../rtl/core/if_id_reg.sv \
	../rtl/core/id_ex_reg.sv \
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
	python3 ../scripts/elf_to_hex.py ../tests/elf/$(ASM).elf ../tests/hex/$(ASM).hex

clean:
	rm -rf obj_dir
	rm -f *.vcd