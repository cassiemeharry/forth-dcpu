all: combined.dasm
	dtasm -o forth-core.bin combined.dasm
combined.dasm: forth-macros.m4 forth-core.dasm
	m4 forth-macros.m4 forth-core.dasm > combined.dasm
clean:
	rm -rf *.bin combined.dasm
