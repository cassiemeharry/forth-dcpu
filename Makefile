all: forth-core.dasm forth-macros.m4
	m4 forth-core.dasm | dtasm -o forth-core.bin -
clean:
	rm -rf *.bin *.o
